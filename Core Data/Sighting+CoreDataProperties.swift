//
//  Sighting+CoreDataProperties.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//
//

import Foundation
import CoreData


extension Sighting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sighting> {
        return NSFetchRequest<Sighting>(entityName: "Sighting")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var imageFilename: String?
    @NSManaged public var lattitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var notes: String?
    @NSManaged public var relationship: Species?

}

extension Sighting : Identifiable {

}
