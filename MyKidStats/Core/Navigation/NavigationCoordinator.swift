import Foundation
import SwiftUI
import CoreData
import Combine

enum AppTab {
    case home
    case live
    case stats
    case teams
}

@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var presentedSheet: PresentedSheet?

    func showGameSummary(_ game: Game) {
        presentedSheet = .gameSummary(game)
    }

    func showCreateTeam() {
        presentedSheet = .createTeam
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}

enum PresentedSheet: Identifiable {
    case gameSummary(Game)
    case createTeam
    case addChild
    case settings

    var id: String {
        switch self {
        case .gameSummary(let game):
            return "gameSummary_\(game.id?.uuidString ?? "unknown")"
        case .createTeam:
            return "createTeam"
        case .addChild:
            return "addChild"
        case .settings:
            return "settings"
        }
    }
}
