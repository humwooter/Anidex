import UIKit
import SwiftUI
import PlaygroundSupport
import CoreData 
import AVFoundation





let persistenceController = CoreDataManager.shared

let containerView = VStack {
    
    ContentViewDemo()
        .environment(\.managedObjectContext, persistenceController.viewContext)
}
.frame(width: 700, height: 900, alignment: .center)

PlaygroundPage.current.setLiveView(containerView)



