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
    @State private var panelHeight: CGFloat = 100 // Minimized height
    @State var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.85

    @State var currentDragOffsetY: CGFloat = .zero
    @State var endingOffsetY: CGFloat = .zero
    @State private var isFullscreen = false
    @State var inCameraMode: Bool = true;

    @State private var endOffset:CGFloat = 0
    
    var body : some View {
        
        
//        VStack {
        GeometryReader  { geometry in
            let totalHeight = geometry.size.height
            let safeAreaBottom = geometry.safeAreaInsets.bottom
            
            // Determine the fixed height for CollectionView (e.g. 100)
            
            // Calculate offset
            let startingOffsetY = 0.85 * totalHeight // Adjust as per your requirement
            let computedOffset = endingOffsetY + startingOffsetY + currentDragOffsetY
            ZStack {
                CameraView(camera: camera).ignoresSafeArea(.all, edges: .all)
                DraggablePanel(panelHeight: $panelHeight)
                    .offset(y: isFullscreen ? 0 : getCollectionsViewOffset(startingOffsetY: startingOffsetY + safeAreaBottom))
                    .frame(height: isFullscreen ? totalHeight : nil) // Full height if fullscreen
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


    private func getCollectionsViewOffset(startingOffsetY: CGFloat) -> CGFloat {
        
        return max(3, endingOffsetY + startingOffsetY + currentDragOffsetY)
    }

//                .onAppear {
//                    let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
//                    if !hasLaunchedBefore {
//                        initializeSpecies()
//                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
//                    }
//                }
        }
//    }

    


struct DraggablePanel: View {

    @Binding var panelHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            // Panel content
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
                .background(/* styling */)
                .coordinateSpace(name: "panel")
                .frame(height: panelHeight)
//                .gesture(
//                    DragGesture().onChanged { value in
//                        let translation = value.translation.height
//                        self.panelHeight = max(100, min(500, translation + self.panelHeight))
//                    }
//                )
//        .frame(height: panelHeight)
//        .gesture(
//            DragGesture().onChanged { value in
//                self.panelHeight = max(100, min(500, value.translation.height + self.panelHeight))
//            }
//        )
    }
}



