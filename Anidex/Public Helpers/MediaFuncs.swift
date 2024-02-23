//
//  MediaFuncs.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/22/24.
//

import Foundation
import SwiftUI



func getImageData(fromFilename filename: String) -> Data? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(filename)
    
    if FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("Error reading image file: \(error)")
            return nil
        }
    } else {
        print("File does not exist at path: \(fileURL.path)")
        return nil
    }
}

func getImagesData(forSightings sightings: [Sighting]) -> [Data] {
    var imagesData: [Data] = []

    for sighting in sightings {
        if let filename = sighting.imageFilename, let imageData = getImageData(fromFilename: filename) {
            imagesData.append(imageData)
        }
    }

    return imagesData
}


func getImageURL(imageFilename: String) -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let imageURL = documentsDirectory.appendingPathComponent(imageFilename)
    return imageURL
}


func saveImageToDocumentsDirectory(image: UIImage?) -> String {
    guard let data = image?.jpegData(compressionQuality: 1.0) else { return "" }
    let filename = UUID().uuidString
    let filepath = getDocumentsDirectory().appendingPathComponent(filename)
    try? data.write(to: filepath)
    return filename
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
