//
//  CoreDataManager.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/24/24.
//

import Foundation
import CoreData

final class CoreDataManager: ObservableObject {

    let persistenceController: PersistenceController
    static let shared = CoreDataManager(persistenceController: PersistenceController.shared)

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    var persistentContainer: NSPersistentContainer {
        return persistenceController.container
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }()
    
    func save(context: NSManagedObjectContext) {
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Failed to save context: \(error)")
                }
            }
        }
    }

    func saveData() {
        if backgroundContext.hasChanges {
            save(context: backgroundContext)
            mergeChanges(from: backgroundContext)
            if viewContext.hasChanges {
                save(context: viewContext)
            }
        }
    }

    func mergeChanges(from context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
    }

    @objc func contextDidSave(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: notification.object)
        viewContext.performAndWait {
            self.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }

    func undo() {
        viewContext.undoManager?.undo()
        saveData()
    }
  
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch data: \(error)")
            return []
        }
    }

    func fetchInBackground<T: NSManagedObject>(request: NSFetchRequest<T>, completion: @escaping ([T]) -> Void) {
        backgroundContext.perform {
            do {
                let results = try self.backgroundContext.fetch(request)
                completion(results)
            } catch {
                print("Failed to fetch data: \(error)")
                completion([])
            }
        }
    }
}
