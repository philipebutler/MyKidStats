import Foundation
import CoreData

class CalculateCareerStatsUseCase {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }

    func execute(for childId: UUID) async throws -> CareerStats {
        let players = try fetchPlayers(for: childId)
        guard !players.isEmpty else { throw CareerError.noData }

        let playerIds = players.compactMap { $0.id }
        let allStats = try fetchAllStats(for: playerIds)

        let gameIds = Set(allStats.compactMap { $0.game?.id })
        let allGames = try fetchGames(ids: Array(gameIds))

        let childName = players.first?.child?.name ?? "Unknown"
        
        return calculateStats(
            childId: childId,
            childName: childName,
            allStats: allStats,
            allGames: allGames
        )
    }
    
    private func fetchPlayers(for childId: UUID) throws -> [Player] {
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.predicate = NSPredicate(format: "childId == %@", childId as CVarArg)
        return try context.fetch(request)
    }

    private func fetchAllStats(for playerIds: [UUID]) throws -> [StatEvent] {
        let request = NSFetchRequest<StatEvent>(entityName: "StatEvent")
        request.predicate = NSPredicate(format: "player.id IN %@ AND isDelete == false", playerIds)
        return try context.fetch(request)
    }

    private func fetchGames(ids: [UUID]) throws -> [Game] {
        let request = NSFetchRequest<Game>(entityName: "Game")
        request.predicate = NSPredicate(format: "id IN %@ AND isComplete == true", ids)
        return try context.fetch(request)
    }

    private func calculateStats(
        childId: UUID,
        childName: String,
        allStats: [StatEvent],
        allGames: [Game]
    ) -> CareerStats {
        var points = 0, rebounds = 0, assists = 0, steals = 0, blocks = 0, turnovers = 0, fouls = 0
        var fgMade = 0, fgAttempted = 0
        var threeMade = 0, threeAttempted = 0
        var ftMade = 0, ftAttempted = 0
        
        var careerHighPoints = 0, careerHighRebounds = 0, careerHighAssists = 0

        for stat in allStats {
            guard let typeString = stat.statType,
                  let type = StatType(rawValue: typeString) else { continue }

            switch type {
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
                // Team points are scored by other players, not the focus child
                // These are already counted in the per-player stats
                break
            }
        }

        let gameCount = Double(allGames.count)
        
        // Calculate career highs
        var gameStats: [UUID: (points: Int, rebounds: Int, assists: Int)] = [:]
        
        for stat in allStats {
            guard let gameId = stat.gameId,
                  let typeString = stat.statType,
                  let type = StatType(rawValue: typeString) else { continue }
            
            var current = gameStats[gameId] ?? (points: 0, rebounds: 0, assists: 0)
            
            switch type {
            case .freeThrowMade:
                current.points += 1
            case .twoPointMade:
                current.points += 2
            case .threePointMade:
                current.points += 3
            case .rebound:
                current.rebounds += 1
            case .assist:
                current.assists += 1
            default:
                break
            }
            
            gameStats[gameId] = current
        }
        
        careerHighPoints = gameStats.values.map { $0.points }.max() ?? 0
        careerHighRebounds = gameStats.values.map { $0.rebounds }.max() ?? 0
        careerHighAssists = gameStats.values.map { $0.assists }.max() ?? 0
        
        // Calculate team stats (performance per team)
        var teamStatsDict: [UUID: (name: String, season: String, org: String?, games: Int, wins: Int, losses: Int)] = [:]
        
        for game in allGames {
            guard let teamId = game.teamId else { continue }
            
            var current = teamStatsDict[teamId] ?? (
                name: game.team?.name ?? "Unknown",
                season: game.team?.season ?? "",
                org: game.team?.organization,
                games: 0,
                wins: 0,
                losses: 0
            )
            
            current.games += 1
            
            if game.result == .win {
                current.wins += 1
            } else if game.result == .loss {
                current.losses += 1
            }
            
            teamStatsDict[teamId] = current
        }
        
        let teamStatsArray = teamStatsDict.map { (teamId, stats) -> TeamSeasonStats in
            let teamGames = allGames.filter { $0.teamId == teamId }
            let teamEvents = allStats.filter { event in
                teamGames.contains { $0.id == event.gameId }
            }
            
            var teamPoints = 0, teamRebounds = 0, teamAssists = 0
            for event in teamEvents {
                guard let typeString = event.statType,
                      let type = StatType(rawValue: typeString) else { continue }
                
                teamPoints += type.pointValue
                if type == .rebound { teamRebounds += 1 }
                if type == .assist { teamAssists += 1 }
            }
            
            let gamesCount = Double(stats.games)
            
            return TeamSeasonStats(
                teamName: stats.name,
                season: stats.season,
                organization: stats.org,
                games: stats.games,
                wins: stats.wins,
                losses: stats.losses,
                pointsPerGame: gamesCount > 0 ? Double(teamPoints) / gamesCount : 0,
                reboundsPerGame: gamesCount > 0 ? Double(teamRebounds) / gamesCount : 0,
                assistsPerGame: gamesCount > 0 ? Double(teamAssists) / gamesCount : 0
            )
        }

        return CareerStats(
            childId: childId,
            childName: childName,
            totalGames: allGames.count,
            pointsPerGame: gameCount > 0 ? Double(points) / gameCount : 0,
            reboundsPerGame: gameCount > 0 ? Double(rebounds) / gameCount : 0,
            assistsPerGame: gameCount > 0 ? Double(assists) / gameCount : 0,
            stealsPerGame: gameCount > 0 ? Double(steals) / gameCount : 0,
            blocksPerGame: gameCount > 0 ? Double(blocks) / gameCount : 0,
            totalPoints: points,
            totalRebounds: rebounds,
            totalAssists: assists,
            totalSteals: steals,
            totalBlocks: blocks,
            totalTurnovers: turnovers,
            totalFouls: fouls,
            fieldGoalMade: fgMade,
            fieldGoalAttempted: fgAttempted,
            fieldGoalPercentage: fgAttempted > 0 ? Double(fgMade) / Double(fgAttempted) * 100 : 0,
            threePointMade: threeMade,
            threePointAttempted: threeAttempted,
            threePointPercentage: threeAttempted > 0 ? Double(threeMade) / Double(threeAttempted) * 100 : 0,
            freeThrowMade: ftMade,
            freeThrowAttempted: ftAttempted,
            freeThrowPercentage: ftAttempted > 0 ? Double(ftMade) / Double(ftAttempted) * 100 : 0,
            careerHighPoints: careerHighPoints,
            careerHighRebounds: careerHighRebounds,
            careerHighAssists: careerHighAssists,
            teamStats: teamStatsArray
        )
    }
}

enum CareerError: Error {
    case noData
}
