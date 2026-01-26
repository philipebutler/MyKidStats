//
//  StatEvent+CoreDataProperties.swift
//  
//
//  Created by Philip Butler on 1/25/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias StatEventCoreDataPropertiesSet = NSSet

extension StatEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StatEvent> {
        return NSFetchRequest<StatEvent>(entityName: "StatEvent")
    }

    @NSManaged public var gameId: UUID?
    @NSManaged public var id: UUID?
    @NSManaged public var isSoftDeleted: Bool
    @NSManaged public var playerId: UUID?
    @NSManaged public var statType: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var value: Int32
    @NSManaged public var game: Game?
    @NSManaged public var player: Player?

}

extension StatEvent : Identifiable {

}
