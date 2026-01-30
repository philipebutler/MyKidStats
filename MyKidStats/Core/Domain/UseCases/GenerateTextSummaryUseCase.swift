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
        
        // Calculate points for all other team players
        let allPlayers = (team.players as? Set<Player>)?.filter { $0.id != focusPlayer.id } ?? []
        let otherPlayerStats = calculateOtherPlayersPoints(players: Array(allPlayers), events: Array(events))

        // Build the focus child's stats section
        var focusChildStats = """
        \(focusChild.name ?? ""): 
        \(stats.points) PTS, \(stats.fgMade)-\(stats.fgAttempted) FG (\(formatPercentage(stats.fgPercentage))) | \(stats.threeMade)-\(stats.threeAttempted) 3PT | \(stats.ftMade)-\(stats.ftAttempted) FT
        """
        
        // Add other stats on separate lines
        if stats.rebounds > 0 {
            focusChildStats += "\n\(stats.rebounds) REB"
        }
        if stats.assists > 0 {
            focusChildStats += "\n\(stats.assists) AST"
        }
        if stats.blocks > 0 {
            focusChildStats += "\n\(stats.blocks) BLK"
        }
        if stats.steals > 0 {
            focusChildStats += "\n\(stats.steals) STL"
        }
        
        // Build other players section
        var otherPlayersText = ""
        for playerStat in otherPlayerStats {
            if playerStat.points > 0 {
                otherPlayersText += "\n\(playerStat.name): \(playerStat.points) PTS"
            }
        }

        return """
        🏀 \(focusChild.name ?? "")'s Game - \(formatDate(game.gameDate!))
        
        \(team.name ?? "Team") \(game.calculatedTeamScore), \(game.opponentName ?? "Opponent") \(game.opponentScore) \(game.result.emoji)
        
        \(focusChildStats)\(otherPlayersText)
        """
    }

    private func calculateStats(_ events: [StatEvent]) -> LiveStats {
        var stats = LiveStats()
        for event in events {
            guard let statType = event.statType, let type = StatType(rawValue: statType) else { continue }
            stats.recordStat(type)
        }
        stats.updatePercentages()
        return stats
    }
    
    private func calculateOtherPlayersPoints(players: [Player], events: [StatEvent]) -> [(name: String, points: Int)] {
        var playerPoints: [(name: String, points: Int)] = []
        
        for player in players {
            guard let playerId = player.id else { continue }
            let playerEvents = events.filter { $0.playerId == playerId && !$0.isSoftDeleted }
            let stats = calculateStats(playerEvents)
            let playerName = player.child?.name ?? "Player #\(player.jerseyNumber ?? "?")"
            playerPoints.append((name: playerName, points: stats.points))
        }
        
        // Sort by points descending
        return playerPoints.sorted { $0.points > $1.points }
    }
    
    private func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.0f%%", percentage)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
