//
//  CollectionsView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI


let adaptiveColumns = [
    GridItem(.adaptive(minimum: UIScreen.main.bounds.width * 0.45, maximum: UIScreen.main.bounds.width * 0.45), spacing: 20),
    GridItem(.adaptive(minimum: UIScreen.main.bounds.width * 0.45, maximum: UIScreen.main.bounds.width * 0.45), spacing: 20)
]


enum FilterCriteria {
    case all, discovered, undiscovered, favorite, mammal, reptile, aves, amphibia
}


struct CollectionsParentView: View {
    @Binding var isFullscreen: Bool
    @StateObject private var searchModel = SearchModel()
    @FocusState private var isSearchFieldFocused: Bool

    
    var body : some View {
        CollectionsView(isFullscreen: $isFullscreen, searchModel: searchModel)
            .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens) { token in
                        switch token {
                        case .discovered:
                            Text("Discovered")
                        case .undiscovered:
                            Text("Undiscovered")
                        case .favoriteFindings:
                            Text("Favorites")
                        case .mammalFindings:
                            Text("Mammals")
                        case .avesFindings:
                            Text("Aves")
                        case .amphibiaFindings:
                            Text("Amphibia")
                        case .reptiliaFindings:
                            Text("Reptilia")
                        }
                
            }.accentColor(.green)
            .focused($isSearchFieldFocused)
            .onChange(of: isFullscreen) { newValue in
                          if !newValue {
                              isSearchFieldFocused = false
                          }
                      }

    }
    
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

    
    @Environment(\.isSearching) private var isSearching
    @ObservedObject var searchModel: SearchModel


    
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
                header()
                NavigationStack {
                    List {
                        if isSearching {
                            suggestedSearchView()
                        }
                        
                        //Main view with all of the collections cards:
                        ScrollView {
                            LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                                
                                ForEach(filteredSpecies(animalCategories: Array(species), searchText: searchModel.searchText, selectedFilters: searchModel.tokens), id: \.id) { animal_category in
                                    
                                    CollectionsCard(animalCategory: animal_category)
                                        .environment(\.managedObjectContext, viewContext)
                                        .onTapGesture {
                                            if ((animal_category.isDiscovered) != false) {
                                                selectedSpecies = animal_category
                                            }
                                        }
                                    
                                }
                            }
                        }
                    }
                }

            }
            .frame(maxWidth: .infinity)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.tertiarySystemBackground))
            .cornerRadius(40)
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
    
    func filteredSpecies(animalCategories: [Species], searchText: String, selectedFilters: [FilterTokens]) -> [Species] {
        return animalCategories.filter { animalCategory in
            let matchesSearchText = searchText.isEmpty || animalCategory.scientificLabel?.lowercased().contains(searchText.lowercased()) ?? false

            let matchesFilter: Bool
            if selectedFilters.isEmpty {
                matchesFilter = true // If no filters, consider it a match.
            } else {
                matchesFilter = selectedFilters.contains { filter in
                    switch filter {
                    case .discovered:
                        return animalCategory.isDiscovered
                    case .undiscovered:
                        return !animalCategory.isDiscovered
                    case .favoriteFindings:
                        return animalCategory.isFavorite
                    case .mammalFindings:
                        return animalCategory.classLabel == "Mammalia"
                    case .avesFindings:
                        return animalCategory.classLabel == "Aves"
                    case .amphibiaFindings:
                        return animalCategory.classLabel == "Amphibia"
                    case .reptiliaFindings:
                        return animalCategory.classLabel == "Reptilia"
                    }
                }
            }

            return matchesSearchText && matchesFilter
        }
    }



    
    @ViewBuilder
    func suggestedSearchView() -> some View {
        if searchModel.tokens.isEmpty && searchModel.searchText.isEmpty { //present possible tokens
            
            Section(header: Text("Suggested")) {
                Button {
                    searchModel.tokens.append(.favoriteFindings)
                } label: {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.pink)
                            .padding(.horizontal, 5)
                        Text("Favorite Sightings")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                Button {
                    searchModel.tokens.append(.discovered)
                } label: {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundStyle(Color.yellow)
                            .padding(.horizontal, 5)
                        Text("Discovered")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }

                Button {
                    searchModel.tokens.append(.mammalFindings)
                } label: {
                    HStack {
                        Image(systemName: "hare.fill")
                            .foregroundStyle(Color("Mammalia"))
                            .padding(.horizontal, 5)

                        Text("Mammal Sightings")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                Button {
                    searchModel.tokens.append(.avesFindings)
                } label: {
                    HStack {
                        Image(systemName: "bird.fill")
                            .foregroundStyle(Color("Aves"))
                            .padding(.horizontal, 5)

                        Text("Bird Findings")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                Button {
                    searchModel.tokens.append(.amphibiaFindings)
                } label: {
                    HStack {
                        Image(systemName: "lizard.fill")
                            .foregroundStyle(Color("Amphibia"))
                            .padding(.horizontal, 5)

                        Text("Amphibia Findings")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                Button {
                    searchModel.tokens.append(.reptiliaFindings)
                } label: {
                    HStack {
                        Image(systemName: "tortoise.fill")
                            .foregroundStyle(Color("Reptilia"))
                            .padding(.horizontal, 5)

                        Text("Reptile Findings")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack {
            Spacer()
            Menu {
                Menu {
                    Button("Discovered", action: { searchModel.tokens.append(.discovered)})
                    Button("Undiscovered", action: { searchModel.tokens.append(.undiscovered)})
                    Button("Favorites", action: { searchModel.tokens.append(.favoriteFindings)})
                    ControlGroup("Filter by class") {
                              Button("Mammals", action: { searchModel.tokens.append(.mammalFindings)})
                              Button("Reptiles", action: { searchModel.tokens.append(.reptiliaFindings)})
                              Button("Birds (Aves)", action: { searchModel.tokens.append(.avesFindings)})
                              Button("Amphibians", action: { searchModel.tokens.append(.amphibiaFindings)})
                    }
                } label: {
                    Text("Filter")
                }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }

           

        }.padding(.horizontal, 30)
            .foregroundStyle(.green)
    }
}
