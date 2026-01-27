import Foundation

class ExportGameCSVUseCase {
    func execute(_ game: Game) throws -> URL {
        let csvString = generateCSV(game)
        return try saveToFile(csvString, filename: makeFilename(game))
    }

    private func generateCSV(_ game: Game) -> String {
        var csv = "Game Statistics\n"
        csv += "Date,Opponent,Player,Points,FGM,FGA,FG%,REB,AST\n"

        guard let events = game.statEvents as? Set<StatEvent> else { return csv }
        let playerIds = Set(events.map { $0.playerId })

        for playerId in playerIds {
            let playerEvents = events.filter { $0.playerId == playerId && !$0.isSoftDeleted }
            let stats = calculateStats(Array(playerEvents))
            let player = events.first { $0.playerId == playerId }?.player

            csv += "\(formatDate(game.gameDate!)),"
            csv += "\(escape(game.opponentName!)),"
               csv += "\(player?.child?.name ?? "Unknown"),"
            csv += "\(stats.points),"
            csv += "\(stats.fgMade),\(stats.fgAttempted),\(format(stats.fgPercentage)),"
            csv += "\(stats.rebounds),\(stats.assists)\n"
        }

        return csv
    }

    private func calculateStats(_ events: [StatEvent]) -> LiveStats {
        var stats = LiveStats()
        for event in events {
            guard let statType = event.statType, let type = StatType(rawValue: statType) else { continue }
            stats.recordStat(type)
        }
        return stats
    }

    private func escape(_ value: String) -> String {
        value.contains(",") ? "\"\(value)\"" : value
    }

    private func format(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }

    private func makeFilename(_ game: Game) -> String {
        let opponent = game.opponentName!.replacingOccurrences(of: " ", with: "_")
        let date = formatDate(game.gameDate!).replacingOccurrences(of: "/", with: "-")
        return "\(opponent)_\(date).csv"
    }

    private func saveToFile(_ content: String, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
