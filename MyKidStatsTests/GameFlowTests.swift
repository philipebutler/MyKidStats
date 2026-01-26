import XCTest
@testable import MyKidStats
import CoreData

class GameFlowTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.createInMemoryStack().mainContext
    }

    func testCompleteGameFlow() throws {
        let child = TestDataHelper.createTestChild(name: "Test", context: context)
        let team = TestDataHelper.createTestTeam(context: context)
        let player = TestDataHelper.createTestPlayer(child: child, team: team, context: context)
        let game = TestDataHelper.createTestGame(team: team, focusChildId: child.id, context: context)

        let stats: [StatType] = [.twoPointMade, .twoPointMade, .rebound]
        for type in stats {
            let event = StatEvent(context: context)
            event.id = UUID()
            event.playerId = player.id
            event.gameId = game.id
            event.timestamp = Date()
            event.statType = type.rawValue
            event.value = Int32(type.pointValue)
            event.isDeleted = false
        }

        try context.save()

        XCTAssertEqual(game.teamScore, 4)

        game.isComplete = true
        try context.save()

        XCTAssertTrue(game.isComplete)
    }
}
