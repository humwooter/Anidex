//
//  CollectionsView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI


let adaptiveColumns = [
    GridItem(.adaptive(minimum: UIScreen.main.bounds.width, maximum: UIScreen.main.bounds.width)),
    GridItem(.adaptive(minimum: UIScreen.main.bounds.width, maximum: UIScreen.main.bounds.width)),
]

enum FilterCriteria {
    case all, discovered, undiscovered, favorite, mammal, reptile, aves, amphibia
}

struct CollectionsView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    
    //Fetch Requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sighting.scientificName, ascending: true)],
        animation: .default)
    private var animal_sightings: FetchedResults<Sighting>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Species.isDiscovered, ascending: false),
                          NSSortDescriptor(keyPath: \Species.commonLabel, ascending: true),
                         ],
        animation: .default)
    private var species: FetchedResults<Species>
    
    
    @State private var selectedAnimalSighting: Sighting? = nil
    @State private var selectedSpecies: Species? = nil
    
    private var isDetailSheetPresented: Bool {
        selectedSpecies != nil
    }
    
    @State private var seenAnimals = []
    @Binding var isFullscreen: Bool

    // For Filter Criteria:
    @State private var searchText = ""
    @State private var selectedFilter: FilterCriteria = .all


    
    var filteredSpecies: [Species] {
        species.filter { animal_category in
            (searchText.isEmpty || animal_category.commonLabel?.lowercased().contains(searchText.lowercased()) ?? false) &&
            (selectedFilter == .all ||
             (selectedFilter == .discovered && animal_category.isDiscovered) ||
             (selectedFilter == .undiscovered && !animal_category.isDiscovered) ||
            (selectedFilter == .favorite && animal_category.isFavorite) ||
            (selectedFilter == .mammal && animal_category.classLabel == "Mammalia") ||
            (selectedFilter == .aves && animal_category.classLabel == "Aves") ||
            (selectedFilter == .reptile && animal_category.classLabel == "Reptilia"))


        }
    }
    
    @FocusState private var focusField: Bool
    @State private var sortEntries: Bool = false

    
    
    var body : some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "chevron.up").foregroundStyle(.green)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .padding(.vertical, 10)
                Spacer()
                
                //Main view with all of the collections cards:
                ScrollView {
                    LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                        
                        ForEach(filteredSpecies, id: \.id) { animal_category in

                            CollectionsCard(animalCategory: animal_category)
                                .environment(\.managedObjectContext, viewContext)
                                .onTapGesture {
                                    if ((animal_category.isDiscovered) != false) {
                                        selectedSpecies = animal_category
                                    }
                                }
                  
                        }
                    }.padding(.horizontal, 20)
                }

            }
            .frame(maxWidth: .infinity)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.tertiarySystemBackground))
            .cornerRadius(40)
//            .padding(.top, 30)
            .navigationTitle("Collection")
            .sheet(isPresented: Binding(
                   get: { self.isDetailSheetPresented },
                   set: { newValue in
                       if !newValue { selectedSpecies = nil }
                   }
               )) {
                   if let animalCategory = selectedSpecies {
                       CollectionsCardDetailView(animalCategory: animalCategory)
                           .environment(\.managedObjectContext, viewContext)
                   }
               }
        }
    }
}
