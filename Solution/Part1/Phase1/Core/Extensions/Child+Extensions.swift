//
//  Child+Extensions.swift
//  MyKidStats - Phase1 Solution
//

import Foundation
import CoreData

extension Child {
    
    /// Fetch the most recently used child for smart defaults
    static func fetchLastUsed(context: NSManagedObjectContext) -> Child? {
        let request = Child.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastUsed", ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    /// Fetch all children sorted by name
    static func fetchAll(context: NSManagedObjectContext) -> [Child] {
        let request = Child.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    /// Update last used timestamp (call when starting a game)
    func markAsUsed(context: NSManagedObjectContext) throws {
        self.lastUsed = Date()
        try context.save()
    }
}
