import SwiftUI
import CoreData

struct LiveGameTabView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var activeGames: [Game] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if activeGames.isEmpty {
                    emptyState
                } else {
                    activeGamesList
                }
            }
            .navigationTitle("Live Game")
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
    
    private var activeGamesList: some View {
        List {
            ForEach(activeGames, id: \.id) { game in
                NavigationLink {
                    if let player = getPlayer(for: game) {
                        LiveGameView(game: game, focusPlayer: player)
                    } else {
                        Text("Error loading game")
                    }
                } label: {
                    ActiveGameRow(game: game)
                }
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
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.predicate = NSPredicate(
            format: "childId == %@ AND teamId == %@",
            game.focusChildId as CVarArg,
            game.teamId as CVarArg
        )
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
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
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    LiveGameTabView()
        .environment(\.managedObjectContext, CoreDataStack.shared.mainContext)
}
