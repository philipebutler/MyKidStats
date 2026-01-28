//
//  SelectTeamView.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/26/26.
//

import SwiftUI
import CoreData

struct SelectTeamView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var coordinator: NavigationCoordinator
    let child: Child
    
    @State private var teams: [Team] = []
    @State private var showCreateTeam = false
    
    var body: some View {
        NavigationStack {
            List {
                if teams.isEmpty {
                    emptyState
                } else {
                    ForEach(teams, id: \.id) { team in
                        TeamRow(team: team) {
                            createGameAndNavigate(for: team)
                        }
                    }
                }
            }
            .navigationTitle("Select Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        coordinator.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreateTeam = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTeam) {
                CreateTeamView(child: child, coordinator: coordinator) { newTeam in
                    teams.append(newTeam)
                    createGameAndNavigate(for: newTeam)
                }
            }
            .onAppear {
                loadTeams()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("No Teams Yet")
                .font(.title2)
            
            Text("Create a team to start tracking games")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: { showCreateTeam = true }) {
                Label("Create Team", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private func loadTeams() {
        // Get all active teams for this child
        let playerRequest = NSFetchRequest<Player>(entityName: "Player")
        playerRequest.predicate = NSPredicate(format: "childId == %@", child.id as CVarArg)
        
        guard let players = try? context.fetch(playerRequest) else {
            teams = []
            return
        }
        
        let teamIds = Array(Set(players.compactMap { $0.teamId }))
        
        if teamIds.isEmpty {
            teams = []
            return
        }
        
        let teamRequest = NSFetchRequest<Team>(entityName: "Team")
        teamRequest.predicate = NSPredicate(format: "id IN %@ AND isActive == true", teamIds)
        teamRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        teams = (try? context.fetch(teamRequest)) ?? []
    }
    
    private func createGameAndNavigate(for team: Team) {
        // Find or create player instance for this child on this team
        let playerRequest = NSFetchRequest<Player>(entityName: "Player")
        playerRequest.predicate = NSPredicate(
            format: "childId == %@ AND teamId == %@",
            child.id as CVarArg,
            team.id as CVarArg
        )
        
        guard let player = try? context.fetch(playerRequest).first else {
            print("Error: No player found for child on team")
            return
        }
        
        // Create new game
        let game = Game(context: context)
        game.id = UUID()
        game.teamId = team.id
        game.focusChildId = child.id
        game.opponentName = "Opponent" // User can edit in live game
        game.opponentScore = 0
        game.gameDate = Date()
        game.isComplete = false
        game.duration = 0
        game.createdAt = Date()
        game.updatedAt = Date()
        
        // Save
        do {
            try context.save()
            
            // Update last used for child
            try? child.markAsUsed(context: context)
            
            // Dismiss sheet and navigate
            coordinator.dismissSheet()
            coordinator.selectedTab = .live
            
        } catch {
            print("Error creating game: \(error)")
        }
    }
}

struct TeamRow: View {
    let team: Team
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(team.colorHex != nil ? Color(hex: team.colorHex!) : Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(team.name?.prefix(1).uppercased() ?? "T")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name ?? "Team")
                        .font(.headline)
                    
                    if let org = team.organization {
                        Text(org)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Text(team.season ?? "Season")
                        .font(.caption2)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// Helper extension for hex colors
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    let context = CoreDataStack.createInMemoryStack().mainContext
    let coordinator = NavigationCoordinator()
    
    let child = Child(context: context)
    child.id = UUID()
    child.name = "Sam"
    
    return SelectTeamView(coordinator: coordinator, child: child)
        .environment(\.managedObjectContext, context)
}
