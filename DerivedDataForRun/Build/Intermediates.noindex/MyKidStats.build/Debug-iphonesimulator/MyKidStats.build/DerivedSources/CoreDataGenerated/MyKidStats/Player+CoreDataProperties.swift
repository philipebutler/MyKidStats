//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Philip Butler on 1/25/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PlayerCoreDataPropertiesSet = NSSet

extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var childId: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var jerseyNumber: String?
    @NSManaged public var position: String?
    @NSManaged public var teamId: UUID?
    @NSManaged public var child: Child?
    @NSManaged public var statEvents: NSSet?
    @NSManaged public var team: Team?

}

// MARK: Generated accessors for statEvents
extension Player {

    @objc(addStatEventsObject:)
    @NSManaged public func addToStatEvents(_ value: StatEvent)

    @objc(removeStatEventsObject:)
    @NSManaged public func removeFromStatEvents(_ value: StatEvent)

    @objc(addStatEvents:)
    @NSManaged public func addToStatEvents(_ values: NSSet)

    @objc(removeStatEvents:)
    @NSManaged public func removeFromStatEvents(_ values: NSSet)

}

extension Player : Identifiable {

}
