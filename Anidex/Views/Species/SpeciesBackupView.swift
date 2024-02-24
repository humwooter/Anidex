//
//  SpeciesBackupView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/24/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct SpeciesBackupView: View {
    @FetchRequest(
        entity: Species.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isDiscovered == true")
    ) private var discoveredSpecies: FetchedResults<Species>
    
    @State private var isExporting = false
    @State private var isImporting = false
    
    @EnvironmentObject var coreDataManager: CoreDataManager


    var body: some View {
        Section(header: Text("Species Data")) {
            VStack {
                Button("Backup") {
                    isExporting = true
                }
                .fileExporter(
                    isPresented: $isExporting,
                    document: SpeciesDocument(speciesData: encodeDiscoveredSpecies()),
                    contentType: .json,
                    defaultFilename: "DiscoveredSpeciesBackup.json"
                ) { result in
                    handleExportResult(result)
                }

                Button("Restore") {
                    isImporting = true
                }
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.json]
                ) { result in
                    handleImportResult(result)
                }
            }
        }
    }

    private func encodeDiscoveredSpecies() -> Data {
        do {
            return try JSONEncoder().encode(Array(discoveredSpecies))
        } catch {
            print("Error encoding species: \(error)")
            return Data()
        }
    }

    private func handleExportResult(_ result: Result<URL, Error>) {
        // Handle the export result
        switch result {
        case .success(let url):
            print("File successfully saved at \(url)")
        case .failure(let error):
            print("Failed to save file: \(error)")
        }
    }

    private func handleImportResult(_ result: Result<URL, Error>) {
        // Handle the import result, update Core Data
        switch result {
        case .success(let url):
            importSpeciesData(from: url)
        case .failure(let error):
            print("Failed to import file: \(error)")
        }
    }

    private func importSpeciesData(from url: URL) {
        guard let jsonData = try? Data(contentsOf: url) else { return }

        coreDataManager.backgroundContext.performAndWait {
            do {
                let decodedSpeciesArray = try JSONDecoder().decode([Species].self, from: jsonData)

                for speciesData in decodedSpeciesArray {
                    let speciesFetchRequest: NSFetchRequest<Species> = Species.fetchRequest()
                    speciesFetchRequest.predicate = NSPredicate(format: "id == %@", speciesData.id as! any CVarArg as CVarArg)
                    let existingSpecies = try coreDataManager.backgroundContext.fetch(speciesFetchRequest).first

                    let species = existingSpecies ?? Species(context: coreDataManager.backgroundContext)
                    updateSpecies(species, with: speciesData, in: coreDataManager.backgroundContext)
                }
                try coreDataManager.backgroundContext.save()
            } catch {
                print("Error importing species data: \(error)")
            }
        }
    }


    private func updateSpecies(_ species: Species, with data: Species, in context: NSManagedObjectContext) {
        species.id = data.id
        species.classLabel = data.classLabel
        species.familyLabel = data.familyLabel
        species.isDiscovered = data.isDiscovered
        species.isFavorite = data.isFavorite
        species.phylumLabel = data.phylumLabel
        species.scientificLabel = data.scientificLabel
        species.commonLabel = data.commonLabel

        updateRelationships(for: species, with: data, in: context)
    }

    private func updateRelationships(for species: Species, with data: Species, in context: NSManagedObjectContext) {
        guard let newSightings = data.relationship as? Set<Sighting> else { return }
        
        for sightingData in newSightings {
            let sightingFetchRequest: NSFetchRequest<Sighting> = Sighting.fetchRequest()
            sightingFetchRequest.predicate = NSPredicate(format: "id == %@", sightingData.id as! any CVarArg as CVarArg)
            let existingSighting = try? context.fetch(sightingFetchRequest).first
            
            let sighting = existingSighting ?? Sighting(context: context)
            sighting.id = sightingData.id
            sighting.timestamp = sightingData.timestamp
            sighting.imageFilename = sightingData.imageFilename
            sighting.lattitude = sightingData.lattitude
            sighting.longitude = sightingData.longitude
            sighting.name = sightingData.name
            sighting.scientificName = sightingData.scientificName
            sighting.notes = sightingData.notes
            
            species.addToRelationship(sighting)
        }
    }
}

