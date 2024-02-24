//
//  newAnimalSightingView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/22/24.
//

import Foundation
import SwiftUI
import CoreData


struct newAnimalSightingView: View {
    @State var showCreationPage: Bool
    @State var predictionLabels: [String]
    @State private var newSightingName: String = ""
    @State private var newSightingScientificName: String = ""
    
    @State var selectedImage: UIImage
    @State var newSightingNotes: String = ""

    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var focusField: Bool
    @EnvironmentObject var locationManager: LocationManager

    var body : some View {
        NavigationStack {
            VStack {

                animalSightingImage()
                
                Section {
                    GrowingTextField(text: $newSightingName, fontSize: UIFont.systemFontSize,  fontColor: UIColor.foregroundColor(background: UIColor(Color(predictionLabels[0] ?? "Mammalia"))), cursorColor: UIColor(.green)).cornerRadius(15).frame(maxHeight: 50)
                } header: {
                    HStack {
                        Text("Name your sighting:").padding(.horizontal).font(.caption)
                        Spacer()
                    }
                }.padding(.horizontal).padding(.vertical, 2)

                Section {
                    GrowingTextField(text: $newSightingNotes, fontSize: UIFont.systemFontSize, fontColor: UIColor.foregroundColor(background: UIColor(Color(predictionLabels[0] ?? "Mammalia"))), cursorColor: UIColor(.green), initialText: "Add notes about your sighting...").cornerRadius(15)
                } header: {
                    HStack {
                        Text("Add notes:").padding(.horizontal).font(.caption)
                        Spacer()
                    }
                }.padding(.horizontal).padding(.vertical, 2)
                
            }
//            .foregroundStyle(Color( UIColor.foregroundColor(background: UIColor(Color(predictionLabels[0] ?? "Mammalia")))))
            .navigationTitle(predictionLabels.count > 3 ? "New \(predictionLabels[4]) found" : "New \(predictionLabels[3]) found")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                },
                trailing: Button("Save") {
                    createNewSighting()

                    showCreationPage = false
                }
            )
            .background {
                LinearGradient(gradient: Gradient(colors: [Color(predictionLabels[0] ?? "Mammalia"), Color(predictionLabels[1] ?? "Mammalia")]), startPoint: .top, endPoint: .bottom).ignoresSafeArea(.all)
            }
        }
        

     
    }
    @ViewBuilder
    func animalSightingImage() -> some View {
            VStack {
                HStack {
                    Spacer()

                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())

                    Spacer()
                }
            }.frame(maxHeight: 300)


    }
    
    private func createNewSighting() {
        let newSighting = Sighting(context: viewContext)
        newSighting.id = UUID()
        newSighting.timestamp = Date()
        newSighting.scientificName = predictionLabels[3]
        newSighting.name = newSightingName
        newSighting.imageFilename = saveImageToDocumentsDirectory(image: selectedImage)
        newSighting.notes = newSightingNotes
        

        Task {
            locationManager.requestLocation()

        }
        newSighting.lattitude = locationManager.location?.latitude ?? 0
        newSighting.longitude = locationManager.location?.longitude ?? 0
        
        print("lattitude: \(newSighting.lattitude )")
        print("longitude: \(newSighting.longitude )")

        

        
        // Fetch the log with the appropriate day
        let species = fetchSpeciesCategory(withScientificName: predictionLabels[3], context: viewContext)

        
        do {
            if let animal_category = species.first {
                animal_category.isDiscovered = true

                animal_category.addToRelationship(newSighting)
                newSighting.relationship = animal_category

            } else {
                // Create a new species
                let newSpecies = Species(context: viewContext)
                newSpecies.id = UUID()
                newSpecies.isDiscovered = true
                
                newSpecies.addToRelationship(newSighting)
                newSighting.relationship = newSpecies
                
                
                newSpecies.phylumLabel = predictionLabels[0]
                newSpecies.classLabel = predictionLabels[1]
                newSpecies.familyLabel = predictionLabels[2]
                newSpecies.scientificLabel = predictionLabels[3]
                newSpecies.commonLabel = predictionLabels[4] //common name
                newSpecies.isFavorite = false
            }
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()

        } catch {
            print("Failed to save new Pokedex entry: \(error)")
        }
    }
}
