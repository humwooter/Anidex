//
//  SettingsView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/24/24.
//

import Foundation
import SwiftUI
import CoreData


struct SettingsView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var focusField: Bool
    @EnvironmentObject var coreDataManager: CoreDataManager

    var body : some View {
        
        NavigationStack {
            List {
                
            }
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                }
            )

        }
        
    }
}
