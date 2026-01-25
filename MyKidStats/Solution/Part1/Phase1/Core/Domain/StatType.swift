//
//  StatType.swift
//  MyKidStats - Phase1 Solution
//

import Foundation
import SwiftUI

enum StatType: String, CaseIterable {
    // Shooting - Made
    case twoPointMade = "TWO_MADE"
    case threePointMade = "THREE_MADE"
    case freeThrowMade = "FT_MADE"
    
    // Shooting - Missed
    case twoPointMiss = "TWO_MISS"
    case threePointMiss = "THREE_MISS"
    case freeThrowMiss = "FT_MISS"
    
    // Other stats
    case rebound = "REBOUND"
    case assist = "ASSIST"
    case steal = "STEAL"
    case block = "BLOCK"
    case turnover = "TURNOVER"
    case foul = "FOUL"
    
    // Team scoring
    case teamPoint = "TEAM_POINT"
    
    var pointValue: Int {
        switch self {
        case .freeThrowMade: return 1
        case .twoPointMade, .teamPoint: return 2
        case .threePointMade: return 3
        default: return 0
        }
    }
    
    var displayName: String {
        switch self {
        case .twoPointMade: return "2PT ✓"
        case .twoPointMiss: return "2PT ✗"
        case .threePointMade: return "3PT ✓"
        case .threePointMiss: return "3PT ✗"
        case .freeThrowMade: return "FT ✓"
        case .freeThrowMiss: return "FT ✗"
        case .rebound: return "REB"
        case .assist: return "AST"
        case .steal: return "STL"
        case .block: return "BLK"
        case .turnover: return "TO"
        case .foul: return "PF"
        case .teamPoint: return "+PTS"
        }
    }
    
    var icon: String {
        switch self {
        case .twoPointMade, .threePointMade:
            return "basketball.fill"
        case .twoPointMiss, .threePointMiss:
            return "xmark.circle"
        case .freeThrowMade:
            return "checkmark.circle.fill"
        case .freeThrowMiss:
            return "xmark.circle.fill"
        case .rebound:
            return "arrow.up.circle.fill"
        case .assist:
            return "hand.raised.fill"
        case .steal:
            return "hand.point.up.left.fill"
        case .block:
            return "hand.raised.slash.fill"
        case .turnover:
            return "arrow.triangle.2.circlepath"
        case .foul:
            return "exclamationmark.triangle.fill"
        case .teamPoint:
            return "plus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .twoPointMade, .threePointMade, .freeThrowMade:
            return .statMade
        case .twoPointMiss, .threePointMiss, .freeThrowMiss:
            return .statMissed
        case .rebound, .assist, .steal, .block:
            return .statPositive
        case .turnover, .foul:
            return .statNegative
        case .teamPoint:
            return .statTeam
        }
    }
}
