import Foundation
import CoreData

class TestDataHelper {
    static func createTestChild(
        name: String = "Test Child",
        context: NSManagedObjectContext
    ) -> Child {
        let child = Child(context: context)
        child.id = UUID()
        child.name = name
        child.lastUsed = Date()
        child.createdAt = Date()
        return child
    }

    static func createTestTeam(
        name: String = "Test Team",
        context: NSManagedObjectContext
    ) -> Team {
        let team = Team(context: context)
        team.id = UUID()
        team.name = name
        team.season = "2024"
        team.isActive = true
        team.createdAt = Date()
        return team
    }

    static func createTestPlayer(
        child: Child,
        team: Team,
        context: NSManagedObjectContext
    ) -> Player {
        let player = Player(context: context)
        player.id = UUID()
        player.childId = child.id
        player.teamId = team.id
        player.createdAt = Date()
        return player
    }

    static func createTestGame(
        team: Team,
        focusChild: Child,
        context: NSManagedObjectContext
    ) -> Game {
        let game = Game(context: context)
        game.id = UUID()
        game.teamId = team.id
        game.focusChildId = focusChild.id
        game.opponentName = "Test Opponent"
        game.opponentScore = 0
        game.isComplete = false
        game.gameDate = Date()
        game.createdAt = Date()
        game.updatedAt = Date()
        return game
    }

    static func createCompleteTestSetup(context: NSManagedObjectContext) -> (Child, Team, Player, Game) {
        let child = createTestChild(name: "Alex Johnson", context: context)
        let team = createTestTeam(name: "Warriors", context: context)
        let player = createTestPlayer(child: child, team: team, context: context)
        let game = createTestGame(team: team, focusChild: child, context: context)
        try? context.save()
        return (child, team, player, game)
    }
}
