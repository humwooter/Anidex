//
//  CollectionsView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/21/24.
//

import Foundation
import SwiftUI


struct CollectionsView: View {
    
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
