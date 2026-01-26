//
//  LiveStats.swift
//  MyKidStats - Phase1 Solution
//

import Foundation

struct LiveStats {
    var points: Int = 0
    var fgMade: Int = 0
    var fgAttempted: Int = 0
    var fgPercentage: Double = 0.0
    var threeMade: Int = 0
    var threeAttempted: Int = 0
    var threePercentage: Double = 0.0
    var ftMade: Int = 0
    var ftAttempted: Int = 0
    var ftPercentage: Double = 0.0
    var rebounds: Int = 0
    var assists: Int = 0
    var steals: Int = 0
    var blocks: Int = 0
    var turnovers: Int = 0
    var fouls: Int = 0
    
    mutating func updatePercentages() {
        fgPercentage = fgAttempted > 0 ? Double(fgMade) / Double(fgAttempted) * 100 : 0
        threePercentage = threeAttempted > 0 ? Double(threeMade) / Double(threeAttempted) * 100 : 0
        ftPercentage = ftAttempted > 0 ? Double(ftMade) / Double(ftAttempted) * 100 : 0
    }
    
    mutating func recordStat(_ statType: StatType) {
        switch statType {
        case .freeThrowMade:
            ftMade += 1
            ftAttempted += 1
            points += 1
        case .freeThrowMiss:
            ftAttempted += 1
        case .twoPointMade:
            fgMade += 1
            fgAttempted += 1
            points += 2
        case .twoPointMiss:
            fgAttempted += 1
        case .threePointMade:
            threeMade += 1
            threeAttempted += 1
            fgMade += 1
            fgAttempted += 1
            points += 3
        case .threePointMiss:
            threeAttempted += 1
            fgAttempted += 1
        case .rebound:
            rebounds += 1
        case .assist:
            assists += 1
        case .steal:
            steals += 1
        case .block:
            blocks += 1
        case .turnover:
            turnovers += 1
        case .foul:
            fouls += 1
        case .teamPoint:
            break
        }
        
        updatePercentages()
    }
    
    mutating func reverseStat(_ statType: StatType) {
        switch statType {
        case .freeThrowMade:
            ftMade -= 1
            ftAttempted -= 1
            points -= 1
        case .freeThrowMiss:
            ftAttempted -= 1
        case .twoPointMade:
            fgMade -= 1
            fgAttempted -= 1
            points -= 2
        case .twoPointMiss:
            fgAttempted -= 1
        case .threePointMade:
            threeMade -= 1
            threeAttempted -= 1
            fgMade -= 1
            fgAttempted -= 1
            points -= 3
        case .threePointMiss:
            threeAttempted -= 1
            fgAttempted -= 1
        case .rebound:
            rebounds -= 1
        case .assist:
            assists -= 1
        case .steal:
            steals -= 1
        case .block:
            blocks -= 1
        case .turnover:
            turnovers -= 1
        case .foul:
            fouls -= 1
        case .teamPoint:
            break
        }
        
        updatePercentages()
    }
}
