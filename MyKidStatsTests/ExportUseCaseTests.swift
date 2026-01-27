import XCTest
@testable import MyKidStats
import CoreData

final class ExportUseCaseTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = CoreDataStack.createInMemoryStack().mainContext
    }

    func testCSVExportAndTextSummary() throws {
        // Arrange
        let child = TestDataHelper.createTestChild(name: "ExportChild", context: context)
        let team = TestDataHelper.createTestTeam(context: context)
        let player = TestDataHelper.createTestPlayer(child: child, team: team, context: context)
        let game = TestDataHelper.createTestGame(team: team, focusChild: child, context: context)

        // Add a couple of stat events
        let e1 = StatEvent(context: context)
        e1.id = UUID()
        e1.playerId = player.id
        e1.gameId = game.id
        e1.timestamp = Date()
        e1.statType = StatType.twoPointMade.rawValue
        e1.value = Int32(2)
        e1.isSoftDeleted = false

        let e2 = StatEvent(context: context)
        e2.id = UUID()
        e2.playerId = player.id
        e2.gameId = game.id
        e2.timestamp = Date()
        e2.statType = StatType.rebound.rawValue
        e2.value = Int32(0)
        e2.isSoftDeleted = false

        try context.save()

        // Act - CSV
        let exporter = ExportGameCSVUseCase()
        let url = try exporter.execute(game)

        // Assert - CSV file exists and contains expected player name
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        let csv = try String(contentsOf: url)
        XCTAssertFalse(csv.isEmpty)
        XCTAssertTrue(csv.contains(player.child?.name ?? ""))

        // Act - Text summary
        let summary = GenerateTextSummaryUseCase().execute(game: game, focusChild: child)
        XCTAssertTrue(summary.contains(child.name ?? ""))
        XCTAssertTrue(summary.contains(game.opponentName ?? ""))
    }
}
