import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacingXXL) {
                    smartStartSection

                    if let lastGame = viewModel.lastGame {
                        lastGameSection(lastGame)
                    }

                    if !viewModel.recentActivities.isEmpty {
                        recentActivitySection
                    }
                }
                .padding(.spacingL)
            }
            .background(Color.appBackground)
            .navigationTitle("Basketball Stats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.openSettings) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(item: $coordinator.presentedSheet) { sheet in
                sheetContent(for: sheet)
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                viewModel.loadData()
            }
        }
        .onAppear {
            viewModel.setCoordinator(coordinator)
        }
    }

    @ViewBuilder
    private func sheetContent(for sheet: PresentedSheet) -> some View {
        switch sheet {
        case .addChild:
            AddChildSheet(coordinator: coordinator, viewModel: viewModel)
        case .settings:
            SettingsSheet(coordinator: coordinator)
        case .gameSummary(let game):
            GameSummarySheet(game: game, coordinator: coordinator)
        case .createTeam:
            Text("Create Team coming soon")
        case .selectTeam(let child):
            SelectTeamSheet(child: child, coordinator: coordinator)
        }
    }

    private var smartStartSection: some View {
        VStack(alignment: .leading, spacing: .spacingL) {
            Text("Ready for today's game?")
                .font(.title2)

            if let defaultChild = viewModel.defaultChild {
                PrimaryButton(
                    title: "Start Game for \(defaultChild.name ?? "")",
                    icon: "play.circle.fill"
                ) {
                    viewModel.startGame(for: defaultChild)
                }

                if viewModel.hasMultipleChildren {
                    Button(action: viewModel.toggleChild) {
                        HStack {
                            Text("Switch to \(viewModel.otherChildName)")
                            Image(systemName: "arrow.right")
                        }
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(.cornerRadiusButton)
                    }
                }
            } else {
                VStack(spacing: .spacingL) {
                    Text("Let's get started!")
                        .font(.headline)

                    Text("Add a child to start tracking their basketball stats.")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)

                    PrimaryButton(
                        title: "Add Your First Child",
                        icon: "plus.circle.fill"
                    ) {
                        viewModel.showAddChild()
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(.cornerRadiusCard)
            }
        }
    }

    private func lastGameSection(_ game: Game) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Last Game:")
                .font(.headline)
                .foregroundColor(.secondaryText)

            GameCard(
                teamName: game.team?.name ?? "Team",
                opponentName: "Opponent",
                teamScore: game.calculatedTeamScore,
                opponentScore: Int(game.opponentScore),
                gameDate: Date(),
                result: game.result,
                focusPlayerStats: ""
            ) {
                viewModel.viewGameSummary(game)
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Recent Activity:")
                .font(.headline)
                .foregroundColor(.secondaryText)

            ForEach(viewModel.recentActivities) { activity in
                HStack {
                    Image(systemName: activity.icon)
                }
                .padding(.spacingM)
                .background(Color.cardBackground)
                .cornerRadius(.cornerRadiusSmall)
            }
        }
    }
}

// MARK: - Select Team Sheet

struct SelectTeamSheet: View {
    @Environment(\.managedObjectContext) private var context
    let child: Child
    let coordinator: NavigationCoordinator
    
    @State private var teams: [Team] = []
    @State private var showCreateTeam = false
    
