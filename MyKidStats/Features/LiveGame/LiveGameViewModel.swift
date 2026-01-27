import Foundation
import CoreData
import UIKit
import Combine

@MainActor
class LiveGameViewModel: ObservableObject {
    @Published var game: Game
    @Published var focusPlayer: Player
    @Published var teamPlayers: [Player] = []
    @Published var opponentScore: Int = 0
    @Published var teamScore: Int = 0
    @Published var canUndo: Bool = false
    @Published var currentStats: LiveStats = LiveStats()
    @Published var teamScores: [UUID: Int] = [:]

    private let context: NSManagedObjectContext
    private var lastAction: UndoAction?
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    init(
        game: Game,
        focusPlayer: Player,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.game = game
        self.focusPlayer = focusPlayer
        self.context = context

        hapticGenerator.prepare()
        loadGameData()
    }

    private func loadGameData() {
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.predicate = NSPredicate(format: "teamId == %@", game.teamId! as CVarArg)
        teamPlayers = (try? context.fetch(request)) ?? []

        loadExistingStats()

        opponentScore = Int(game.opponentScore)
        teamScore = game.calculatedTeamScore
    }

    private func loadExistingStats() {
        guard let events = game.statEvents as? Set<StatEvent> else { return }

        let focusEvents = events.filter { $0.playerId == focusPlayer.id && !$0.isSoftDeleted }
        currentStats = LiveStats()
        for event in focusEvents {
            guard let typeString = event.statType,
                  let type = StatType(rawValue: typeString) else { continue }
            currentStats.recordStat(type)
        }

        for player in teamPlayers where player.id != focusPlayer.id {
            guard let playerId = player.id else { continue }
            let playerEvents = events.filter { $0.playerId == playerId && !$0.isSoftDeleted }
            let score = playerEvents.reduce(0) { $0 + Int($1.value) }
            teamScores[playerId] = score
        }
    }

    func recordFocusPlayerStat(_ statType: StatType) {
        hapticGenerator.impactOccurred()

        let event = StatEvent(context: context)
        event.id = UUID()
        event.playerId = focusPlayer.id
        event.gameId = game.id
        event.timestamp = Date()
        event.statType = statType.rawValue
        event.value = Int32(statType.pointValue)
        event.isSoftDeleted = false

        currentStats.recordStat(statType)
        teamScore += statType.pointValue

        lastAction = .focusPlayerStat(eventId: event.id!, statType: statType)
        canUndo = true

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            if self.context.hasChanges {
                try? self.context.save()
            }
        }
    }

    func recordTeamPlayerScore(_ playerId: UUID, points: Int) {
        hapticGenerator.impactOccurred()

        let statType: StatType = points == 1 ? .freeThrowMade : (points == 3 ? .threePointMade : .twoPointMade)

        let event = StatEvent(context: context)
        event.id = UUID()
        event.playerId = playerId
        event.gameId = game.id
        event.timestamp = Date()
        event.statType = statType.rawValue
        event.value = Int32(points)
        event.isSoftDeleted = false

        teamScores[playerId, default: 0] += points
        teamScore += points
        lastAction = .teamScore(eventId: event.id!, playerId: playerId, points: points)
        canUndo = true

        Task.detached(priority: .userInitiated) { [weak self] in
            try? self?.context.save()
        }
    }

    func recordOpponentScore(_ points: Int) {
        hapticGenerator.impactOccurred()
        opponentScore += points
        lastAction = .opponentScore(points: points)
        canUndo = true

        game.opponentScore = Int32(opponentScore)
        Task.detached(priority: .userInitiated) { [weak self] in
            try? self?.context.save()
        }
    }

    func undoLastAction() {
        guard let action = lastAction else { return }

        hapticGenerator.impactOccurred()

        switch action {
        case .focusPlayerStat(let eventId, let statType):
            softDeleteEvent(eventId)
            currentStats.reverseStat(statType)
            teamScore -= statType.pointValue

        case .teamScore(let eventId, let playerId, let points):
            softDeleteEvent(eventId)
            teamScores[playerId, default: 0] -= points
            teamScore -= points

        case .opponentScore(let points):
            opponentScore -= points
            game.opponentScore = Int32(opponentScore)
        }

        lastAction = nil
        canUndo = false

        Task.detached(priority: .userInitiated) { [weak self] in
            try? self?.context.save()
        }
    }

    func endGame() {
        game.isComplete = true
        game.updatedAt = Date()
        try? context.save()
    }

    private func softDeleteEvent(_ eventId: UUID) {
        let request = NSFetchRequest<StatEvent>(entityName: "StatEvent")
        request.predicate = NSPredicate(format: "id == %@", eventId as CVarArg)
        if let event = try? context.fetch(request).first {
            event.isSoftDeleted = true
        }
    }
}

// Supporting types
enum UndoAction {
    case focusPlayerStat(eventId: UUID, statType: StatType)
    case teamScore(eventId: UUID, playerId: UUID, points: Int)
    case opponentScore(points: Int)
}
