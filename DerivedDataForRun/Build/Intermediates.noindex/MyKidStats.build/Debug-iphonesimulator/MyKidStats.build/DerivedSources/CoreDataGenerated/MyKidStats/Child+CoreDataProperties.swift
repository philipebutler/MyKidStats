//
//  Child+CoreDataProperties.swift
//  
//
//  Created by Philip Butler on 1/25/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias ChildCoreDataPropertiesSet = NSSet

extension Child {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Child> {
        return NSFetchRequest<Child>(entityName: "Child")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var lastUsed: Date?
    @NSManaged public var name: String?
    @NSManaged public var photoData: Data?
    @NSManaged public var playerInstances: NSSet?

}

// MARK: Generated accessors for playerInstances
extension Child {

    @objc(addPlayerInstancesObject:)
    @NSManaged public func addToPlayerInstances(_ value: Player)

    @objc(removePlayerInstancesObject:)
    @NSManaged public func removeFromPlayerInstances(_ value: Player)

    @objc(addPlayerInstances:)
    @NSManaged public func addToPlayerInstances(_ values: NSSet)

    @objc(removePlayerInstances:)
    @NSManaged public func removeFromPlayerInstances(_ values: NSSet)

}

extension Child : Identifiable {

}
