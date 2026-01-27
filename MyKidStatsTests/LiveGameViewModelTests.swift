import XCTest
@testable import MyKidStats
import CoreData

@MainActor
final class LiveGameViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.createInMemoryStack().mainContext
    }

    func testRecordAndUndoFocusPlayerStat() throws {
        let child = TestDataHelper.createTestChild(name: "TestChild", context: context)
        let team = TestDataHelper.createTestTeam(context: context)
        let player = TestDataHelper.createTestPlayer(child: child, team: team, context: context)
        let game = TestDataHelper.createTestGame(team: team, focusChild: child, context: context)
        try context.save()

        let vm = LiveGameViewModel(game: game, focusPlayer: player, context: context)

        XCTAssertEqual(vm.currentStats.points, 0)
        XCTAssertEqual(vm.teamScore, game.calculatedTeamScore)

        vm.recordFocusPlayerStat(.twoPointMade)

        XCTAssertEqual(vm.currentStats.points, 2, "Recording a two-point made should add 2 points")
        XCTAssertTrue(vm.canUndo, "After recording an action, undo should be available")

        vm.undoLastAction()

        XCTAssertFalse(vm.canUndo, "Undo should be cleared after undoing the last action")
        XCTAssertEqual(vm.currentStats.points, 0, "Points should be reverted after undo")
    }
}
