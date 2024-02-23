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
    
    var body : some View {
        NavigationStack {
            List {
                animalSightingImage()
                
                Section(header: Text("Name")) {
                    TextField("Name your sighting:", text: $newSightingName)
                        .onTapGesture {
                            focusField = true
                        }
                        .focused($focusField)

                }
                Section(header: Text("Notes")) {
                    GrowingTextField(text: $newSightingNotes, fontSize: UIFont.systemFontSize, fontColor: UIColor(Color(UIColor.label)), cursorColor: UIColor(Color(predictionLabels[0])), initialText: "Add notes about your sighting...")
                        .frame(maxHeight: 300)
                }
//                    .scaledToFit()
            }
            .navigationTitle(predictionLabels.count > 3 ? "New \(predictionLabels[4]) found" : "New \(predictionLabels[3]) found")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                },
                trailing: Button("Save") {
                    createNewSighting()

                    // TODO: create new photo entry here
                    showCreationPage = false
                }
            )
        }
    }
    
    @ViewBuilder
    func animalSightingImage() -> some View {
            VStack {
                HStack {
                    Spacer()

                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())

                    Spacer()
                }
            }.frame(maxHeight: 300)
//            .border(LinearGradient(gradient: Gradient(colors: [Color(predictionLabels[0] ?? ""), Color(predictionLabels[1] ?? "Mammalia")]), startPoint: .top, endPoint: .bottom), width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
        .background {
            LinearGradient(gradient: Gradient(colors: [Color(predictionLabels[0] ?? "Mammalia"), Color(predictionLabels[1] ?? "Mammalia")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        }
        .clipShape(Circle()).padding(40)

    }
    
    private func createNewSighting() {
        let newSighting = Sighting(context: viewContext)
        newSighting.id = UUID()
        newSighting.timestamp = Date()
        newSighting.scientificName = predictionLabels[3]
        newSighting.name = newSightingName
        newSighting.imageFilename = saveImageToDocumentsDirectory(image: selectedImage)
        newSighting.notes = newSightingNotes
        

//        Task {
//            locationManager.requestLocation()
//
//        }
////        newSighting.lattitude = locationManager.location?.latitude ?? 0
//        newSighting.longitude = locationManager.location?.longitude ?? 0
        

        
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
