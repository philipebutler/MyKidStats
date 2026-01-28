//
//  GameSummaryView.swift
//  MyKidStats
//
//  Created by Copilot on 1/27/26.
//

import SwiftUI
import CoreData

struct GameSummaryView: View {
    let game: Game
    let focusChild: Child
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var shareContent: [Any] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var careerStats: CareerStats?
    
    private let exportCSVUseCase = ExportGameCSVUseCase()
    private let textSummaryUseCase = GenerateTextSummaryUseCase()
    private let careerStatsUseCase = CalculateCareerStatsUseCase()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .spacingL) {
                    gameResultHeader
                    focusPlayerStats
                    
                    if let careerStats = careerStats {
                        seasonComparisonSection(gameStats: calculateFocusPlayerStats(), careerStats: careerStats)
                    }
                    
                    gameDetails
                    exportButtons
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Game Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ActivityViewController(activityItems: shareContent, applicationActivities: nil)
            }
            .alert("Export Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadCareerStats()
            }
        }
    }
    
    private var gameResultHeader: some View {
        VStack(spacing: .spacingM) {
            Text(game.result.emoji)
                .font(.system(size: 60))
            
            Text(resultText)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: .spacingM) {
                Text(game.team?.name ?? "Team")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(game.calculatedTeamScore)")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(game.result == .win ? .green : .primary)
                
                Text("-")
                    .foregroundColor(.secondaryText)
                
                Text("\(game.opponentScore)")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(game.result == .loss ? .red : .primary)
                
                Text(game.opponentName ?? "Opponent")
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private var focusPlayerStats: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("\(focusChild.name ?? "Player") Stats")
                .font(.headline)
            
            let stats = calculateFocusPlayerStats()
            
            HStack(spacing: .spacingXL) {
                VStack {
                    Text("\(stats.points)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("PTS")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                VStack {
                    Text("\(stats.rebounds)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("REB")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                VStack {
                    Text("\(stats.assists)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("AST")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                VStack {
                    Text("\(stats.steals)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("STL")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                VStack {
                    Text("\(stats.blocks)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("BLK")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: .spacingS) {
                statRow(label: "FG", value: "\(stats.fgMade)/\(stats.fgAttempted)", percentage: stats.fgPercentage)
                statRow(label: "3PT", value: "\(stats.threeMade)/\(stats.threeAttempted)", percentage: stats.threePercentage)
                statRow(label: "FT", value: "\(stats.ftMade)/\(stats.ftAttempted)", percentage: stats.ftPercentage)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func statRow(label: String, value: String, percentage: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Text(String(format: "%.1f%%", percentage))
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var gameDetails: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            Text("Game Details")
                .font(.headline)
            
            HStack {
                Text("Date:")
                    .foregroundColor(.secondaryText)
                Spacer()
                Text(formatDate(game.gameDate ?? Date()))
            }
            
            if let location = game.location, !location.isEmpty {
                HStack {
                    Text("Location:")
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text(location)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private var exportButtons: some View {
        VStack(spacing: .spacingM) {
            Button(action: shareTextSummary) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Text Summary")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: shareCSVExport) {
                HStack {
                    Image(systemName: "tablecells")
                    Text("Export as CSV")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private func seasonComparisonSection(gameStats: LiveStats, careerStats: CareerStats) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Season Comparison")
                .font(.headline)
            
            VStack(spacing: .spacingS) {
                comparisonRow(label: "Points", gameValue: gameStats.points, seasonAvg: careerStats.pointsPerGame)
                comparisonRow(label: "Rebounds", gameValue: gameStats.rebounds, seasonAvg: careerStats.reboundsPerGame)
                comparisonRow(label: "Assists", gameValue: gameStats.assists, seasonAvg: careerStats.assistsPerGame)
                comparisonRow(label: "Steals", gameValue: gameStats.steals, seasonAvg: careerStats.stealsPerGame)
                comparisonRow(label: "Blocks", gameValue: gameStats.blocks, seasonAvg: careerStats.blocksPerGame)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private func comparisonRow(label: String, gameValue: Int, seasonAvg: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("This Game: \(gameValue)")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Text(String(format: "Season Avg: %.1f", seasonAvg))
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            if Double(gameValue) > seasonAvg {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
            } else if Double(gameValue) < seasonAvg {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "equal.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(comparisonAccessibilityLabel(label: label, gameValue: gameValue, seasonAvg: seasonAvg))
    }
    
    private func comparisonAccessibilityLabel(label: String, gameValue: Int, seasonAvg: Double) -> String {
        let comparison: String
        if Double(gameValue) > seasonAvg {
            comparison = "above average"
        } else if Double(gameValue) < seasonAvg {
            comparison = "below average"
        } else {
            comparison = "equal to average"
        }
        return "\(label): \(gameValue) this game, \(String(format: "%.1f", seasonAvg)) season average, \(comparison)"
    }
    
    // MARK: - Helper Functions
    
    private var resultText: String {
        switch game.result {
        case .win: return "Victory!"
        case .loss: return "Tough Loss"
        case .tie: return "Tie Game"
        case .inProgress: return "Game Complete"
        }
    }
    
    private func calculateFocusPlayerStats() -> LiveStats {
        guard let events = game.statEvents as? Set<StatEvent> else { 
            print("No stat events found for game")
            return LiveStats() 
        }
        
        print("Found \(events.count) stat events for game")
        
        // Filter events directly by focusChildId using game's focusChildId
        guard let focusChildId = game.focusChildId else {
            print("No focusChildId on game")
            return LiveStats()
        }
        
        // Find player for this child on this team
        guard let teamId = game.teamId else {
            print("No teamId on game")
            return LiveStats()
        }
        
        let context = game.managedObjectContext!
        let playerRequest = NSFetchRequest<Player>(entityName: "Player")
        playerRequest.predicate = NSPredicate(
            format: "childId == %@ AND teamId == %@",
            focusChildId as CVarArg,
            teamId as CVarArg
        )
        
        guard let focusPlayer = try? context.fetch(playerRequest).first,
              let focusPlayerId = focusPlayer.id else {
            print("Could not find focus player")
            return LiveStats()
        }
        
        print("Focus player ID: \(focusPlayerId)")
        
        let playerEvents = events.filter { $0.playerId == focusPlayerId && !$0.isSoftDeleted }
        print("Found \(playerEvents.count) events for focus player")
        
        var stats = LiveStats()
        
        for event in playerEvents {
            guard let statType = event.statType, let type = StatType(rawValue: statType) else { 
                print("Invalid stat type: \(event.statType ?? "nil")")
                continue 
            }
            print("Recording stat: \(type.rawValue)")
            stats.recordStat(type)
        }
        
        print("Final stats - Points: \(stats.points), Rebounds: \(stats.rebounds), Assists: \(stats.assists)")
        
        return stats
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func shareTextSummary() {
        let summary = textSummaryUseCase.execute(game: game, focusChild: focusChild)
        shareContent = [summary]
        showingShareSheet = true
    }
    
    private func shareCSVExport() {
        do {
            let fileURL = try exportCSVUseCase.execute(game)
            shareContent = [fileURL]
            showingShareSheet = true
        } catch {
            errorMessage = "Failed to export CSV: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func loadCareerStats() async {
        guard let childId = focusChild.id else { return }
        do {
            careerStats = try await careerStatsUseCase.execute(for: childId)
        } catch {
            // Silently fail - comparison section just won't show
            print("Failed to load career stats: \(error)")
        }
    }
}

#Preview {
    let context = CoreDataStack.shared.mainContext
    let game = Game(context: context)
    game.id = UUID()
    game.opponentName = "Lakers"
    game.opponentScore = 45
    game.isComplete = true
    game.gameDate = Date()
    
    let child = Child(context: context)
    child.id = UUID()
    child.name = "Johnny"
    
    return GameSummaryView(game: game, focusChild: child)
}
