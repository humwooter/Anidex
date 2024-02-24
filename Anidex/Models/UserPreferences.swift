//
//  UserPreferences.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/23/24.
//

import Foundation
import SwiftUI
import CoreData


class UserPreferences: ObservableObject {
    @Published var hasCameraAccess: Bool {
        didSet {
            UserDefaults.standard.set(hasCameraAccess, forKey: "hasCameraAccess")
        }
    }
    @Published var hasLocationAccess: Bool {
        didSet {
            UserDefaults.standard.set(hasLocationAccess, forKey: "hasLocationAccess")
        }
    }
    
    @Published var hasInitializedSpecies: Bool {
        didSet {
            UserDefaults.standard.set(hasInitializedSpecies, forKey: "hasInitializedSpecies")
        }
    }

    
    init() {
        self.hasCameraAccess = UserDefaults.standard.bool(forKey: "hasCameraAccess")
        self.hasLocationAccess = UserDefaults.standard.bool(forKey: "hasLocationAccess")
        self.hasInitializedSpecies = UserDefaults.standard.bool(forKey: "hasInitializedSpecies")
    }
}

