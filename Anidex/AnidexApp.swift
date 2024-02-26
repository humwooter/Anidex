//
//  AnidexApp.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/20/24.
//

import SwiftUI

@main
struct AnidexApp: App {
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentViewDemo().environment(\.managedObjectContext, persistenceController.viewContext)

        }
    }
}
