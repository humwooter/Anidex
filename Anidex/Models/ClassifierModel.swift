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
    private var specificClassClassifier: VNCoreMLModel? //one of four chordata classes
    
    //vars
    private var currentImage: UIImage? // State variable to save the current image
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
    
    func classify(image: UIImage, completion: @escaping () -> Void) {
        self.currentImage = image // Save the current image
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
    
    private func handleSpecificClassification(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation],
              let bestResult = results.first(where: { $0.confidence > 0.3 }) else { return }

        DispatchQueue.main.async {
            self.predictionLabel = bestResult.identifier
            self.confidenceLabel = String(bestResult.confidence)
            self.parseLabel(label: bestResult.identifier)
            self.isClassificationComplete = true
            // Update additional UI elements or perform further actions as needed
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
                VNCoreMLRequest(model: $0, completionHandler: self.handleSpecificClassification)
            }
            self.classifyWithSpecificClassifier(image: currentImage)
        }
    }
}
