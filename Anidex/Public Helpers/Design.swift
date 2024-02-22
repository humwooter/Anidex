//
//  Design.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI

func colorForConfidence(confidenceString: String) -> Color {
    if let confidence = Float(confidenceString) {
        return Color(red: 1.0 - CGFloat(confidence), green: CGFloat(confidence), blue: 0)
    }
    return Color.gray
}
