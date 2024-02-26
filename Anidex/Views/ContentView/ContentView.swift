//
//  ContentView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/20/24.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var camera = CameraModel()
    @State private var panelHeight: CGFloat = 100 
    @State var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.85
    
    @State var currentDragOffsetY: CGFloat = .zero
    @State var endingOffsetY: CGFloat = .zero
    @State private var isFullscreen = false
    @State var inCameraMode: Bool = true;
    @Environment(\.scenePhase) var scenePhase
    
    @State private var endOffset:CGFloat = 0
    @ObservedObject private var userPreferences = UserPreferences()
    @ObservedObject private var locationManager = LocationManager()
    
    private var coreDataManager = CoreDataManager(persistenceController: PersistenceController.shared)

    
    
    var body : some View {
        VStack {
            GeometryReader { geometry in
                let totalHeight = geometry.size.height
                let safeAreaBottom = geometry.safeAreaInsets.bottom
                
                
                let startingOffsetY = 0.87 * totalHeight
                let computedOffset = endingOffsetY + startingOffsetY + currentDragOffsetY
                
                
                ZStack {
                    Color(.black).ignoresSafeArea(.all, edges: .all)
                    
                    
                    CameraView(camera: camera)
                        .environmentObject(coreDataManager)
                        .environmentObject(userPreferences)
                        .environmentObject(locationManager)
                    
                    
                    
                    CollectionsParentView(isFullscreen: $isFullscreen).cornerRadius(40)
                        .environmentObject(coreDataManager)
                        .offset(y: isFullscreen ? 0 : getCollectionsViewOffset(startingOffsetY: startingOffsetY + safeAreaBottom))
                        .frame(height: isFullscreen ? totalHeight : nil) 
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.spring()) {
                                        currentDragOffsetY = value.translation.height
                                    }
                                }
                                .onEnded { value in
                                    if ((inCameraMode == true) && (currentDragOffsetY <= -150)) {
                                        setCameraState(cameraMode: false)
                                    } else if ((inCameraMode == false) && (currentDragOffsetY >= 150)) {
                                        setCameraState(cameraMode: true)
                                    } else {
                                        setCameraState(cameraMode: inCameraMode)
                                    }
                                }
                        )
                    
                }
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: scenePhase) { newPhase in
                    if ((newPhase != .active) && (newPhase != .inactive)) {
                        setCameraState(cameraMode: true)
                    }
                }
            }
            
        }.accentColor(.green)
            .onAppear {
                if !userPreferences.hasInitializedSpecies {
                    initializeSpecies()
                    userPreferences.hasInitializedSpecies = true
                }
            }
    }
    
    private func setCameraState(cameraMode: Bool) {
        withAnimation(.spring()) {
            inCameraMode = cameraMode
            if (cameraMode) {
                endingOffsetY = .zero
                
            } else {
                endingOffsetY = -startingOffsetY
            }
            currentDragOffsetY = .zero
        }
    }
    
    private func initializeSpecies() {
        let input_labels = "AnimalLabels"
        
        if let path = Bundle.main.path(forResource: input_labels, ofType: "txt") {
               do {
                   let data = try String(contentsOfFile: path, encoding: .utf8)
                   let labels = data.components(separatedBy: .newlines)
                   for label in labels {
                       if !label.isEmpty {
                           let newSpecies = Species(context: viewContext)
                           
                           let components = label.components(separatedBy: " ")
                           if components.count == 2 {
                               newSpecies.id = UUID()
                               newSpecies.commonLabel = components[0]
                               newSpecies.classLabel = components[1]
                               newSpecies.isDiscovered = false
                               
                               do {
                                   try viewContext.save()
                               } catch {
                                   print("Failed to save new Species entry: \(error)")
                               }
                           }
                       }
                   }
                   
               } catch {
                   print(error)
               }
           }
       }
    
    private func getCollectionsViewOffset(startingOffsetY: CGFloat) -> CGFloat {
        
        return max(3, endingOffsetY + startingOffsetY + currentDragOffsetY)
    }
}
