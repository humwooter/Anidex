//
//  Formatters.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/24/24.
//

import Foundation


//Time and Location String representations 

func formatLocation(latitude: Double, longitude: Double) -> String {
    String(format: "Lat: %.2f, Lon: %.2f", latitude, longitude)
}


func formatShortDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
}

func formatLongDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    return dateFormatter.string(from: date)
}
