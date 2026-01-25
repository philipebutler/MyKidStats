//
//  StatTypeTests.swift
//  MyKidStatsTests
//
//  Created by Philip Butler on 1/24/26.
//

import XCTest
import SwiftUI
@testable import MyKidStats

final class StatTypeTests: XCTestCase {
    
    // MARK: - Point Value Tests
    func testFreeThrowPointValue() {
        XCTAssertEqual(StatType.freeThrowMade.pointValue, 1)
    }
    
    func testTwoPointPointValue() {
        XCTAssertEqual(StatType.twoPointMade.pointValue, 2)
    }
    
    func testThreePointPointValue() {
        XCTAssertEqual(StatType.threePointMade.pointValue, 3)
    }
    
    func testTeamPointValue() {
        XCTAssertEqual(StatType.teamPoint.pointValue, 2)
    }
    
    func testMissedShotsHaveZeroValue() {
        XCTAssertEqual(StatType.twoPointMiss.pointValue, 0)
        XCTAssertEqual(StatType.threePointMiss.pointValue, 0)
        XCTAssertEqual(StatType.freeThrowMiss.pointValue, 0)
    }
    
    func testNonShootingStatsHaveZeroValue() {
        XCTAssertEqual(StatType.rebound.pointValue, 0)
        XCTAssertEqual(StatType.assist.pointValue, 0)
        XCTAssertEqual(StatType.steal.pointValue, 0)
        XCTAssertEqual(StatType.block.pointValue, 0)
        XCTAssertEqual(StatType.turnover.pointValue, 0)
        XCTAssertEqual(StatType.foul.pointValue, 0)
    }
    
    // MARK: - Display Name Tests
    func testDisplayNames() {
        XCTAssertEqual(StatType.twoPointMade.displayName, "2PT ✓")
        XCTAssertEqual(StatType.twoPointMiss.displayName, "2PT ✗")
        XCTAssertEqual(StatType.threePointMade.displayName, "3PT ✓")
        XCTAssertEqual(StatType.threePointMiss.displayName, "3PT ✗")
        XCTAssertEqual(StatType.freeThrowMade.displayName, "FT ✓")
        XCTAssertEqual(StatType.freeThrowMiss.displayName, "FT ✗")
        XCTAssertEqual(StatType.rebound.displayName, "REB")
        XCTAssertEqual(StatType.assist.displayName, "AST")
        XCTAssertEqual(StatType.steal.displayName, "STL")
        XCTAssertEqual(StatType.block.displayName, "BLK")
        XCTAssertEqual(StatType.turnover.displayName, "TO")
        XCTAssertEqual(StatType.foul.displayName, "PF")
        XCTAssertEqual(StatType.teamPoint.displayName, "+PTS")
    }
    
    // MARK: - Icon Tests
    func testIconsAreValid() {
        // Just verify they return non-empty strings (actual SF Symbol validation would be visual)
        for statType in StatType.allCases {
            XCTAssertFalse(statType.icon.isEmpty, "\(statType.rawValue) should have an icon")
        }
    }
    
    func testShootingIcons() {
        XCTAssertEqual(StatType.twoPointMade.icon, "basketball.fill")
        XCTAssertEqual(StatType.threePointMade.icon, "basketball.fill")
        XCTAssertEqual(StatType.twoPointMiss.icon, "xmark.circle")
        XCTAssertEqual(StatType.threePointMiss.icon, "xmark.circle")
    }
    
    // MARK: - Color Tests
    func testMadeShotColors() {
        XCTAssertEqual(StatType.twoPointMade.color, Color.statMade)
        XCTAssertEqual(StatType.threePointMade.color, Color.statMade)
        XCTAssertEqual(StatType.freeThrowMade.color, Color.statMade)
    }
    
    func testMissedShotColors() {
        XCTAssertEqual(StatType.twoPointMiss.color, Color.statMissed)
        XCTAssertEqual(StatType.threePointMiss.color, Color.statMissed)
        XCTAssertEqual(StatType.freeThrowMiss.color, Color.statMissed)
    }
    
    func testPositiveStatColors() {
        XCTAssertEqual(StatType.rebound.color, Color.statPositive)
        XCTAssertEqual(StatType.assist.color, Color.statPositive)
        XCTAssertEqual(StatType.steal.color, Color.statPositive)
        XCTAssertEqual(StatType.block.color, Color.statPositive)
    }
    
    func testNegativeStatColors() {
        XCTAssertEqual(StatType.turnover.color, Color.statNegative)
        XCTAssertEqual(StatType.foul.color, Color.statNegative)
    }
    
    func testTeamPointColor() {
        XCTAssertEqual(StatType.teamPoint.color, Color.statTeam)
    }
    
    // MARK: - Raw Value Tests
    func testRawValues() {
        XCTAssertEqual(StatType.twoPointMade.rawValue, "TWO_MADE")
        XCTAssertEqual(StatType.threePointMade.rawValue, "THREE_MADE")
        XCTAssertEqual(StatType.freeThrowMade.rawValue, "FT_MADE")
        XCTAssertEqual(StatType.rebound.rawValue, "REBOUND")
        XCTAssertEqual(StatType.assist.rawValue, "ASSIST")
        XCTAssertEqual(StatType.steal.rawValue, "STEAL")
        XCTAssertEqual(StatType.block.rawValue, "BLOCK")
        XCTAssertEqual(StatType.turnover.rawValue, "TURNOVER")
        XCTAssertEqual(StatType.foul.rawValue, "FOUL")
        XCTAssertEqual(StatType.teamPoint.rawValue, "TEAM_POINT")
    }
    
    func testInitFromRawValue() {
        XCTAssertEqual(StatType(rawValue: "TWO_MADE"), .twoPointMade)
        XCTAssertEqual(StatType(rawValue: "THREE_MADE"), .threePointMade)
        XCTAssertEqual(StatType(rawValue: "REBOUND"), .rebound)
        XCTAssertNil(StatType(rawValue: "INVALID"))
    }
    
    // MARK: - CaseIterable Tests
    func testAllCasesCount() {
        XCTAssertEqual(StatType.allCases.count, 13)
    }
    
    func testAllCasesContainsAllStats() {
        let allCases = StatType.allCases
        
        XCTAssertTrue(allCases.contains(.twoPointMade))
        XCTAssertTrue(allCases.contains(.threePointMade))
        XCTAssertTrue(allCases.contains(.freeThrowMade))
        XCTAssertTrue(allCases.contains(.twoPointMiss))
        XCTAssertTrue(allCases.contains(.threePointMiss))
        XCTAssertTrue(allCases.contains(.freeThrowMiss))
        XCTAssertTrue(allCases.contains(.rebound))
        XCTAssertTrue(allCases.contains(.assist))
        XCTAssertTrue(allCases.contains(.steal))
        XCTAssertTrue(allCases.contains(.block))
        XCTAssertTrue(allCases.contains(.turnover))
        XCTAssertTrue(allCases.contains(.foul))
        XCTAssertTrue(allCases.contains(.teamPoint))
    }
}
