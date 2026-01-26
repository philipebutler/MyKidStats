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

    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        loadData()
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
        // TODO: Implement in Part 3
        print("Starting game for \(child.name ?? "")")
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
        // TODO: Implement in Part 3
        print("Show add child")
    }

    func viewGameSummary(_ game: Game) {
        // TODO: Implement in Part 3
        print("View game summary")
    }

    func openSettings() {
        // TODO: Implement in Part 3
        print("Open settings")
    }

    private func fetchLastGame(for childId: UUID) -> Game? {
        let request = Game.fetchRequest()
        request.predicate = NSPredicate(
            format: "focusChildId == %@ AND isComplete == true",
            childId as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "gameDate", ascending: false)]
        request.fetchLimit = 1
        let results = try? context.fetch(request) as? [Game]
        return results?.first
    }
}

struct RecentActivity: Identifiable {
    let id = UUID()
    let icon: String
    let description: String
    let timeAgo: String
}
