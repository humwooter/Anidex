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
    @State private var selectedData: Data?
    @State private var selectedImage: UIImage?

    @State private var isShowingImagePicker = false
    @State private var showCreationPage = false
    @State private var showProfileView = false
    @State private var showMapView = false
    
    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    
//    @State private var animalImages: [UIImage] = [UIImage(named: "animal_\(i)") , ] //demo photo library
    @State private var animalImages: [Image] = [Image("animal_1"), Image("animal_2"), Image("animal_3"),Image("animal_4"), Image("animal_5"), Image("animal_6"), Image("animal_7")]
    
    //placeholder variables to mimic the real functionality
    @State private var cameraIsTaken = false
    @State private var cameraIsSaved = false
    @State private var showClassification = false
    @State private var showAlert = false
    @State private var isProcessing = false
    @State private var showClassificationAlert = false
    @State private var cameraIsProcessing = false

    @ObservedObject var classifierModel = ClassifierModel()
    @State private var predictions: [String] = []
    
    @State private var confidenceLabel = ""
    
 

//    init() {
//        for i in 1...7 {
//            if let image = UIImage(named: "animal_\(i)") {
//                animalImages.append(image)
//            }
//        }
//    }
    

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.black).ignoresSafeArea(.all, edges: .all)
                CameraPreviewDemo(selectedImage: $selectedImage)
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
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePickerDemoView()
  
//            ImagePicker(selectedImage: self.$selectedImage, sourceType: .photoLibrary)
        }
        .alert("Classification Result", isPresented: $showClassificationAlert) {
            Button("Save", role: .cancel) {
                showAlert = false
                showCreationPage = true
            }
            Button("Dismiss", role: .destructive) {
                showAlert = false
            }
        } message: {
            Text("Prediction: \(predictions.count > 0 ? predictions.last! : "") \nConfidence: \(self.confidenceLabel)")
                .foregroundColor(.green)
            
        }
        .sheet(isPresented: $showProfileView) {
            SettingsView()
                .environmentObject(userPreferences)
        }
        .sheet(isPresented: $showCreationPage) {
            if let image = selectedImage {
                newAnimalSightingViewDemo(showCreationPage: showCreationPage, predictionLabels: self.predictions, selectedImage: image).accentColor(.green)
                // Your code for newAnimalSightingView
            }
        }
    }

    
    @ViewBuilder
    func buttonBar_vertical() -> some View {
        VStack {
            
            if !cameraIsTaken {
                
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
                            self.selectedData = nil
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
                            cameraIsTaken = false
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
                    
                    if cameraIsTaken {
                        VStack {
                            if isProcessing {
                                ProgressView().progressViewStyle(.circular).padding(15)
                            } else {
                                Text(predictions.count  > 0 ?  predictions[4] : "No name")
                                    .font(.footnote)
                                    .padding(15)
                                    .background(Capsule().fill(Color.white.opacity(0.8)).overlay(Capsule().stroke(colorForConfidence(confidenceString: self.confidenceLabel), lineWidth: 3)))
                                
                                    .foregroundColor(colorForConfidence(confidenceString: self.confidenceLabel))
                                    .padding(.horizontal, 5)
                                    .contextMenu {
                                        Button(action: {
                                            UIPasteboard.general.string = predictions[6]
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
    
    func parseLabel(label: String) {
        let components = label.split(separator: "_").map(String.init)
        if components.count >= 7 {
//            let kingdomName = components[0]

            let phylumName = components[1]
            let className = components[2]
            let familyName = components[4]
            let scientificName = "\(components[5]) \(components[6])"
            let commonName = components.dropFirst(7).joined(separator: " ")
            
            self.predictions = [phylumName, className, familyName, scientificName, commonName]
            print("self.predictions: \(self.predictions)")
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
                                        self.selectedData = nil
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

    func processImageData(_ imageData: Data) {
        print("ENTERED PROCESS IMAGE DATA")
        print("IMAGE DATA \(imageData)")
        self.selectedData = imageData
        if let uiImage = UIImage(data: imageData) {
            Task {
                await self.classifierModel.classifyForDemo(image: uiImage) {
                    self.isProcessing = false
                    print("Prediction: \(self.classifierModel.predictionLabel)")
                    parseLabel(label: self.classifierModel.predictionLabel)
                    self.confidenceLabel = self.classifierModel.confidenceLabel
                    self.showClassificationAlert = true
                    self.cameraIsTaken = true

                }
            }
        }
    }
    
    @ViewBuilder
    func ImagePickerDemoView() -> some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(1...7, id: \.self) { index in
                        Image("animal_\(index)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
//                            .cornerRadius(70)
                            .onTapGesture {
                                
                                selectedData  = nil
                                selectedImage = nil
                                if let imageData =  UIImage(named: "animal_\(index)")?.pngData() {
                                    print("IT WORKED!")
                                    selectedData = imageData
                                    
                                    processImageData(imageData)
                                    if let image = UIImage(named: "animal_\(index)"){
                                        selectedImage = image
                                        isShowingImagePicker = false
                                    }
                                }
                                
                            }
                    }
                }
            }
            .navigationTitle("Image Library Demo")
        }
    }
//    private mutating func loadImages() {
//        for i in 1...7 {
//            if let image = UIImage(named: "animal_\(i)") {
//                animalImages.append(image)
//            }
//        }
//    }
}

