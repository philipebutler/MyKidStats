import Foundation
import CoreData
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var defaultChild: Child?
    @Published var otherChildren: [Child] = []
    @Published var lastGame: Game?
    @Published var recentActivities: [RecentActivity] = []

    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: NavigationCoordinator?

    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        loadData()
    }

    func setCoordinator(_ coordinator: NavigationCoordinator) {
        self.coordinator = coordinator
    }

    var hasMultipleChildren: Bool {
        !otherChildren.isEmpty
    }

    var otherChildName: String {
        otherChildren.first?.name ?? ""
    }

    func loadData() {
        // Load default child (last used)
        defaultChild = Child.fetchLastUsed(context: context)

        // Load all other children
        let allChildren = Child.fetchAll(context: context)
        otherChildren = allChildren.filter { $0.id != defaultChild?.id }

        // Load last game
        if let childId = defaultChild?.id {
            lastGame = fetchLastGame(for: childId)
        }

        // Load recent activities (simplified for now)
        recentActivities = []
    }

    func startGame(for child: Child) {
        coordinator?.presentedSheet = .selectTeam(child)
    }

    func toggleChild() {
        guard let other = otherChildren.first else { return }

        // Swap default and other
        let temp = defaultChild
        defaultChild = other
        otherChildren = temp.map { [$0] } ?? []

        // Update lastUsed
        try? defaultChild?.markAsUsed(context: context)

        // Reload data
        loadData()
    }

    func showAddChild() {
        coordinator?.presentedSheet = .addChild
    }

    func viewGameSummary(_ game: Game) {
        coordinator?.showGameSummary(game)
    }

    func openSettings() {
        coordinator?.presentedSheet = .settings
    }

    private func fetchLastGame(for childId: UUID) -> Game? {
        let request = NSFetchRequest<Game>(entityName: "Game")
        request.predicate = NSPredicate(
            format: "focusChildId == %@ AND isComplete == true",
            childId as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "gameDate", ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}

struct RecentActivity: Identifiable {
    let id = UUID()
    let icon: String
    let description: String
    let timeAgo: String
}
