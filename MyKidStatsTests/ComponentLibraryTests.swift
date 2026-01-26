import XCTest
import SwiftUI
import UIKit
@testable import MyKidStats

final class ComponentLibraryTests: XCTestCase {
    func testTeamScoringRowLoads() {
        let view = TeamScoringRow(jerseyNumber: "12", playerName: "Alex", currentScore: 3) { _ in }
        let host = UIHostingController(rootView: view)
        host.loadViewIfNeeded()
        XCTAssertNotNil(host.view)
    }

    func testGameCardLoads() {
        let view = GameCard(teamName: "My Team", opponentName: "Opp", teamScore: 5, opponentScore: 2, gameDate: Date(), result: GameResult.win, focusPlayerStats: "Alex: 5 PTS") { }
        let host = UIHostingController(rootView: view)
        host.loadViewIfNeeded()
        XCTAssertNotNil(host.view)
    }
}
