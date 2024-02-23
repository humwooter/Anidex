//
//  Sighting Helpers.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/22/24.
//

import Foundation
import CoreData

func fetchSpeciesCategory(withScientificName name: String, context: NSManagedObjectContext) -> [Species] {
    print("entered func")
    let fetchRequest: NSFetchRequest<Species> = Species.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "scientificLabel == %@", name)

    do {
        let species = try context.fetch(fetchRequest)

        return species
    } catch {
        print("Error fetching entries: \(error)")
        return []
    }
}

func save(context: NSManagedObjectContext) {
  print("Saving context: \(context)")
  context.performAndWait {
    do {
      try context.save()
      print("Successfully saved context: \(context)")
    } catch {
      print("Failed to save context: \(error)")
    }
  }
}
