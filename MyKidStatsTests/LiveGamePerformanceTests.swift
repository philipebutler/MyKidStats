import XCTest
@testable import MyKidStats
import CoreData

@MainActor
final class LiveGamePerformanceTests: XCTestCase {
    var context: NSManagedObjectContext!
    var viewModel: LiveGameViewModel!
    var game: Game!
    var player: Player!
    
    override func setUp() async throws {
        try await super.setUp()
        
        context = CoreDataStack.createInMemoryStack().mainContext
        
        let child = TestDataHelper.createTestChild(name: "PerformanceTest", context: context)
        let team = TestDataHelper.createTestTeam(context: context)
        player = TestDataHelper.createTestPlayer(child: child, team: team, context: context)
        game = TestDataHelper.createTestGame(team: team, focusChild: child, context: context)
        
        try context.save()
        
        viewModel = LiveGameViewModel(game: game, focusPlayer: player, context: context)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        game = nil
        player = nil
        context = nil
        try await super.tearDown()
    }
    
    // MARK: - Performance Tests
    
    /// Test that recording a stat takes less than 50ms (critical requirement)
    func testStatRecordingPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            viewModel.recordFocusPlayerStat(.twoPointMade)
        }
        
        // Additional verification that it's under the 50ms requirement
        let expectation = XCTestExpectation(description: "Stat recording completes quickly")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        viewModel.recordFocusPlayerStat(.threePointMade)
        
        let elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000 // Convert to ms
        XCTAssertLessThan(elapsedTime, 50.0, "Stat recording should take less than 50ms, took \(elapsedTime)ms")
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test that team scoring is fast
    func testTeamScoringPerformance() throws {
        guard let playerId = player.id else {
            XCTFail("Player should have an ID")
            return
        }
        
        measure(metrics: [XCTClockMetric()]) {
            viewModel.recordTeamPlayerScore(playerId, points: 2)
        }
    }
    
    /// Test that opponent scoring is fast
    func testOpponentScoringPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            viewModel.recordOpponentScore(2)
        }
    }
    
    /// Test that undo operations are fast
    func testUndoPerformance() throws {
        // Record a stat first
        viewModel.recordFocusPlayerStat(.twoPointMade)
        
        measure(metrics: [XCTClockMetric()]) {
            viewModel.undoLastAction()
            viewModel.recordFocusPlayerStat(.twoPointMade) // Re-record for next iteration
        }
    }
    
    /// Test rapid stat recording (simulating fast gameplay)
    func testRapidStatRecording() throws {
        let statTypes: [StatType] = [
            .twoPointMade, .freeThrowMade, .rebound, .assist,
            .twoPointMade, .steal, .twoPointMade, .rebound
        ]
        
        measure(metrics: [XCTClockMetric()]) {
            for statType in statTypes {
                viewModel.recordFocusPlayerStat(statType)
            }
        }
        
        // Verify all stats were recorded
        XCTAssertGreaterThan(viewModel.currentStats.points, 0)
    }
    
    /// Test loading existing game stats
    func testLoadExistingStatsPerformance() throws {
        // First, create some stats
        for _ in 0..<20 {
            viewModel.recordFocusPlayerStat(.twoPointMade)
            viewModel.recordFocusPlayerStat(.rebound)
            viewModel.recordFocusPlayerStat(.assist)
        }
        
        try context.save()
        
        // Now measure loading them
        measure(metrics: [XCTClockMetric()]) {
            let newVM = LiveGameViewModel(game: game, focusPlayer: player, context: context)
            XCTAssertGreaterThan(newVM.currentStats.points, 0)
        }
    }
    
    /// Test calculating live stats from events
    func testStatsCalculationPerformance() throws {
        // Create multiple stat events
        for i in 0..<50 {
            let event = StatEvent(context: context)
            event.id = UUID()
            event.playerId = player.id
            event.gameId = game.id
            event.timestamp = Date()
            event.statType = (i % 2 == 0) ? StatType.twoPointMade.rawValue : StatType.rebound.rawValue
            event.value = Int32((i % 2 == 0) ? 2 : 0)
            event.isSoftDeleted = false
        }
        
        try context.save()
        
        measure(metrics: [XCTClockMetric()]) {
            let events = (game.statEvents as? Set<StatEvent>) ?? Set()
            let playerEvents = events.filter { $0.playerId == player.id && !$0.isSoftDeleted }
            
            var stats = LiveStats()
            for event in playerEvents {
                guard let statType = event.statType, let type = StatType(rawValue: statType) else { continue }
                stats.recordStat(type)
            }
            
            XCTAssertGreaterThan(stats.points, 0)
        }
    }
    
    /// Benchmark test - measure baseline performance
    func testBaselineStatRecordingBenchmark() throws {
        let iterations = 100
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            viewModel.recordFocusPlayerStat(.twoPointMade)
        }
        
        let totalTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000 // Convert to ms
        let averageTime = totalTime / Double(iterations)
        
        print("📊 Performance Benchmark Results:")
        print("   Total time for \(iterations) stats: \(String(format: "%.2f", totalTime))ms")
        print("   Average time per stat: \(String(format: "%.2f", averageTime))ms")
        print("   Target: <50ms per stat")
        print("   Status: \(averageTime < 50 ? "✅ PASS" : "❌ FAIL")")
        
        XCTAssertLessThan(averageTime, 50.0, "Average stat recording should be under 50ms")
    }
}
