//
//  ClassifierModel.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import UIKit
import Vision
import CoreML


class ClassifierModel: NSObject, ObservableObject {
    
    //requests
    private var chordataClassRequest: VNCoreMLRequest?
    private var speciesClassificationRequest: VNCoreMLRequest?
    
    private var visionQueue = DispatchQueue(label: "ClassifierModel-BackgroundQueue")
    
    // the classifiers
    private var chordataClassClassifier: VNCoreMLModel
    private var specificClassClassifier: VNCoreMLModel? // corresponds to one of the four chordata classes
    
    //vars
    private var currentImage: UIImage?
    @Published var predictionLabel = ""
    @Published var confidenceLabel = ""
    
    //names
    @Published var phylumName = ""
    @Published var className = ""
    @Published var scientificName = ""
    @Published var familyName = ""
    @Published var commonName = ""
    
    //bools
    @Published var isClassificationComplete = false
    
    override init() {
        let defaultConfig = MLModelConfiguration()
        guard let chordataClassifier = try? ChordataClassClassifier(configuration: defaultConfig),
              let visionChordataModel = try? VNCoreMLModel(for: chordataClassifier.model) else {
            fatalError("Failed to create ChordataClassClassifier VNCoreMLModel.")
        }
        self.chordataClassClassifier = visionChordataModel
        super.init()
        self.chordataClassRequest = VNCoreMLRequest(model: chordataClassClassifier, completionHandler: handleChordataClassification)

        // Set usesCPUOnly for simulator
        #if targetEnvironment(simulator)
        self.chordataClassRequest?.usesCPUOnly = true
        #endif
    }
    
    func setupLifecycleNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleAppDidEnterBackground() {
        #if targetEnvironment(simulator)
        updateModelForBackground()
        #endif
    }

    @objc private func handleAppWillEnterForeground() {
        #if targetEnvironment(simulator)
        updateModelForForeground()
        #endif
    }
    
    private func updateModelForBackground() {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly // force model to use CPU only in the simulator
        updateChordataClassModel(with: config)
    }

    private func updateModelForForeground() {
        let config = MLModelConfiguration()
        updateChordataClassModel(with: config)
    }

    private func updateChordataClassModel(with config: MLModelConfiguration) {
        guard let newModel = try? ChordataClassClassifier(configuration: config),
              let visionModel = try? VNCoreMLModel(for: newModel.model) else {
            fatalError("Could not update ChordataClass model configuration.")
        }
        self.chordataClassClassifier = visionModel
        self.chordataClassRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleChordataClassification)
    }
    
    private func createSpecificClassifier(forClass className: String) -> VNCoreMLModel? {
        let defaultConfig = MLModelConfiguration()
        var model: MLModel?

        switch className {
        case "Mammalia":
            model = try? MammalClassifier(configuration: defaultConfig).model
        case "Aves":
            model = try? AvesClassifier(configuration: defaultConfig).model
        case "Reptilia":
            model = try? ReptilliaClassifier(configuration: defaultConfig).model
        case "Amphibia":
            model = try? AmphibiaClassifier(configuration: defaultConfig).model
        default:
            return nil
        }

        return model.flatMap { try? VNCoreMLModel(for: $0) }
    }
    
    private func classifyWithSpecificClassifier(image: UIImage) {
        guard let specificRequest = speciesClassificationRequest, let ciImage = CIImage(image: image) else { return }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        visionQueue.async {
            do {
                try handler.perform([specificRequest])
            } catch {
                print("Failed to perform specific classification: \(error)")
            }
        }
    }
    
    func classifyForDemo(image: UIImage, completion: @escaping () -> Void) async{
        self.currentImage = image
        guard let chordataRequest = chordataClassRequest, let ciImage = CIImage(image: image) else { return }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        visionQueue.async {
            do {
                // Perform Chordata Classification
                try handler.perform([chordataRequest])
                
                // Handle Chordata Classification Result
                if let bestResult = self.processChordataClassificationResults(request: chordataRequest),
                   let specificClassifier = self.createSpecificClassifier(forClass: bestResult) {
                    
                    
                    print("BEST RESULT: \(bestResult)")
                    
                    // Create and perform Specific Classification
                    self.speciesClassificationRequest = VNCoreMLRequest(model: specificClassifier, completionHandler: self.handleSpecificClassification)
                    if let specificRequest = self.speciesClassificationRequest {
                        try handler.perform([specificRequest])
                    }
                }

                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Failed to perform classification: \(error)")
            }
        }
    }
    
    func classify(image: UIImage, completion: @escaping () -> Void) {
        self.currentImage = image
        guard let chordataRequest = chordataClassRequest, let ciImage = CIImage(image: image) else { return }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        visionQueue.async {
            do {
                // Perform Chordata Classification
                try handler.perform([chordataRequest])
                
                // Handle Chordata Classification Result
                if let bestResult = self.processChordataClassificationResults(request: chordataRequest),
                   let specificClassifier = self.createSpecificClassifier(forClass: bestResult) {
                    
                    
                    
                    // Create and perform Specific Classification
                    self.speciesClassificationRequest = VNCoreMLRequest(model: specificClassifier, completionHandler: self.handleSpecificClassification)
                    if let specificRequest = self.speciesClassificationRequest {
                        try handler.perform([specificRequest])
                    }
                }

                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Failed to perform classification: \(error)")
            }
        }
    }
    
    private func handleSpecificClassification(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation],
              let bestResult = results.first(where: { $0.confidence > 0.3 }) else { return }

        DispatchQueue.main.async {
            self.predictionLabel = bestResult.identifier
            self.confidenceLabel = String(bestResult.confidence)
            self.parseLabel(label: bestResult.identifier)
            self.isClassificationComplete = true
        }
    }
    
    func parseLabel(label: String) {
        let components = label.split(separator: "_").map(String.init)
        if components.count >= 7 {
            self.phylumName = components[1]
            self.className = components[2]
            self.familyName = components[4]
            self.scientificName = "\(components[5]) \(components[6])"
            self.commonName = components.dropFirst(7).joined(separator: " ")
        }
    }

}


extension ClassifierModel {
    private func processChordataClassificationResults(request: VNRequest) -> String? {
        guard let results = request.results as? [VNClassificationObservation],
              let bestResult = results.first(where: { $0.confidence > 0.3 }) else { return nil }

        return bestResult.identifier.components(separatedBy: "_").last
    }
    
    private func handleChordataClassification(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation],
              let bestResult = results.first(where: { $0.confidence > 0.3 }),
              let currentImage = self.currentImage else { return }

        let className = bestResult.identifier.components(separatedBy: "_").last ?? ""
        print("CLASS NAME: \(className)")
        DispatchQueue.main.async {
            self.specificClassClassifier = self.createSpecificClassifier(forClass: className)
            self.speciesClassificationRequest = self.specificClassClassifier.flatMap {
                let request = VNCoreMLRequest(model: $0, completionHandler: self.handleSpecificClassification)

                #if targetEnvironment(simulator)
                request.usesCPUOnly = true
                #endif

                return request
            }

            self.classifyWithSpecificClassifier(image: currentImage)
        }
    }
}
