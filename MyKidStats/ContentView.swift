//
//  ContentView.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/23/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            LiveGameTabView()
                .tabItem {
                    Label("Live", systemImage: "play.circle.fill")
                }
                .tag(AppTab.live)

            TeamsView()
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }
                .tag(AppTab.teams)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.stats)
        }
        .environmentObject(coordinator)
    }
}

// HomeView is provided in Features/Home/HomeView.swift

// Placeholder views for tabs

struct TeamsView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var teams: [Team] = []
    
    var body: some View {
        NavigationStack {
            List {
                if teams.isEmpty {
                    emptyState
                } else {
                    ForEach(teams, id: \.id) { team in
                        NavigationLink(destination: TeamDetailView(team: team)) {
                            TeamDetailRow(team: team)
                        }
                    }
                }
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { coordinator.showCreateTeam() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                loadTeams()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
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
            
            Text("Create teams to track games and stats")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: { coordinator.showCreateTeam() }) {
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
        let request = NSFetchRequest<Team>(entityName: "Team")
        request.predicate = NSPredicate(format: "isActive == true")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        teams = (try? context.fetch(request)) ?? []
    }
}

struct TeamDetailRow: View {
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill((team.colorHex != nil ? Color(hex: team.colorHex!) : nil) ?? Color.blue)
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
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Spacer()
            }
            
            HStack {
                Label(team.season ?? "Season", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                
                // Player count
                Text("\(team.players?.count ?? 0) players")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Team Detail View

struct TeamDetailView: View {
    @Environment(\.managedObjectContext) private var context
    let team: Team
    @State private var players: [Player] = []
    @State private var allChildren: [Child] = []
    @State private var showingAddPlayer = false
    @State private var showingAddChild = false
    @State private var editingPlayer: Player?
    @State private var playerToDelete: Player?
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Team Info")) {
                HStack {
                    Text("Name")
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text(team.name ?? "")
                }
                
                HStack {
                    Text("Season")
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text(team.season ?? "")
                }
                
                if let org = team.organization {
                    HStack {
                        Text("Organization")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        Text(org)
                    }
                }
            }
            
            Section(header: Text("Players (\(players.count))")) {
                if players.isEmpty {
                    VStack(spacing: 12) {
                        Text("No players on this team yet")
                            .foregroundColor(.secondaryText)
                            .italic()
                        Text("Add children first, then add them to this team")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    ForEach(players, id: \.id) { player in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(player.child?.name ?? "Unknown")
                                    .font(.headline)
                                HStack(spacing: 12) {
                                    if let jersey = player.jerseyNumber {
                                        Label(jersey, systemImage: "number")
                                            .font(.caption)
                                            .foregroundColor(.secondaryText)
                                    }
                                    if let position = player.position {
                                        Label(position, systemImage: "figure.run")
                                            .font(.caption)
                                            .foregroundColor(.secondaryText)
                                    }
                                }
                            }
                            Spacer()
                            Button(action: { editingPlayer = player }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.borderless)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                playerToDelete = player
                                showDeleteAlert = true
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
                
                Button(action: { 
                    if allChildren.isEmpty {
                        showingAddChild = true
                    } else {
                        showingAddPlayer = true
                    }
                }) {
                    Label("Add Player to Team", systemImage: "person.badge.plus")
                }
            }
            
            Section {
                Button(action: { showingAddChild = true }) {
                    Label("Manage All Children", systemImage: "person.2")
                }
            }
        }
        .navigationTitle(team.name ?? "Team")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPlayers()
            loadChildren()
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerToTeamView(team: team, availableChildren: availableChildren) {
                loadPlayers()
            }
        }
        .sheet(item: $editingPlayer) { player in
            EditPlayerView(player: player) {
                loadPlayers()
            }
        }
        .sheet(isPresented: $showingAddChild) {
            ManageChildrenView()
                .onDisappear {
                    loadChildren()
                }
        }
        .alert("Remove Player", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let player = playerToDelete {
                    deletePlayer(player)
                }
            }
        } message: {
            if let player = playerToDelete {
                Text("Remove \(player.child?.name ?? "this player") from \(team.name ?? "this team")? This won't delete the child, just removes them from this team.")
            }
        }
    }
    
    private var availableChildren: [Child] {
        let playerChildIds = Set(players.compactMap { $0.childId })
        return allChildren.filter { child in
            guard let childId = child.id else { return false }
            return !playerChildIds.contains(childId)
        }
    }
    
    private func loadPlayers() {
        guard let teamId = team.id else { return }
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.predicate = NSPredicate(format: "teamId == %@", teamId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "jerseyNumber", ascending: true)]
        players = (try? context.fetch(request)) ?? []
    }
    
    private func loadChildren() {
        let request = NSFetchRequest<Child>(entityName: "Child")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        allChildren = (try? context.fetch(request)) ?? []
    }
    
    private func deletePlayer(_ player: Player) {
        context.delete(player)
        do {
            try context.save()
            loadPlayers()
        } catch {
            print("Error deleting player: \(error)")
        }
    }
}

// MARK: - Edit Player View

