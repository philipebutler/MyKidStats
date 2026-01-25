//
//  CoreDataStack.swift
//  MyKidStats - Phase1 Solution
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyKidStats")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func save() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Core Data save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Testing Support
    static func createInMemoryStack() -> CoreDataStack {
        let stack = CoreDataStack()
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        stack.persistentContainer.persistentStoreDescriptions = [description]
        
        // Force load
        _ = stack.persistentContainer.viewContext
        
        return stack
    }
}
