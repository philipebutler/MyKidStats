//
//  LiveStatsTests.swift
//  MyKidStatsTests
//
//  Created by Philip Butler on 1/24/26.
//

import XCTest
@testable import MyKidStats

final class LiveStatsTests: XCTestCase {
    var sut: LiveStats!
    
    override func setUp() {
        super.setUp()
        sut = LiveStats()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Two Point Tests
    func testRecordTwoPointMade() {
        sut.recordStat(.twoPointMade)
        
        XCTAssertEqual(sut.points, 2)
        XCTAssertEqual(sut.fgMade, 1)
        XCTAssertEqual(sut.fgAttempted, 1)
        XCTAssertEqual(sut.fgPercentage, 100.0)
    }
    
    func testRecordTwoPointMiss() {
        sut.recordStat(.twoPointMiss)
        
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.fgMade, 0)
        XCTAssertEqual(sut.fgAttempted, 1)
        XCTAssertEqual(sut.fgPercentage, 0.0)
    }
    
    // MARK: - Three Point Tests
    func testRecordThreePointMade() {
        sut.recordStat(.threePointMade)
        
        XCTAssertEqual(sut.points, 3)
        XCTAssertEqual(sut.fgMade, 1)
        XCTAssertEqual(sut.fgAttempted, 1)
        XCTAssertEqual(sut.threeMade, 1)
        XCTAssertEqual(sut.threeAttempted, 1)
        XCTAssertEqual(sut.fgPercentage, 100.0)
        XCTAssertEqual(sut.threePercentage, 100.0)
    }
    
