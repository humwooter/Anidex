//
//  CollectionsView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI


struct CollectionsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sighting.scientificName, ascending: true)],
        animation: .default)
    private var animal_sightings: FetchedResults<Sighting>
    
    
    var body : some View {
        ZStack {
            VStack {
                Image(systemName: "chevron.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .padding(.vertical, 10)
//                    .onTapGesture {
//                        withAnimation(.spring()) {
//                            isFullscreen.toggle()
//                            endingOffsetY = .zero
//                            currentDragOffsetY = .zero
//                        }
//                    }
            }
        }
    }
}
