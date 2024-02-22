//
//  CameraFuncs.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import AVFoundation
import SwiftUI
import CoreML
import Vision

func currentOrientation() -> CGImagePropertyOrientation {
    let deviceOrientation = UIDevice.current.orientation
    switch deviceOrientation {
    case .portrait: return .up
    case .portraitUpsideDown: return .down
    case .landscapeLeft: return .left
    case .landscapeRight: return .right
    default: return .up
    }
}