    func testRecordThreePointMiss() {
        sut.recordStat(.threePointMiss)
        
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.fgMade, 0)
        XCTAssertEqual(sut.fgAttempted, 1)
        XCTAssertEqual(sut.threeMade, 0)
        XCTAssertEqual(sut.threeAttempted, 1)
        XCTAssertEqual(sut.threePercentage, 0.0)
    }
    
    // MARK: - Free Throw Tests
    func testRecordFreeThrowMade() {
        sut.recordStat(.freeThrowMade)
        
        XCTAssertEqual(sut.points, 1)
        XCTAssertEqual(sut.ftMade, 1)
        XCTAssertEqual(sut.ftAttempted, 1)
        XCTAssertEqual(sut.ftPercentage, 100.0)
    }
    
    func testRecordFreeThrowMiss() {
        sut.recordStat(.freeThrowMiss)
        
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.ftMade, 0)
        XCTAssertEqual(sut.ftAttempted, 1)
        XCTAssertEqual(sut.ftPercentage, 0.0)
    }
    
    // MARK: - Percentage Calculation Tests
    func testFieldGoalPercentage() {
        sut.recordStat(.twoPointMade)
        sut.recordStat(.twoPointMade)
        sut.recordStat(.twoPointMiss)
        sut.recordStat(.twoPointMiss)
        
        XCTAssertEqual(sut.fgMade, 2)
        XCTAssertEqual(sut.fgAttempted, 4)
        XCTAssertEqual(sut.fgPercentage, 50.0)
    }
    
    func testThreePointPercentage() {
        sut.recordStat(.threePointMade)
        sut.recordStat(.threePointMade)
        sut.recordStat(.threePointMiss)
        
        XCTAssertEqual(sut.threeMade, 2)
        XCTAssertEqual(sut.threeAttempted, 3)
        XCTAssertEqual(sut.threePercentage, 66.66666666666667, accuracy: 0.001)
    }
    
    func testFreeThrowPercentage() {
        sut.recordStat(.freeThrowMade)
        sut.recordStat(.freeThrowMade)
        sut.recordStat(.freeThrowMade)
        sut.recordStat(.freeThrowMiss)
        
        XCTAssertEqual(sut.ftMade, 3)
        XCTAssertEqual(sut.ftAttempted, 4)
        XCTAssertEqual(sut.ftPercentage, 75.0)
    }
    
    func testPercentageWithZeroAttempts() {
        XCTAssertEqual(sut.fgPercentage, 0.0)
        XCTAssertEqual(sut.threePercentage, 0.0)
        XCTAssertEqual(sut.ftPercentage, 0.0)
    }
    
    // MARK: - Reverse Stat Tests
    func testReverseTwoPointMade() {
        sut.recordStat(.twoPointMade)
        XCTAssertEqual(sut.points, 2)
        
        sut.reverseStat(.twoPointMade)
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.fgMade, 0)
        XCTAssertEqual(sut.fgAttempted, 0)
    }
    
    func testReverseThreePointMade() {
        sut.recordStat(.threePointMade)
        XCTAssertEqual(sut.points, 3)
        XCTAssertEqual(sut.threeMade, 1)
        
        sut.reverseStat(.threePointMade)
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.threeMade, 0)
        XCTAssertEqual(sut.fgMade, 0)
    }
    
    func testReverseFreeThrowMade() {
        sut.recordStat(.freeThrowMade)
        XCTAssertEqual(sut.points, 1)
        
        sut.reverseStat(.freeThrowMade)
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.ftMade, 0)
        XCTAssertEqual(sut.ftAttempted, 0)
    }
    
    func testReverseTwoPointMiss() {
        sut.recordStat(.twoPointMiss)
        XCTAssertEqual(sut.fgAttempted, 1)
        
        sut.reverseStat(.twoPointMiss)
        XCTAssertEqual(sut.fgAttempted, 0)
    }
    
    // MARK: - Other Stats Tests
    func testRecordRebound() {
        sut.recordStat(.rebound)
        XCTAssertEqual(sut.rebounds, 1)
    }
    
    func testRecordAssist() {
        sut.recordStat(.assist)
        XCTAssertEqual(sut.assists, 1)
    }
    
    func testRecordSteal() {
        sut.recordStat(.steal)
        XCTAssertEqual(sut.steals, 1)
    }
    
    func testRecordBlock() {
        sut.recordStat(.block)
        XCTAssertEqual(sut.blocks, 1)
    }
    
    func testRecordTurnover() {
        sut.recordStat(.turnover)
        XCTAssertEqual(sut.turnovers, 1)
    }
    
    func testRecordFoul() {
        sut.recordStat(.foul)
        XCTAssertEqual(sut.fouls, 1)
    }
    
    func testReverseRebound() {
        sut.recordStat(.rebound)
        sut.recordStat(.rebound)
        XCTAssertEqual(sut.rebounds, 2)
        
        sut.reverseStat(.rebound)
        XCTAssertEqual(sut.rebounds, 1)
    }
    
    // MARK: - Complex Scenarios
    func testRecordMultipleStats() {
        sut.recordStat(.twoPointMade)
        sut.recordStat(.rebound)
        sut.recordStat(.assist)
        sut.recordStat(.threePointMade)
        
        XCTAssertEqual(sut.points, 5)
        XCTAssertEqual(sut.rebounds, 1)
        XCTAssertEqual(sut.assists, 1)
        XCTAssertEqual(sut.fgMade, 2)
        XCTAssertEqual(sut.fgAttempted, 2)
    }
    
    func testMixedShootingPerformance() {
        // 2-point: 1/3 (33.3%)
        sut.recordStat(.twoPointMade)
        sut.recordStat(.twoPointMiss)
        sut.recordStat(.twoPointMiss)
        
        // 3-point: 1/2 (50%)
        sut.recordStat(.threePointMade)
        sut.recordStat(.threePointMiss)
        
        // FG: 2/5 (40%)
        XCTAssertEqual(sut.fgMade, 2)
        XCTAssertEqual(sut.fgAttempted, 5)
        XCTAssertEqual(sut.fgPercentage, 40.0)
        
        // 3PT: 1/2 (50%)
        XCTAssertEqual(sut.threeMade, 1)
        XCTAssertEqual(sut.threeAttempted, 2)
        XCTAssertEqual(sut.threePercentage, 50.0)
        
        // Points: 2 + 3 = 5
        XCTAssertEqual(sut.points, 5)
    }
    
    func testUndoLastStatInSequence() {
        sut.recordStat(.twoPointMade)
        sut.recordStat(.rebound)
        sut.recordStat(.assist)
        sut.recordStat(.steal)
        
        // Undo steal
        sut.reverseStat(.steal)
        
        XCTAssertEqual(sut.steals, 0)
        XCTAssertEqual(sut.points, 2)
        XCTAssertEqual(sut.rebounds, 1)
        XCTAssertEqual(sut.assists, 1)
    }
    
    func testTeamPointDoesNotAffectPlayerStats() {
        sut.recordStat(.teamPoint)
        
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.fgMade, 0)
        XCTAssertEqual(sut.fgAttempted, 0)
    }
}
