//
//  MapView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/24/24.
//

import Foundation
import MapKit
import SwiftUI

struct MapAnnotationItem: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let filename: String
    let index: Int
}

struct MapView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showMapView: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var locationManager: LocationManager
    
    @FetchRequest(entity: Sighting.entity(), sortDescriptors: []) var animalSightings: FetchedResults<Sighting>
    
    var annotations: [MapAnnotationItem] {
        animalSightings.enumerated().map { index, entry in
            MapAnnotationItem(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: entry.lattitude, longitude: entry.longitude), filename: entry.imageFilename ?? "", index: index)
        }
    }
    
    var body: some View {
        ZStack {
            
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: annotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    CustomAnnotationView(filename: item.filename)
                        .offset(offsetForAnnotation(at: item.index))
                    
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        DispatchQueue.main.async {
                            showMapView = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.green)
                            .padding(20)
                    })
                }
                Spacer()
            }
        }
    }
    func offsetForAnnotation(at index: Int) -> CGSize {
        let radius: CGFloat = 20.0
        // calculating angle to spread each annotation equally in a circle
        let angle = (Double(index) * (360.0 / Double(annotations.count))) * (Double.pi / 180)
        let xOffset = cos(angle) * radius
        let yOffset = sin(angle) * radius
        return CGSize(width: xOffset, height: yOffset)
    }
    
}


struct CustomAnnotationView: View {
    let filename: String

    var body: some View {
        if !filename.isEmpty {
            CustomAsyncImageView(url: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(filename))
                .scaledToFit()
                .frame(width: 30, height: 30) 
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
    }
       
}
