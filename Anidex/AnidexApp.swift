//
//  AnidexApp.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/20/24.
//

import SwiftUI

@main
struct AnidexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
