import SwiftUI
import CoreData

struct LiveGameTabView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var activeGames: [Game] = []
    @State private var navigateToGame: Game?
    
    var body: some View {
        NavigationStack {
            Group {
                if activeGames.isEmpty {
                    emptyState
                } else if activeGames.count == 1, let game = activeGames.first {
                    // Single active game - navigate directly to it
                    if let player = getPlayer(for: game) {
                        LiveGameView(game: game, focusPlayer: player)
                            .navigationTitle("Live Game")
                            .navigationBarTitleDisplayMode(.inline)
                    } else {
                        errorView
                    }
                } else {
                    // Multiple active games - show list
                    activeGamesList
                }
            }
            .onAppear {
                loadActiveGames()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                loadActiveGames()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("No Active Games")
                .font(.title2)
            
            Text("Start a game from the Home tab")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
    
    private var errorView: some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Error Loading Game")
                .font(.title2)
            
            Text("Could not find player information")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
    
    private var activeGamesList: some View {
        List {
            ForEach(activeGames, id: \.id) { game in
                ZStack {
                    NavigationLink {
                        if let player = getPlayer(for: game) {
                            LiveGameView(game: game, focusPlayer: player)
                        } else {
                            Text("Error loading game")
                        }
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    ActiveGameRow(game: game)
                }
                .listRowInsets(EdgeInsets())
            }
        }
    }
    
    private func loadActiveGames() {
        let request = NSFetchRequest<Game>(entityName: "Game")
        request.predicate = NSPredicate(format: "isComplete == false")
        request.sortDescriptors = [NSSortDescriptor(key: "gameDate", ascending: false)]
        
        activeGames = (try? context.fetch(request)) ?? []
    }
    
    private func getPlayer(for game: Game) -> Player? {
        guard let focusChildId = game.focusChildId,
              let teamId = game.teamId else {
            return nil
        }
        
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.predicate = NSPredicate(
            format: "childId == %@ AND teamId == %@",
            focusChildId as CVarArg,
            teamId as CVarArg
        )
        request.relationshipKeyPathsForPrefetching = ["child", "team"]  // Ensure relationships are loaded
        request.fetchLimit = 1
        
        guard let player = try? context.fetch(request).first else {
            return nil
        }
        
        // Ensure child relationship is set if not already
        if player.child == nil {
            let childRequest = NSFetchRequest<Child>(entityName: "Child")
            childRequest.predicate = NSPredicate(format: "id == %@", focusChildId as CVarArg)
            if let child = try? context.fetch(childRequest).first {
                player.child = child
            }
        }
        
        return player
    }
}
struct ActiveGameRow: View {
    let game: Game
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(game.team?.name ?? "Team") vs \(game.opponentName ?? "Opponent")")
                    .font(.headline)
                
                HStack {
                    Text("\(game.calculatedTeamScore)")
                        .font(.title3)
                        .bold()
                    Text("-")
                        .foregroundColor(.secondaryText)
                    Text("\(game.opponentScore)")
                        .font(.title3)
                        .bold()
                }
                
                if let date = game.gameDate {
                    Text(date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            Text("GO")
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .cornerRadius(8)
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .contentShape(Rectangle())
    }
}

#Preview {
    LiveGameTabView()
        .environment(\.managedObjectContext, CoreDataStack.shared.mainContext)
}
