//
//  CareerStats.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/24/26.
//

import Foundation

struct CareerStats {
    let childId: UUID
    let childName: String
    let totalGames: Int
    
    // Overall averages
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
    let stealsPerGame: Double
    let blocksPerGame: Double
    
    // Totals
    let totalPoints: Int
    let totalRebounds: Int
    let totalAssists: Int
    let totalSteals: Int
    let totalBlocks: Int
    let totalTurnovers: Int
    let totalFouls: Int
    
    // Shooting
    let fieldGoalMade: Int
    let fieldGoalAttempted: Int
    let fieldGoalPercentage: Double
    
    let threePointMade: Int
    let threePointAttempted: Int
    let threePointPercentage: Double
    
    let freeThrowMade: Int
    let freeThrowAttempted: Int
    let freeThrowPercentage: Double
    
    // Career highs
    let careerHighPoints: Int
    let careerHighRebounds: Int
    let careerHighAssists: Int
    
    // Team breakdown
    let teamStats: [TeamSeasonStats]
}

struct TeamSeasonStats {
    let teamName: String
    let season: String
    let organization: String?
    let games: Int
    let wins: Int
    let losses: Int
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
}
