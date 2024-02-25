import UIKit
import SwiftUI
import PlaygroundSupport
import CoreData // Import CoreData

// Initialize your Core Data stack or use an existing one from your app



let persistenceController = CoreDataManager.shared

let containerView = VStack {
    ContentView()
        .environment(\.managedObjectContext, persistenceController.viewContext)
}
.frame(width: 700, height: 1000, alignment: .center)

PlaygroundPage.current.setLiveView(containerView)



