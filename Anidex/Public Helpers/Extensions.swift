//
//  Extensions.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/23/24.
//

import Foundation
import SwiftUI

func isClear(for color: UIColor) -> Bool {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return ((red + green + blue + alpha) == 0)
}

extension UIColor {
    static func foregroundColor(background: UIColor) -> UIColor { //returns highest contrast font color (black or white) based off of background color
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if (isClear(for: background)) {
            let new_background = UIColor.systemGroupedBackground
            new_background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        
        print("print background color: \(background)")

        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        print("brightness value: \(brightness)")
        
        return brightness > 0.5 ? UIColor.black : UIColor.white
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
