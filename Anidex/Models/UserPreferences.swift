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
    
    @Published var mostRecentLattitude: Double {
        didSet {
            UserDefaults.standard.set(mostRecentLattitude, forKey: "mostRecentLattitude")
        }
    }
    @Published var mostRecentLongitude: Double {
        didSet {
            UserDefaults.standard.set(mostRecentLongitude, forKey: "mostRecentLongitude")
        }
    }

    
    init() {
        self.hasCameraAccess = UserDefaults.standard.bool(forKey: "hasCameraAccess")
        self.hasLocationAccess = UserDefaults.standard.bool(forKey: "hasLocationAccess")
        self.hasInitializedSpecies = UserDefaults.standard.bool(forKey: "hasInitializedSpecies")
        self.mostRecentLattitude = UserDefaults.standard.double(forKey: "mostRecentLattitude")
        self.mostRecentLongitude = UserDefaults.standard.double(forKey: "mostRecentLongitude")
    }
}

