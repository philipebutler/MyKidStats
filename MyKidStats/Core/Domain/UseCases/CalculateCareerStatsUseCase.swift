import Foundation
import CoreData

struct CareerStats {
    let childId: UUID
    let childName: String
    let totalGames: Int
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
    let totalPoints: Int
    let totalRebounds: Int
    let totalAssists: Int
    let fieldGoalPercentage: Double
    let threePointPercentage: Double
    let freeThrowPercentage: Double
}

class CalculateCareerStatsUseCase {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }

    func execute(for childId: UUID) async throws -> CareerStats {
        let players = Player.fetchForChild(childId, context: context)
        guard !players.isEmpty else { throw CareerError.noData }

        let playerIds = players.map { $0.id }
        let allStats = try fetchAllStats(for: playerIds)

        let gameIds = Set(allStats.map { $0.gameId })
        let allGames = try fetchGames(ids: Array(gameIds))

        return calculateStats(
            childId: childId,
            childName: players.first?.child?.name ?? "",
            allStats: allStats,
            allGames: allGames
        )
    }

    private func fetchAllStats(for playerIds: [UUID]) throws -> [StatEvent] {
        let request = StatEvent.fetchRequest()
        request.predicate = NSPredicate(format: "playerId IN %@ AND isDeleted == false", playerIds)
        return try context.fetch(request)
    }

    private func fetchGames(ids: [UUID]) throws -> [Game] {
        let request = Game.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@ AND isComplete == true", ids)
        return try context.fetch(request)
    }

    private func calculateStats(
        childId: UUID,
        childName: String,
        allStats: [StatEvent],
        allGames: [Game]
    ) -> CareerStats {
        var points = 0, rebounds = 0, assists = 0
        var fgMade = 0, fgAttempted = 0
        var threeMade = 0, threeAttempted = 0
        var ftMade = 0, ftAttempted = 0

        for stat in allStats {
            guard let type = StatType(rawValue: stat.statType) else { continue }

            switch type {
            case .freeThrowMade: ftMade += 1; ftAttempted += 1; points += 1
            case .freeThrowMiss: ftAttempted += 1
            case .twoPointMade: fgMade += 1; fgAttempted += 1; points += 2
            case .twoPointMiss: fgAttempted += 1
            case .threePointMade: threeMade += 1; threeAttempted += 1; fgMade += 1; fgAttempted += 1; points += 3
            case .threePointMiss: threeAttempted += 1; fgAttempted += 1
            case .rebound: rebounds += 1
            case .assist: assists += 1
            default: break
            }
        }

        let gameCount = Double(allGames.count)

        return CareerStats(
            childId: childId,
            childName: childName,
            totalGames: allGames.count,
            pointsPerGame: gameCount > 0 ? Double(points) / gameCount : 0,
            reboundsPerGame: gameCount > 0 ? Double(rebounds) / gameCount : 0,
            assistsPerGame: gameCount > 0 ? Double(assists) / gameCount : 0,
            totalPoints: points,
            totalRebounds: rebounds,
            totalAssists: assists,
            fieldGoalPercentage: fgAttempted > 0 ? Double(fgMade) / Double(fgAttempted) * 100 : 0,
            threePointPercentage: threeAttempted > 0 ? Double(threeMade) / Double(threeAttempted) * 100 : 0,
            freeThrowPercentage: ftAttempted > 0 ? Double(ftMade) / Double(ftAttempted) * 100 : 0
        )
    }
}

enum CareerError: Error {
    case noData
}
