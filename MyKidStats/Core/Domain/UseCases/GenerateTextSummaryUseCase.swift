import Foundation

class GenerateTextSummaryUseCase {
    func execute(game: Game, focusChild: Child) -> String {
        guard let events = game.statEvents as? Set<StatEvent>,
              let team = game.team else {
            return "Game summary unavailable"
        }

        let focusPlayers = (team.players as? Set<Player>)?.filter { $0.childId == focusChild.id } ?? []
        guard let focusPlayer = focusPlayers.first else {
            return "Player not found"
        }

        let playerEvents = events.filter { $0.playerId == focusPlayer.id && !$0.isSoftDeleted }
        let stats = calculateStats(Array(playerEvents))

        return """
        🏀 \(focusChild.name ?? "")'s Game - \(formatDate(game.gameDate!))

        \(team.name) \(game.teamScore), \(game.opponentName) \(game.opponentScore) \(game.result.emoji)

        \(focusChild.name ?? ""): \(stats.points) PTS, \(stats.rebounds) REB, \(stats.assists) AST
        \(stats.fgMade)-\(stats.fgAttempted) FG (\(Int(stats.fgPercentage))%) | \(stats.ftMade)-\(stats.ftAttempted) FT
        """
    }

    private func calculateStats(_ events: [StatEvent]) -> LiveStats {
        var stats = LiveStats()
        for event in events {
            guard let statType = event.statType, let type = StatType(rawValue: statType) else { continue }
            stats.recordStat(type)
        }
        return stats
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
