import XCTest
@testable import MyKidStats
import CoreData

final class CalculateCareerStatsUseCaseTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.createInMemoryStack().mainContext
    }

    func testCalculateCareerStats() throws {
        // Arrange: create child, player and two completed games with events
        let child = TestDataHelper.createTestChild(name: "CareerChild", context: context)
        let team = TestDataHelper.createTestTeam(context: context)
        let player = TestDataHelper.createTestPlayer(child: child, team: team, context: context)

        let game1 = TestDataHelper.createTestGame(team: team, focusChildId: child.id, context: context)
        game1.isComplete = true
        let event1 = StatEvent(context: context)
        event1.id = UUID(); event1.playerId = player.id; event1.gameId = game1.id
        event1.timestamp = Date(); event1.statType = StatType.twoPointMade.rawValue; event1.value = 2; event1.isDeleted = false

        let game2 = TestDataHelper.createTestGame(team: team, focusChildId: child.id, context: context)
        game2.isComplete = true
        let event2 = StatEvent(context: context)
        event2.id = UUID(); event2.playerId = player.id; event2.gameId = game2.id
        event2.timestamp = Date(); event2.statType = StatType.threePointMade.rawValue; event2.value = 3; event2.isDeleted = false

        try context.save()

        // Act
        let useCase = CalculateCareerStatsUseCase(context: context)
        let stats = try XCTUnwrap(try useCase.execute(for: child.id))

        // Assert
        XCTAssertEqual(stats.totalGames, 2)
        XCTAssertEqual(stats.totalPoints, 5)
        XCTAssertEqual(Int(stats.pointsPerGame.rounded()), 3) // average ~2.5 -> rounded to 3 for simple assertion
    }
}
