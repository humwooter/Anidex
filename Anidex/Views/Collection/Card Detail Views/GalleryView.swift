//
//  GalleryView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/22/24.
//

import Foundation
import SwiftUI
import CoreData

struct GalleryView: View {
    @ObservedObject var animalCategory: Species
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack {
            TabView {
                if let sightings = animalCategory.relationship as? Set<Sighting>, !sightings.isEmpty {
                    ForEach(sightings.sorted{$0.timestamp! < $1.timestamp!}, id: \.self) { sighting in
                        if let uiImage = loadImageFromSighting(sighting:sighting) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200, alignment: .center)
                                .clipped()
                                .cornerRadius(50)
                                .shadow(radius: 1)
                                .padding(.bottom, 15)
                        }
                    }
                } else {
                    Image("default")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200, alignment: .center)
                        .clipped()
                        .cornerRadius(50)
                        .shadow(radius: 1)
                        .padding(.bottom, 15)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }
    
    private func loadImageFromSighting(sighting:Sighting) -> UIImage? {
        if let filename = sighting.imageFilename, let imageData = getImageData(fromFilename: filename) {
            return UIImage(data: imageData)
        }
        return nil
    }
}
