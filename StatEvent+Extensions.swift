//
//  StatEvent+Extensions.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/24/26.
//

import Foundation
import CoreData

extension StatEvent {
    /// Soft delete compatibility - maps to isDeleted attribute
    var isSoftDeleted: Bool {
        get { isDeleted }
        set { isDeleted = newValue }
    }
    
    /// Check if this event represents a scoring play
    var isPointEvent: Bool {
        guard let type = statType else { return false }
        return type == "twoPointMade" || type == "threePointMade" || type == "freeThrowMade"
    }
    
    /// Get the point value for this event
    var pointValue: Int {
        guard let type = statType else { return 0 }
        
        switch type {
        case "twoPointMade": return 2
        case "threePointMade": return 3
        case "freeThrowMade": return 1
        default: return 0
        }
    }
    
    /// Fetch all stat events for a game
    static func fetchEvents(forGameId gameId: UUID, context: NSManagedObjectContext) throws -> [StatEvent] {
        let request = NSFetchRequest<StatEvent>(entityName: "StatEvent")
        request.predicate = NSPredicate(format: "gameId == %@ AND isDeleted == false", gameId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return try context.fetch(request)
    }
    
    /// Fetch stat events for a specific player in a game
    static func fetchEvents(forPlayerId playerId: UUID, gameId: UUID, context: NSManagedObjectContext) throws -> [StatEvent] {
        let request = NSFetchRequest<StatEvent>(entityName: "StatEvent")
        request.predicate = NSPredicate(
            format: "playerId == %@ AND gameId == %@ AND isDeleted == false",
            playerId as CVarArg,
            gameId as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return try context.fetch(request)
    }
}
