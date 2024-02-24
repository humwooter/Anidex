//
//  CollectionsCard.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI
import CoreData


struct CollectionsCard: View {
    
    @ObservedObject var animalCategory: Species
    @Environment(\.colorScheme) var colorScheme

    var maxRowHeight : CGFloat = 200
    var imageLength: CGFloat = 100
    @State private var isFavorite: Bool = false
    @State private var images: [UIImage] = []
    
    @State private var firstAnimalSighting: Sighting?
    @Environment(\.managedObjectContext) private var viewContext
    
    var body : some View {
        VStack(spacing: 5) {
            animalImages()
            
        }.padding(.top, 15)
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            animalCategory.isFavorite.toggle()
                            save(context: viewContext)
                        }) {
                            Image(systemName: animalCategory.isFavorite ? "heart.fill" : "heart").foregroundColor(.white).padding()
                        }
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: maxRowHeight, maxHeight: maxRowHeight)
            .padding(.vertical, 5)
            .padding(.horizontal,5)
            .background(content: {
                ZStack {
                    if animalCategory.isDiscovered {
                        Color.white
                        LinearGradient(gradient: Gradient(colors: [Color("Chordata"), Color(animalCategory.classLabel ?? "Mammalia")]), startPoint: .top, endPoint: .bottom)
                    } else {
                        Color(UIColor.systemFill)
                    }
                }
                .edgesIgnoringSafeArea(.all)

                
            })
            .cornerRadius(15)
//            .padding(.horizontal, 5)
            .padding(.top, 10)
            .onAppear {
                if let relationshipSet = animalCategory.relationship as? Set<Sighting>, relationshipSet.count > 0 {
                    firstAnimalSighting = relationshipSet.first
                }
            }
      
        
    }
    
    @ViewBuilder
    func animalImages() -> some View {
        if let relationshipSet = animalCategory.relationship as? Set<Sighting>, relationshipSet.count > 0, let firstAnimal = relationshipSet.sorted(by: {$0.timestamp! < $1.timestamp!}).first {
            if let imageFile = firstAnimal.imageFilename, !imageFile.isEmpty {
                CustomAsyncImageView(url: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(imageFile))
                    .scaledToFill()
                    .frame(width: imageLength, height: imageLength, alignment: .center)
                    .clipped()
                    .cornerRadius(25)
                    .padding(.horizontal, 5)
                
            }

        }
        else {
            if animalCategory.isDiscovered {
                Image("default")
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .cornerRadius(25)
                    .padding(.horizontal, 5)
            }
            else {
                Image("undiscovered")
                    .resizable()
                    .scaledToFit()
                
                    .clipped()
                    .cornerRadius(25)
                    .padding(.horizontal, 5)
                    .onAppear {
                        print("UNDISCOVERD")
                    }
            }
        }
        
        VStack {
            HStack {
                Text("\(animalCategory.commonLabel ?? "Unnamed animal")").font(.title)
                
                Spacer()
            }
            HStack {
                Text(animalCategory.scientificLabel ?? "").font(.caption).opacity(0.5)
                    .padding(.bottom, 2)
                Spacer()
            }
        }.padding(.leading, 10)
    }
}
