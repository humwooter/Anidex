//
//  CameraPreview.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    @Binding var selectedImage: UIImage?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
            view.addGestureRecognizer(pinchGesture)
        
        DispatchQueue.main.async {
            camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
            camera.preview.frame = view.frame
            view.layer.addSublayer(camera.preview)
        }
        
        DispatchQueue.global(qos: .background).async {
            camera.session.startRunning()
        }
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if camera.isTaken, let selectedImage = selectedImage {
            let imageView = UIImageView(image: selectedImage)
            imageView.frame = uiView.bounds
            imageView.contentMode = .scaleAspectFit
            
            
            imageView.backgroundColor = .black
            imageView.translatesAutoresizingMaskIntoConstraints = false

            uiView.addSubview(imageView)
        } else {
            uiView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        camera.session.stopRunning()
    }
    
    class Coordinator: NSObject {
        var parent: CameraPreview

        init(_ parent: CameraPreview) {
            self.parent = parent
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            if gesture.state == .changed {
                let scale = gesture.scale
                parent.camera.zoom *= scale
                parent.camera.setZoom(parent.camera.zoom)
                gesture.scale = 1.0
            }
        }
    }
}
