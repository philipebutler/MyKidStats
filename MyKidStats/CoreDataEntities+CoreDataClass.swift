import Foundation
import CoreData

@objc(Child)
public class Child: NSManagedObject {
	@NSManaged public var id: UUID?
	@NSManaged public var name: String?
	@NSManaged public var lastUsed: Date?
	@NSManaged public var playerInstances: NSSet?
}

@objc(Game)
public class Game: NSManagedObject {
	@NSManaged public var id: UUID?
	@NSManaged public var isComplete: Bool
	@NSManaged public var opponentScore: Int32
	@NSManaged public var statEvents: NSSet?
	@NSManaged public var teamId: UUID?
	@NSManaged public var team: Team?
}

@objc(Player)
public class Player: NSManagedObject {
	@NSManaged public var id: UUID?
	@NSManaged public var childId: UUID?
	@NSManaged public var teamId: UUID?
	@NSManaged public var child: Child?
	@NSManaged public var statEvents: NSSet?
	@NSManaged public var team: Team?
}

@objc(StatEvent)
public class StatEvent: NSManagedObject {
	@NSManaged public var id: UUID?
	@NSManaged public var isSoftDeleted: Bool
	@NSManaged public var statType: String?
	@NSManaged public var value: Int32
	@NSManaged public var player: Player?
	@NSManaged public var game: Game?
}

@objc(Team)
public class Team: NSManagedObject {
	@NSManaged public var id: UUID?
	@NSManaged public var name: String?
	@NSManaged public var isActive: Bool
	@NSManaged public var players: NSSet?
	@NSManaged public var games: NSSet?
}
