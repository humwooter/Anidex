//
//  Species+CoreDataClass.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//
//

import Foundation
import CoreData

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

@objc(Species)
public class Species: NSManagedObject, Codable {
    
    required public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
          }

          self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(UUID.self, forKey: .id)!
        commonLabel = try values.decodeIfPresent(String.self, forKey: .commonLabel)
        classLabel = try values.decodeIfPresent(String.self, forKey: .classLabel)
        familyLabel = try values.decodeIfPresent(String.self, forKey: .familyLabel)
        phylumLabel = try values.decodeIfPresent(String.self, forKey: .phylumLabel)
        isDiscovered = try values.decode(Bool.self, forKey: .isDiscovered)
        isFavorite = try values.decode(Bool.self, forKey: .isFavorite)
    }
    
    public func encode(to encoder: Encoder) throws {
        print("entry: \(self)")
     
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(commonLabel, forKey: .commonLabel)
        try container.encodeIfPresent(classLabel, forKey: .classLabel)
        try container.encodeIfPresent(familyLabel, forKey: .familyLabel)
        try container.encodeIfPresent(phylumLabel, forKey: .phylumLabel)
        try container.encode(isDiscovered, forKey: .isDiscovered)
        try container.encode(isFavorite, forKey: .isFavorite)
    }

    
    private enum CodingKeys: String, CodingKey {
        case id, relationship, commonLabel, classLabel, familyLabel, phylumLabel, isDiscovered, isFavorite
    }
}
