//
//  CameraView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit


struct CameraView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var camera: CameraModel
    @State private var selectedImage: UIImage?
    
    @State private var isShowingImagePicker = false
    
    @State private var showAlert = false
    @State private var showCreationPage = false
    @State private var showProfileView = false
    @State private var showMapView = false
    
    
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var coreDataManager: CoreDataManager

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.black).ignoresSafeArea(.all, edges: .all)
                CameraPreview(camera: camera, selectedImage: $selectedImage)
                    .ignoresSafeArea(.all, edges: .all)
                    .gesture(
                        DragGesture(minimumDistance: 50, coordinateSpace: .local)
                            .onEnded { value in
                                let horizontalMovement = value.translation.width
                                let verticalMovement = value.translation.height
                                
                                // check for mostly horizontal movement
                                if abs(horizontalMovement) > abs(verticalMovement) {
                                    // right swipe
                                    if horizontalMovement > 0 {
                                        showMapView = true
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        if (!camera.isTaken) {
                            camera.toggleCamera()
                        }
                    }
                    .overlay {
                        VStack {
                            ForEach(0..<7) {_ in
                                Spacer()
                            }
                            buttonBar_horizontal()
                            Spacer()
                        }
                    }
                buttonBar_vertical().padding(.top, 40)

                if showMapView {
                    MapView(showMapView: $showMapView)
                        .transition(.move(edge: .leading))
                }
            }

        }
        .onAppear(perform: {
            camera.checkPermissions()
            if !userPreferences.hasCameraAccess {
                userPreferences.hasCameraAccess = true
            }
        })
        .alert(isPresented: $camera.showAlert) {
            Alert(title: Text("Permission Denied"),
                  message: Text("Please enable camera access in settings."),
                  dismissButton: .default(Text("OK")))
        }
        .alert("Classification Result", isPresented: $camera.showClassificationAlert) {
            Button("Save", role: .cancel) {
                showAlert = false
                showCreationPage = true
            }
            Button("Dismiss", role: .destructive) {
                showAlert = false
            }
        } message: {
            Text("Prediction: \(!camera.classifierModel.commonName.isEmpty ? camera.classifierModel.commonName : camera.classifierModel.scientificName) \nConfidence: \(camera.classifierModel.confidenceLabel)")
                .foregroundColor(.green)
            
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
                newAnimalSightingView(showCreationPage: showCreationPage, predictionLabels:[camera.classifierModel.phylumName, camera.classifierModel.className, camera.classifierModel.familyName, camera.classifierModel.scientificName, camera.classifierModel.commonName], selectedImage: image).accentColor(.green)
                    .environmentObject(locationManager)
            }
            if selectedImage == nil, let image = UIImage(data: camera.originalData) {
                newAnimalSightingView(showCreationPage: showCreationPage, predictionLabels:[camera.classifierModel.phylumName, camera.classifierModel.className, camera.classifierModel.familyName, camera.classifierModel.scientificName, camera.classifierModel.commonName], selectedImage: image).accentColor(.green)
                    .environmentObject(locationManager)
            }
            
        }
    }
    
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        guard let imageData = selectedImage.jpegData(compressionQuality: 1.0) else { return }
        camera.processImageData(imageData, shouldClassify: true)
        camera.isTaken = true
    }
    
    @ViewBuilder
    func buttonBar_top() -> some View {
        HStack {
            VStack {
                Button {
                    showProfileView = true
                } label: {
                    Image(systemName:  "person.crop.circle")
                        .foregroundColor(.white)
                        .padding(15)
                        .frame(width: 50, height: 50)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }.shadow(radius:2)
                Spacer()
            }
            Spacer()
            buttonBar_vertical()
        }
        
        .padding(.trailing, 10)
        .padding(.leading, 25)
        .padding(.top, 40)
    }
    
    
    @ViewBuilder
    func buttonBar_vertical() -> some View {
        VStack {
            
            if !camera.isTaken {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        
                        Button {
                            if camera.isCameraAvailable(camera.currentCameraPosition == .front ? .front : .back) {
                                withAnimation {
                                    vibration_medium.impactOccurred()
                                    camera.toggleCamera()
                                }
                            }
                            
                        } label: {
                            Image(systemName: camera.currentCameraPosition == .front ? "arrow.triangle.2.circlepath.camera.fill" : "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.white)
                                .padding(15)
                                .frame(width: 50, height: 50)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }.shadow(radius:2)
                        
                        Button(action: {
                            camera.toggleFlash()
                        }, label: {
                            Image(systemName: camera.flashMode == .on ? "bolt.fill" : "bolt.slash.fill")
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
            
            
            else {
                HStack(spacing: 10) {
                    VStack {
                        Button(action: {
                            vibration_light.prepare()
                            vibration_light.impactOccurred()
                            camera.retakePic()
                        }, label: {
                            
                            Image(systemName: "arrowshape.backward.fill")
                                .foregroundColor(.white)
                                .padding(15)
                                .padding(.horizontal, 5)
                                .background(.white.opacity(0.3))
                                .clipShape(Circle())
                            
                        }).shadow(radius:2)
                        
                        
                        Spacer()
                    }
                    Spacer()
                    if camera.isTaken {
                        VStack {
                            if camera.isProcessing {
                                ProgressView().progressViewStyle(.circular).padding(15)
                            } else {
                                Text(!camera.classifierModel.commonName.isEmpty ? camera.classifierModel.commonName : camera.classifierModel.scientificName)
                                    .font(.footnote)
                                    .padding(15)
                                    .background(Capsule().fill(Color.white.opacity(0.8)).overlay(Capsule().stroke(colorForConfidence(confidenceString: camera.classifierModel.confidenceLabel), lineWidth: 3)))
                                
                                    .foregroundColor(colorForConfidence(confidenceString: camera.classifierModel.confidenceLabel))
                                    .padding(.horizontal, 5)
                                    .contextMenu {
                                        Button(action: {
                                            UIPasteboard.general.string = !camera.classifierModel.commonName.isEmpty ? camera.classifierModel.commonName : camera.classifierModel.scientificName
                                        }) {
                                            Text("Copy Message")
                                            Image(systemName: "doc.on.doc")
                                        }
                                    }
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.trailing, 10)
                .padding(.leading, 25)
            }
        }
    }
    
    
    @ViewBuilder
    func buttonBar_horizontal() -> some View {
        HStack(spacing: 25) {
            
            if camera.isTaken {
                Button(action: {
                    vibration_medium.prepare()
                    vibration_medium.impactOccurred()
                    camera.savePic()
                    
                }, label: {
                    Image(systemName: camera.isSaved ? "arrow.down.square.fill" : "arrow.down.square")
                        .foregroundColor(.white)
                        .padding(15)
                        .padding(.horizontal, 5)
                        .background(camera.isSaved ? .green : .white.opacity(0.3))
                        .clipShape(Circle())
                }).padding(.leading, 25)
                Spacer()
            }
            else {
                Button(action: {
                    camera.takePic()
                    selectedImage = UIImage(data: camera.originalData)
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
                                
                                
                                if !camera.isTaken {
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
                    }
                })
            }
        }
    }
}





