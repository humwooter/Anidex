//
//  CameraPreviewDemo.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/25/24.
//

import Foundation
import SwiftUI
import UIKit
import AVFoundation

struct CameraPreviewDemo: UIViewRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        // If there is a selected image, display it
        if let selectedImage = selectedImage {
            let imageView = UIImageView(image: selectedImage)
            imageView.frame = view.bounds
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .black
            view.addSubview(imageView)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // If the selected image changes, update the view
        if let selectedImage = selectedImage {
            // Remove any existing subviews (e.g., old images)
            uiView.subviews.forEach { $0.removeFromSuperview() }
            
            // Add the new image
            let imageView = UIImageView(image: selectedImage)
            imageView.frame = uiView.bounds
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .black
            uiView.addSubview(imageView)
        } else {
            // Remove the image view if there is no selected image
            uiView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
}
