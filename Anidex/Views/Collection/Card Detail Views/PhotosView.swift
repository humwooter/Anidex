//
//  PhotosView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/22/24.
//

import Foundation
import SwiftUI
import CoreData

struct PhotosView: View {
    @ObservedObject var animalCategory: Species
     @State private var isPresentingDeleteConfirm: Bool = false
     @State private var isPresentingEdit: Bool = false
     @State private var selectedSighting: Sighting?
     @State private var newName = ""
     @Environment(\.managedObjectContext) private var viewContext

     private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 15), count: 2)

     var body: some View {
         VStack {
             if let sightings = animalCategory.relationship as? Set<Sighting>, !sightings.isEmpty {
                 ScrollView {
                     LazyVGrid(columns: columns, spacing: 15) {
                         ForEach(sightings.sorted { $0.timestamp! < $1.timestamp! }, id: \.self) { sighting in
                             if let image = getImageFromSighting(sighting: sighting) {
                                 ZStack(alignment: .bottomTrailing) {
                                     Image(uiImage: image)
                                         .resizable()
                                         .scaledToFill()
                                         .frame(width: 150, height: 150)
                                         .clipped()
                                         .cornerRadius(10)
                                     Text(sighting.name ?? "")
                                         .font(.caption)
                                         .padding(6)
                                         .background(Color.black.opacity(0.7))
                                         .cornerRadius(10)
                                         .foregroundColor(.white)
                                         .padding(4)
                                 }.contextMenu(ContextMenu {
                                     Button {
                                         // Actions
                                     } label: {
                                         Label("Show in Maps", systemImage: "mappin")
                                     }
                                     Button {
                                         isPresentingEdit = true
                                         selectedSighting = sighting
                                         newName = sighting.name ?? ""
                                     } label: {
                                         Label("Edit Name", systemImage: "pencil")
                                     }
                                     Button(role: .destructive) {
                                         isPresentingDeleteConfirm = true
                                         selectedSighting = sighting
                                     } label: {
                                         Label("Delete", systemImage: "trash")
                                     }
                                 })
                                 .alert("Are you sure you want to delete this photo?",
                                        isPresented: $isPresentingDeleteConfirm) {
                                     Button("Cancel", role: .cancel) { isPresentingDeleteConfirm = false }
                                     Button("Delete", role: .destructive) {
                                         if let sighting = selectedSighting {
                                             deleteImageFromSighting(sighting: sighting)
                                             isPresentingDeleteConfirm = false
                                         }
                                     }
                                 } message: {
                                     Text("Deleted photos and associated location data cannot be recovered.")
                                 }
                                 .alert("Edit Name",
                                        isPresented: $isPresentingEdit) {
                                     TextField("Name", text: $newName)
                                     Button("Cancel", role: .cancel) { isPresentingEdit = false }
                                     Button("Save") {
                                         if let sighting = selectedSighting {
                                             editImageFromSighting(sighting: sighting, newName: newName)
                                             isPresentingEdit = false
                                         }
                                     }
                                 }
                             }
                         }
                     }
                     .padding([.horizontal, .bottom])
                     .padding(.top, 20)
                 }
             } else {
                 Text("No images available")
             }
         }
     }
    

    private func getImageFromSighting(sighting: Sighting) -> UIImage? {
        if let filename = sighting.imageFilename, let imageData = getImageData(fromFilename: filename), let image = UIImage(data: imageData) {
            return image
        } else {
            print("could not load image \(sighting.name ?? ""):")
            return nil
        }
    }
    
    private func deleteImageFromSighting(sighting: Sighting){
        animalCategory.removeFromRelationship(sighting)
        viewContext.delete(sighting)
        do {
            try viewContext.save()
        } catch {
            print("could not delete image: ", error)
        }
    }
    
    private func editImageFromSighting(sighting: Sighting, newName: String){
        sighting.name = newName
        do {
            try viewContext.save()
        } catch {
            print("could not change name: ", error)
        }
    }
}
