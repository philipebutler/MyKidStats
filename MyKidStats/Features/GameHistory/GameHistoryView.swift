//
//  GameHistoryView.swift
//  MyKidStats
//
//  Created by Copilot on 1/28/26.
//

import SwiftUI
import CoreData

struct GameHistoryView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var games: [Game] = []
    @State private var selectedChild: Child?
    
    var body: some View {
        List {
            if games.isEmpty {
                emptyState
            } else {
                ForEach(games, id: \.id) { game in
                    NavigationLink(destination: PastGameSummaryView(game: game)) {
                        GameHistoryRow(game: game)
                    }
                }
            }
        }
        .navigationTitle("Past Games")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadGames()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            loadGames()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("No Games Yet")
                .font(.title2)
            
            Text("Complete a game to see it here")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private func loadGames() {
        let request: NSFetchRequest<Game> = NSFetchRequest(entityName: "Game")
        request.predicate = NSPredicate(format: "isComplete == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "gameDate", ascending: false)]
        
        do {
            games = try context.fetch(request)
        } catch {
            print("Error loading games: \(error)")
        }
    }
}

struct GameHistoryRow: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            HStack {
                Text(formatDate(game.gameDate ?? Date()))
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                
                Text(game.result.emoji)
                    .font(.title3)
            }
            
            HStack {
                Text(game.team?.name ?? "Team")
                    .font(.headline)
                
                Text("\(game.calculatedTeamScore)")
                    .font(.headline.bold())
                
                Text("-")
                    .foregroundColor(.secondaryText)
                
                Text("\(game.opponentScore)")
                    .font(.headline.bold())
                
                Text(game.opponentName ?? "Opponent")
                    .font(.headline)
            }
            
            if let focusChild = getFocusChild() {
                let stats = calculateFocusPlayerStats()
                Text("\(focusChild.name ?? ""): \(stats.points) PTS, \(stats.rebounds) REB, \(stats.assists) AST")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.vertical, .spacingS)
    }
    
    private func getFocusChild() -> Child? {
        // Get the focus child from the game
        guard let focusChildId = game.focusChildId else { return nil }
        
        let request: NSFetchRequest<Child> = NSFetchRequest(entityName: "Child")
        request.predicate = NSPredicate(format: "id == %@", focusChildId as CVarArg)
        request.fetchLimit = 1
        
        guard let context = game.managedObjectContext else { return nil }
        return try? context.fetch(request).first
    }
    
    private func calculateFocusPlayerStats() -> LiveStats {
        guard let events = game.statEvents as? Set<StatEvent>,
              let focusChild = getFocusChild(),
              let team = game.team,
              let focusPlayer = (team.players as? Set<Player>)?.first(where: { $0.childId == focusChild.id }) else {
            return LiveStats()
        }
        
        let playerEvents = events.filter { $0.playerId == focusPlayer.id && !$0.isSoftDeleted }
        var stats = LiveStats()
        
        for event in playerEvents {
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

#Preview {
    NavigationStack {
        GameHistoryView()
            .environment(\.managedObjectContext, CoreDataStack.shared.mainContext)
    }
}
