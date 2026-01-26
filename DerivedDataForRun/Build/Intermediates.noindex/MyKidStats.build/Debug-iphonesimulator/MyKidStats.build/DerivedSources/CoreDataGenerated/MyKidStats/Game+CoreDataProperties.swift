//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Philip Butler on 1/25/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias GameCoreDataPropertiesSet = NSSet

extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var duration: Int32
    @NSManaged public var focusChildId: UUID?
    @NSManaged public var gameDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isComplete: Bool
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
    @NSManaged public var opponentName: String?
    @NSManaged public var opponentScore: Int32
    @NSManaged public var teamId: UUID?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var statEvents: NSSet?
    @NSManaged public var team: Team?

}

// MARK: Generated accessors for statEvents
extension Game {

    @objc(addStatEventsObject:)
    @NSManaged public func addToStatEvents(_ value: StatEvent)

    @objc(removeStatEventsObject:)
    @NSManaged public func removeFromStatEvents(_ value: StatEvent)

    @objc(addStatEvents:)
    @NSManaged public func addToStatEvents(_ values: NSSet)

    @objc(removeStatEvents:)
    @NSManaged public func removeFromStatEvents(_ values: NSSet)

}

extension Game : Identifiable {

}