    var body: some View {
        NavigationStack {
            List {
                if teams.isEmpty {
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
                } else {
                    ForEach(teams, id: \.id) { team in
                        Button(action: { createGameAndNavigate(for: team) }) {
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
                CreateTeamSheet(child: child, coordinator: coordinator) { newTeam in
                    teams.append(newTeam)
                    createGameAndNavigate(for: newTeam)
                }
            }
            .onAppear {
                loadTeams()
            }
        }
    }
    
    private func loadTeams() {
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
        let playerRequest = NSFetchRequest<Player>(entityName: "Player")
        playerRequest.predicate = NSPredicate(
            format: "childId == %@ AND teamId == %@",
            child.id as CVarArg,
            team.id as CVarArg
        )
        
        guard let player = try? context.fetch(playerRequest).first else {
            return
        }
        
        let game = Game(context: context)
        game.id = UUID()
        game.teamId = team.id
        game.focusChildId = child.id
        game.opponentName = "Opponent"
        game.opponentScore = 0
        game.gameDate = Date()
        game.isComplete = false
        game.duration = 0
        game.createdAt = Date()
        game.updatedAt = Date()
        
        do {
            try context.save()
            try? child.markAsUsed(context: context)
            
            coordinator.dismissSheet()
            coordinator.selectedTab = .live
        } catch {
            print("Error creating game: \(error)")
        }
    }
}

//MARK: - Create Team Sheet

struct CreateTeamSheet: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let child: Child
    let coordinator: NavigationCoordinator
    let onTeamCreated: (Team) -> Void
    
    @State private var teamName: String = ""
    @State private var season: String = ""
    @State private var organization: String = ""
    @State private var jerseyNumber: String = ""
    @State private var position: String = ""
    @State private var selectedColor: Color = .blue
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private let colorOptions: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .cyan, .indigo
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Team Information")) {
                    TextField("Team Name", text: $teamName)
                        .autocapitalization(.words)
                    
                    TextField("Season (e.g., Fall 2026)", text: $season)
                    
                    TextField("Organization (Optional)", text: $organization)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Team Colors")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colorOptions, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .shadow(radius: selectedColor == color ? 4 : 0)
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("\(child.name ?? "Player") Details")) {
                    TextField("Jersey Number (Optional)", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                    
                    TextField("Position (Optional)", text: $position)
                        .autocapitalization(.words)
                }
                
                Section {
                    Text("You can add more players to this team later.")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .navigationTitle("Create Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTeam()
                    }
                    .disabled(teamName.trimmingCharacters(in: .whitespaces).isEmpty ||
                             season.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createTeam() {
        let trimmedName = teamName.trimmingCharacters(in: .whitespaces)
        let trimmedSeason = season.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty, !trimmedSeason.isEmpty else {
            errorMessage = "Please enter team name and season"
            showError = true
            return
        }
        
        let team = Team(context: context)
        team.id = UUID()
        team.name = trimmedName
        team.season = trimmedSeason
        team.organization = organization.isEmpty ? nil : organization
        team.isActive = true
        team.createdAt = Date()
        team.colorHex = selectedColor.toHex()
        
        let player = Player(context: context)
        player.id = UUID()
        player.childId = child.id
        player.teamId = team.id
        player.jerseyNumber = jerseyNumber.isEmpty ? nil : jerseyNumber
        player.position = position.isEmpty ? nil : position
        player.createdAt = Date()
        
        do {
            try context.save()
            onTeamCreated(team)
            dismiss()
        } catch {
            errorMessage = "Failed to create team: \(error.localizedDescription)"
            showError = true
        }
    }
}

// MARK: - Color Extensions

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = components[0]
        let g = components.count > 1 ? components[1] : components[0]
        let b = components.count > 2 ? components[2] : components[0]
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(Float(r * 255)),
                     lroundf(Float(g * 255)),
                     lroundf(Float(b * 255)))
    }
}

// MARK: - Settings & Game Summary

struct SelectTeamSheet_Old: View {
    @Environment(\.managedObjectContext) private var context
    let child: Child
    let coordinator: NavigationCoordinator
    
    var body: some View {
        SelectTeamView(coordinator: coordinator, child: child)
            .environment(\.managedObjectContext, context)
    }
}

struct SettingsSheet: View {
    let coordinator: NavigationCoordinator
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Section(header: Text("Data")) {
                    Button(role: .destructive) {
                        // TODO: Implement data reset
                    } label: {
                        Text("Reset All Data")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        coordinator.dismissSheet()
                    }
                }
            }
        }
    }
}

struct GameSummarySheet: View {
    let game: Game
    let coordinator: NavigationCoordinator
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacingL) {
                    // Score
                    HStack {
                        VStack {
                            Text("\(game.calculatedTeamScore)")
                                .font(.system(size: 48, weight: .bold))
                            Text(game.team?.name ?? "Team")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("VS")
                            .font(.headline)
                            .foregroundColor(.secondaryText)
                        
                        VStack {
                            Text("\(game.opponentScore)")
                                .font(.system(size: 48, weight: .bold))
                            Text(game.opponentName ?? "Opponent")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(.cornerRadiusCard)
                    
                    // Result
                    HStack {
                        Text("Result:")
                            .font(.headline)
                        Spacer()
                        Text(game.result.emoji + " " + game.result.rawValue)
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(.cornerRadiusCard)
                    
                    // Stats would go here
                    Text("Detailed stats coming soon")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                .padding()
            }
            .navigationTitle("Game Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        coordinator.dismissSheet()
                    }
                }
            }
        }
    }
}

struct AddChildSheet: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var coordinator: NavigationCoordinator
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Child Information")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                    
                    DatePicker(
                        "Date of Birth",
                        selection: $dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }
                
                Section {
                    Text("You can add a photo and more details later.")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        coordinator.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChild()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveChild() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter a name"
            showError = true
            return
        }
        
        // Create new child
        let child = Child(context: context)
        child.id = UUID()
        child.name = trimmedName
        child.dateOfBirth = dateOfBirth
        child.createdAt = Date()
        child.lastUsed = Date()
        
        // Save to Core Data
        do {
            try context.save()
            coordinator.dismissSheet()
            viewModel.loadData()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
            showError = true
        }
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with test data using helper
        let context = CoreDataStack.createInMemoryStack().mainContext
        _ = TestDataHelper.createCompleteTestSetup(context: context)

        return HomeView()
            .environment(\.managedObjectContext, context)
    }
}