struct EditPlayerView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    let player: Player
    var onSave: () -> Void
    
    @State private var jerseyNumber: String
    @State private var position: String
    
    init(player: Player, onSave: @escaping () -> Void) {
        self.player = player
        self.onSave = onSave
        _jerseyNumber = State(initialValue: player.jerseyNumber ?? "")
        _position = State(initialValue: player.position ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Player")) {
                    Text(player.child?.name ?? "Unknown")
                        .font(.headline)
                }
                
                Section(header: Text("Details")) {
                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                    TextField("Position (optional)", text: $position)
                }
            }
            .navigationTitle("Edit Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlayer()
                    }
                }
            }
        }
    }
    
    private func savePlayer() {
        player.jerseyNumber = jerseyNumber.isEmpty ? nil : jerseyNumber
        player.position = position.isEmpty ? nil : position
        
        do {
            try context.save()
            onSave()
            dismiss()
        } catch {
            print("Error saving player: \(error)")
        }
    }
}

// MARK: - Manage Children View

struct ManageChildrenView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var children: [Child] = []
    @State private var showingAddChild = false
    @State private var editingChild: Child?
    @State private var childToDelete: Child?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                if children.isEmpty {
                    VStack(spacing: 12) {
                        Text("No children added yet")
                            .foregroundColor(.secondaryText)
                            .italic()
                        Text("Add your child and their teammates")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    ForEach(children, id: \.id) { child in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(child.name ?? "")
                                    .font(.headline)
                                if let dob = child.dateOfBirth {
                                    Text(dob, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondaryText)
                                }
                            }
                            Spacer()
                            Button(action: { editingChild = child }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.borderless)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                childToDelete = child
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Children")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddChild = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                loadChildren()
            }
            .sheet(isPresented: $showingAddChild) {
                AddOrEditChildView(mode: .add) {
                    loadChildren()
                }
            }
            .sheet(item: $editingChild) { child in
                AddOrEditChildView(mode: .edit(child)) {
                    loadChildren()
                }
            }
            .alert("Delete Child", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let child = childToDelete {
                        deleteChild(child)
                    }
                }
            } message: {
                if let child = childToDelete {
                    Text("Delete \(child.name ?? "this child")? This will also remove them from all teams.")
                }
            }
        }
    }
    
    private func loadChildren() {
        let request = NSFetchRequest<Child>(entityName: "Child")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        children = (try? context.fetch(request)) ?? []
    }
    
    private func deleteChild(_ child: Child) {
        // Also delete associated players
        if let childId = child.id {
            let playerRequest = NSFetchRequest<Player>(entityName: "Player")
            playerRequest.predicate = NSPredicate(format: "childId == %@", childId as CVarArg)
            if let players = try? context.fetch(playerRequest) {
                players.forEach { context.delete($0) }
            }
        }
        
        context.delete(child)
        do {
            try context.save()
            loadChildren()
        } catch {
            print("Error deleting child: \(error)")
        }
    }
}

// MARK: - Add or Edit Child View

struct AddOrEditChildView: View {
    enum Mode {
        case add
        case edit(Child)
    }
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    var onSave: () -> Void
    
    @State private var name: String
    @State private var dateOfBirth: Date
    
    init(mode: Mode, onSave: @escaping () -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        if case .edit(let child) = mode {
            _name = State(initialValue: child.name ?? "")
            _dateOfBirth = State(initialValue: child.dateOfBirth ?? Date())
        } else {
            _name = State(initialValue: "")
            _dateOfBirth = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Child Information")) {
                    TextField("Name", text: $name)
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChild()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveChild() {
        switch mode {
        case .add:
            let child = Child(context: context)
            child.id = UUID()
            child.name = name
            child.dateOfBirth = dateOfBirth
        case .edit(let child):
            child.name = name
            child.dateOfBirth = dateOfBirth
        }
        
        do {
            try context.save()
            onSave()
            dismiss()
        } catch {
            print("Error saving child: \(error)")
        }
    }
}

extension AddOrEditChildView.Mode {
    var title: String {
        switch self {
        case .add: return "Add Child"
        case .edit: return "Edit Child"
        }
    }
}

// MARK: - Add Player to Team View

struct AddPlayerToTeamView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let team: Team
    let availableChildren: [Child]
    let onComplete: () -> Void
    
    @State private var selectedChild: Child?
    @State private var jerseyNumber: String = ""
    @State private var position: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                if availableChildren.isEmpty {
                    Section {
                        VStack(spacing: .spacingL) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.secondaryText)
                            
                            Text("No Children Available")
                                .font(.headline)
                            
                            Text("All your children are already on this team, or you need to add children first.")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                } else {
                    Section(header: Text("Select Child")) {
                        ForEach(availableChildren, id: \.id) { child in
                            Button(action: { selectedChild = child }) {
                                HStack {
                                    Text(child.name ?? "Unknown")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedChild?.id == child.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    if selectedChild != nil {
                        Section(header: Text("Player Details (Optional)")) {
                            TextField("Jersey Number", text: $jerseyNumber)
                                .keyboardType(.numberPad)
                            
                            TextField("Position", text: $position)
                                .autocapitalization(.words)
                        }
                    }
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addPlayer()
                    }
                    .disabled(selectedChild == nil)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addPlayer() {
        guard let child = selectedChild,
              let childId = child.id,
              let teamId = team.id else {
            errorMessage = "Invalid selection"
            showError = true
            return
        }
        
        let player = Player(context: context)
        player.id = UUID()
        player.childId = childId
        player.teamId = teamId
        player.child = child  // Set the Core Data relationship
        player.team = team    // Set the team relationship
        player.jerseyNumber = jerseyNumber.isEmpty ? nil : jerseyNumber
        player.position = position.isEmpty ? nil : position
        player.createdAt = Date()
        
        do {
            try context.save()
            onComplete()
            dismiss()
        } catch {
            errorMessage = "Failed to add player: \(error.localizedDescription)"
            showError = true
        }
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title2)
            Text("App settings and debug tools")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    ContentView()
}
