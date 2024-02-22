//
//  Species+CoreDataProperties.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//
//

import Foundation
import CoreData


extension Species {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Species> {
        return NSFetchRequest<Species>(entityName: "Species")
    }

    @NSManaged public var classLabel: String?
    @NSManaged public var familyLabel: String?
    @NSManaged public var isDiscovered: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var phylumLabel: String?
    @NSManaged public var id: UUID?
    @NSManaged public var scientificLabel: String?
    @NSManaged public var commonLabel: String?
    @NSManaged public var relationship: NSSet?

}

// MARK: Generated accessors for relationship
extension Species {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Sighting)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Sighting)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}

extension Species : Identifiable {

}
