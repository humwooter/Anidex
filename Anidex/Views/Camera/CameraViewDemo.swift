//
//  CameraViewDemo.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/24/24.
//

import Foundation
import SwiftUI
import UIKit

struct CameraViewDemo: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var showCreationPage = false
    @State private var showProfileView = false
    @State private var showMapView = false
    
    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    
    
    
    //placeholder variables to mimic the real functionality
    @State private var cameraIsTaken = false
    @State private var cameraIsSaved = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.black).ignoresSafeArea(.all, edges: .all)
                    .overlay {
                        VStack {
                            VStack {
                                ForEach(0..<7) {_ in
                                    Spacer()
                                }
                                
                                buttonBar_horizontal().padding(.bottom, 150)
                            }
                        }
                    }
                
                    buttonBar_vertical().padding(.top, 40)

//                if showMapView {
//                    MapView(showMapView: $showMapView) // Your custom MapView
//                        .transition(.move(edge: .leading))
//                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
            ImagePicker(selectedImage: self.$selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showProfileView) {
            SettingsView()
                .environmentObject(userPreferences)
        }
        .sheet(isPresented: $showCreationPage) {
            if let image = selectedImage {
                // Your code for newAnimalSightingView
            }
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        guard let _ = selectedImage.jpegData(compressionQuality: 1.0) else { return }
        // Process the image data if needed
    }
    
    @ViewBuilder
    func buttonBar_vertical() -> some View {
        VStack {
            
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        
                        Button {
                                withAnimation {
                                    vibration_medium.impactOccurred()
                                }
                            
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill" )
                                .foregroundColor(.white)
                                .padding(15)
                                .frame(width: 50, height: 50)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }.shadow(radius:2)
                        
                        Button(action: {
                        }, label: {
                            Image(systemName: "bolt.fill" )
                                .foregroundColor(.white)
                                .padding(15)
                                .frame(width: 50, height: 50)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }).shadow(radius:2)
                        
                        
                        Button(action: {
                            self.isShowingImagePicker = true
                            self.selectedImage = nil
                        }, label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.white)
                                .padding(15)
                                .frame(width: 50, height: 50)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }).shadow(radius:2)
                        Spacer()
                    }.padding(.trailing, 15)
                }
        }
    }

    @ViewBuilder
    func buttonBar_horizontal() -> some View {
        HStack(spacing: 25) {
            
            if cameraIsTaken {
                Button(action: {
                    vibration_medium.prepare()
                    vibration_medium.impactOccurred()
                    
                }, label: {
                    Image(systemName: cameraIsSaved ? "arrow.down.square.fill" : "arrow.down.square")
                        .foregroundColor(.white)
                        .padding(15)
                        .padding(.horizontal, 5)
                        .background(cameraIsSaved ? .green : .white.opacity(0.3))
                        .clipShape(Circle())
                }).padding(.leading, 25)
                Spacer()
            }
            
            else {
                Button(action: {
//                    selectedImage = UIImage(data: camera.originalData)
                }, label: {
                    VStack {
                        ZStack {
                            HStack(spacing: 30) {
                                
                                Button(action: {
                                    withAnimation {
                                        showMapView = true
                                    }
                                }) {
                                    Image(systemName: "map") // Map icon
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                    
                                }
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 7)
                                    .frame(width: 65, height: 65)
                                    .shadow(radius: 2)
                                    .onTapGesture {
                                        cameraIsTaken.toggle()
                                    }
                                
                                
                                    Button(action: {
                                        self.isShowingImagePicker = true
                                        self.selectedImage = nil
                                    }, label: {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .foregroundColor(.white)
                                            .frame(width: 50, height: 50)
                                        
                                    }).shadow(radius:2)
                                }
                            }
                        }
                })
            }
    
        }
    }
}
