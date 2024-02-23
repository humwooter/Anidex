//
//  CollectionsCardDetailView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI
import CoreData

struct CollectionsCardDetailView: View {
    
    @ObservedObject var animalCategory: Species
    @State private var selectedIndex = 0
    @State private var images: [UIImage] = []
    @State private var isFavorited: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.presentationMode) var presentationMode
    
    var body : some View {
        
        
        
        NavigationStack {
            ZStack {
                Color.white
                LinearGradient(gradient: Gradient(colors: [Color(animalCategory.phylumLabel ?? ""), Color(animalCategory.classLabel ?? "Mammalia")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 15) {
                    Spacer()
                    
                    GalleryView(animalCategory: animalCategory)
                        .frame(height: 255)
                    
                    
                    TabView(selection: $selectedIndex) {
      
                            StatsView(species: animalCategory)
                            .tabItem {
                                Label("About", systemImage: "pawprint.fill")
                            }.tag(0)
                        
                        Text("Stats").tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }.tag(1)
                        PhotosView(animalCategory: animalCategory)
                            .environment(\.managedObjectContext, viewContext)
                            .tabItem {
                                Label("Photos", systemImage: "photo.on.rectangle.angled")
                            }.tag(2)
                    }.accentColor(Color(animalCategory.classLabel ?? "Mammalia"))
                }
            }


            .navigationTitle("\(animalCategory.commonLabel ?? "")")

            .toolbar {
                // Back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.backward").foregroundColor(.white)
                    }
                }

                // Heart button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            animalCategory.isFavorite.toggle()
                            save(context: viewContext)
                        }
                    }) {
                        Image(systemName: animalCategory.isFavorite ? "heart.fill" : "heart").foregroundColor(.white)
                    }
                }
            }
        }
    }

}
