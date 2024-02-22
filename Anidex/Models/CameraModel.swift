//
//  CameraModel.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import AVFoundation
import SwiftUI
import CoreML
import Vision




class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var classifierModel = ClassifierModel()
    @Published var originalData = Data(count: 0)
    @Published var zoom: CGFloat = 1.0

    
    //Bools
    @Published var isCapturing = false
    @Published var isTaken = false
    @Published var showAlert = false
    @Published var showClassificationAlert = false
    @Published var isSaved = false
    @Published var isSaving = false
    @Published var isProcessing  = false

    
    
    
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!

    
    var currentCameraPosition: AVCaptureDevice.Position = .back
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    
    
    func setUp() {
        do {
            self.session.beginConfiguration()
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            
            let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: currentCameraPosition).devices
            
            guard !availableDevices.isEmpty, let device = availableDevices.first else {
                print("Specified camera not available.")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if !self.session.outputs.contains(self.output) && self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func takePic() -> Bool {
        guard !isCapturing else {
            print("Already capturing...")
            return false
        }
        
        isCapturing = true
        print("in take pic")
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isProcessing = true
                self.isTaken = true
                
                let settings = AVCapturePhotoSettings()
                settings.flashMode = self.flashMode
                self.output.capturePhoto(with: settings, delegate: self)
            }
        }
        print("out of take pic, and isProcessing is: \(isProcessing)")
        return isProcessing
    }

    
    func retakePic() {
        print("in retake pic")
        self.originalData = Data(count: 0) // Clear the original data
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken = false
                    self.isSaved = false
                }
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            print(error?.localizedDescription)
            isCapturing = false
            return
        }
        print("Picture has been taken")
        
        if let imageData = photo.fileDataRepresentation() {
            self.originalData = imageData
            processImageData(imageData)
        }
        
        self.session.stopRunning()
        isCapturing = false
    }
    
    func isCameraAvailable(_ position: AVCaptureDevice.Position) -> Bool {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        return devices.contains { $0.position == position }
    }
    
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.showAlert.toggle()
            return
        default:
            return
        }
    }
    
    func toggleCamera() {
        switch currentCameraPosition {
        case .unspecified, .front:
            currentCameraPosition = .back
        case .back:
            currentCameraPosition = .front
        default:
            return
        }
        setUp()
    }
    
    func toggleFlash() {
        flashMode = flashMode == .on ? .off : .on
    }
    
    func setZoom(_ zoom: CGFloat) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else { return }
        do {
            try device.lockForConfiguration()
            let zoomFactor = max(Float(1.0), min(Float(zoom), Float(device.activeFormat.videoMaxZoomFactor)))
            device.videoZoomFactor = CGFloat(zoomFactor)
            device.unlockForConfiguration()
        } catch {
            print("Failed to set zoom: \(error)")
        }
    }
    
    
    // Saving images
    func savePic() {
        self.isSaving = true
        if !isCapturing && originalData.count > 0 {
            UIImageWriteToSavedPhotosAlbum(UIImage(data: originalData)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            self.isSaved = false
//            self.classificationAlert = false
        }
        self.isSaving = false
        self.isSaved = true
//        self.classificationAlert = false
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle error
            print("Error saving image: \(error.localizedDescription)")
        } else {
            isSaved = true
        }
    }
    
    func processImageData(_ imageData: Data, shouldClassify: Bool = true) {
        self.originalData = imageData
        if let uiImage = UIImage(data: imageData) {
            self.classifierModel.classify(image: uiImage) {
                self.isProcessing = false
                self.showClassificationAlert = true
                print("Prediction: \(self.classifierModel.predictionLabel)")
            }
        }
    }
}

