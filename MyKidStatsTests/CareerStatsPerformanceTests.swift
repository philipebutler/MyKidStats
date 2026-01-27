import XCTest
@testable import MyKidStats
import CoreData

final class CareerStatsPerformanceTests: XCTestCase {
    var context: NSManagedObjectContext!
    var useCase: CalculateCareerStatsUseCase!
    
    override func setUp() async throws {
        try await super.setUp()
        context = CoreDataStack.createInMemoryStack().mainContext
        useCase = CalculateCareerStatsUseCase(context: context)
    }
    
    override func tearDown() async throws {
        useCase = nil
        context = nil
        try await super.tearDown()
    }
    
    // MARK: - Performance Tests
    
    /// Test career stats calculation with small dataset (5 games)
    func testCareerStatsCalculationSmallDataset() async throws {
        let child = try createChildWithGames(gameCount: 5, eventsPerGame: 20)
        
        measure(metrics: [XCTClockMetric()]) {
            Task {
                do {
                    let stats = try await useCase.execute(for: child.id!)
                    XCTAssertGreaterThan(stats.totalGames, 0)
                } catch {
                    XCTFail("Failed to calculate stats: \(error)")
                }
            }
        }
    }
    
    /// Test career stats calculation with medium dataset (20 games)
    func testCareerStatsCalculationMediumDataset() async throws {
        let child = try createChildWithGames(gameCount: 20, eventsPerGame: 30)
        
        measure(metrics: [XCTClockMetric()]) {
            Task {
                do {
                    let stats = try await useCase.execute(for: child.id!)
                    XCTAssertGreaterThan(stats.totalGames, 0)
                } catch {
                    XCTFail("Failed to calculate stats: \(error)")
                }
            }
        }
    }
    
    /// Test career stats calculation with large dataset (50 games)
    func testCareerStatsCalculationLargeDataset() async throws {
        let child = try createChildWithGames(gameCount: 50, eventsPerGame: 40)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let stats = try await useCase.execute(for: child.id!)
        let elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        
        print("📊 Career Stats Performance (50 games, ~2000 events):")
        print("   Time: \(String(format: "%.2f", elapsedTime))ms")
        print("   Games: \(stats.totalGames)")
        print("   Total Points: \(stats.totalPoints)")
        
        XCTAssertEqual(stats.totalGames, 50)
        XCTAssertLessThan(elapsedTime, 1000, "Career stats calculation should complete in under 1 second")
    }
    
    /// Test career stats with multiple teams
    func testCareerStatsMultipleTeamsPerformance() async throws {
        let child = TestDataHelper.createTestChild(name: "MultiTeam", context: context)
        
        // Create 3 teams with games
        for teamIndex in 0..<3 {
            let team = TestDataHelper.createTestTeam(context: context)
            team.name = "Team \(teamIndex + 1)"
            
            let player = TestDataHelper.createTestPlayer(child: child, team: team, context: context)
            
            for _ in 0..<10 {
                let game = TestDataHelper.createTestGame(team: team, focusChild: child, context: context)
                game.isComplete = true
                
                // Add some stats
                for _ in 0..<15 {
                    let event = StatEvent(context: context)
                    event.id = UUID()
                    event.playerId = player.id
                    event.gameId = game.id
                    event.timestamp = Date()
                    event.statType = StatType.twoPointMade.rawValue
                    event.value = 2
                    event.isSoftDeleted = false
                }
            }
        }
        
        try context.save()
        
        measure(metrics: [XCTClockMetric()]) {
            Task {
                do {
                    let stats = try await useCase.execute(for: child.id!)
                    XCTAssertEqual(stats.teamStats.count, 3, "Should have stats for 3 teams")
                } catch {
                    XCTFail("Failed to calculate stats: \(error)")
                }
            }
        }
    }
    
    /// Test memory usage during career stats calculation
    func testCareerStatsMemoryUsage() async throws {
        let child = try createChildWithGames(gameCount: 30, eventsPerGame: 35)
        
        measure(metrics: [XCTMemoryMetric()]) {
            Task {
                do {
                    _ = try await useCase.execute(for: child.id!)
                } catch {
                    XCTFail("Failed to calculate stats: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createChildWithGames(gameCount: Int, eventsPerGame: Int) throws -> Child {
        let child = TestDataHelper.createTestChild(name: "PerfTest", context: context)
        let team = TestDataHelper.createTestTeam(context: context)
        let player = TestDataHelper.createTestPlayer(child: child, team: team, context: context)
        
        let statTypes: [StatType] = [
            .twoPointMade, .twoPointMiss, .threePointMade, .threePointMiss,
            .freeThrowMade, .freeThrowMiss, .rebound, .assist,
            .steal, .block, .turnover, .foul
        ]
        
        for _ in 0..<gameCount {
            let game = TestDataHelper.createTestGame(team: team, focusChild: child, context: context)
            game.isComplete = true
            
            for _ in 0..<eventsPerGame {
                let event = StatEvent(context: context)
                event.id = UUID()
                event.playerId = player.id
                event.gameId = game.id
                event.timestamp = Date()
                
                let randomStatType = statTypes.randomElement()!
                event.statType = randomStatType.rawValue
                event.value = Int32(randomStatType.pointValue)
                event.isSoftDeleted = false
            }
        }
        
        try context.save()
        return child
    }
}
