//
//  NewGameView.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/31/26.
//

import SwiftUI
import CoreData

struct NewGameView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var coordinator: NavigationCoordinator
    let child: Child
    
    @State private var teams: [Team] = []
    @State private var selectedTeam: Team?
    @State private var opponentName: String = ""
    @FocusState private var isOpponentFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Team")) {
                    if teams.isEmpty {
                        Text("No teams available")
                            .foregroundColor(.secondaryText)
                        
                        Text("Please create a team first from the Teams tab")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    } else {
                        Picker("Select Team", selection: $selectedTeam) {
                            Text("Choose team...").tag(nil as Team?)
                            ForEach(teams, id: \.id) { team in
                                teamPickerRow(team)
                                    .tag(team as Team?)
                            }
                        }
                    }
                }
                
                Section(header: Text("Opponent")) {
                    TextField("Enter opponent name", text: $opponentName)
                        .focused($isOpponentFieldFocused)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Start New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        coordinator.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        createGameAndNavigate()
                    }
                    .disabled(!isValid)
                    .bold()
                }
            }
            .onAppear {
                loadTeams()
            }
        }
    }
    
    private var isValid: Bool {
        selectedTeam != nil && !opponentName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func teamPickerRow(_ team: Team) -> some View {
        HStack {
            if let colorHex = team.colorHex, let color = Color(hex: colorHex) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            } else {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
            }
            Text(team.name ?? "Team")
        }
    }
    
    private func loadTeams() {
        // Get all active teams for this child
        let playerRequest = NSFetchRequest<Player>(entityName: "Player")
        guard let childId = child.id else { return }
        playerRequest.predicate = NSPredicate(format: "childId == %@", childId as CVarArg)
        
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
        
        // Auto-select if only one team
        if teams.count == 1 {
            selectedTeam = teams.first
        }
    }
    
    private func createGameAndNavigate() {
        guard let team = selectedTeam else { return }
        
        // Check if there's already an active game
        let activeGameRequest = NSFetchRequest<Game>(entityName: "Game")
        activeGameRequest.predicate = NSPredicate(format: "isComplete == false")
        activeGameRequest.fetchLimit = 1
        
        if let existingGame = try? context.fetch(activeGameRequest).first {
            // Complete the existing game automatically
            existingGame.isComplete = true
            existingGame.updatedAt = Date()
        }
        
        // Find player instance for this child on this team
        let playerRequest = NSFetchRequest<Player>(entityName: "Player")
        guard let childId = child.id, let teamId = team.id else { return }
        playerRequest.predicate = NSPredicate(
            format: "childId == %@ AND teamId == %@",
            childId as CVarArg,
            teamId as CVarArg
        )
        playerRequest.relationshipKeyPathsForPrefetching = ["child", "team"]
        
        guard let player = try? context.fetch(playerRequest).first else {
            print("Error: No player found for child on team")
            return
        }
        
        // Create new game
        let game = Game(context: context)
        game.id = UUID()
        game.teamId = team.id
        game.team = team  // Set the relationship explicitly
        game.focusChildId = child.id
        game.opponentName = opponentName.trimmingCharacters(in: .whitespaces)
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
            
            // Dismiss sheet
            coordinator.dismissSheet()
            
            // Navigate to Live tab - it will automatically show the active game
            coordinator.selectedTab = .live
            
        } catch {
            print("Error creating game: \(error)")
        }
    }
}

struct NewGameView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.createInMemoryStack().mainContext
        let coordinator = NavigationCoordinator()
        
        let child = Child(context: context)
        child.id = UUID()
        child.name = "Alex"
        
        let team = Team(context: context)
        team.id = UUID()
        team.name = "Warriors"
        team.colorHex = "#0000FF"
        
        let player = Player(context: context)
        player.id = UUID()
        player.childId = child.id
        player.teamId = team.id
        
        try? context.save()
        
        return NewGameView(coordinator: coordinator, child: child)
            .environment(\.managedObjectContext, context)
    }
}
