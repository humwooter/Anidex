//
//  Sighting+CoreDataClass.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//
//

import Foundation
import CoreData

@objc(Sighting)
public class Sighting: NSManagedObject, Codable {
    
    required public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp)
        id = try values.decodeIfPresent(UUID.self, forKey: .id)
        imageFilename = try values.decodeIfPresent(String.self, forKey: .imageFilename)
        lattitude = try values.decode(Double.self, forKey: .lattitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        scientificName = try values.decodeIfPresent(String.self, forKey: .scientificName)
        notes = try values.decodeIfPresent(String.self, forKey: .notes)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(imageFilename, forKey: .imageFilename)
        try container.encode(lattitude, forKey: .lattitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(scientificName, forKey: .scientificName)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, id, imageFilename, lattitude, longitude, name, scientificName, notes
    }
}

