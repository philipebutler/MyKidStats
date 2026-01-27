//
//  StatsView.swift
//  MyKidStats
//
//  Created by Copilot on 1/27/26.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @Environment(\.managedObjectContext) private var context
    @State private var showingShareSheet = false
    @State private var shareText: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.children.isEmpty {
                    emptyState
                } else if viewModel.isLoading {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage {
                    errorState(message: errorMessage)
                } else if let stats = viewModel.careerStats {
                    statsContent(stats: stats)
                } else {
                    emptyStatsState
                }
            }
            .navigationTitle("Career Stats")
            .toolbar {
                if viewModel.children.count > 1 {
                    ToolbarItem(placement: .principal) {
                        childSegmentedControl
                    }
                }
                
                if viewModel.careerStats != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: shareCareerStats) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ActivityViewController(activityItems: [shareText], applicationActivities: nil)
            }
        }
    }
    
    // MARK: - Child Selector
    
    private var childSegmentedControl: some View {
        Picker("Child", selection: Binding(
            get: { viewModel.selectedChild },
            set: { if let child = $0 { viewModel.selectChild(child) } }
        )) {
            ForEach(viewModel.children, id: \.id) { child in
                Text(child.name ?? "Unknown").tag(child as Child?)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 300)
    }
    
    // MARK: - Stats Content
    
    private func statsContent(stats: CareerStats) -> some View {
        ScrollView {
            VStack(spacing: .spacingL) {
                // Overview Card
                overviewSection(stats: stats)
                
                // Shooting Stats
                shootingSection(stats: stats)
                
                // Career Highs
                careerHighsSection(stats: stats)
                
                // Team Breakdown
                if !stats.teamStats.isEmpty {
                    teamBreakdownSection(stats: stats)
                }
            }
            .padding()
        }
        .background(Color.appBackground)
    }
    
    private func overviewSection(stats: CareerStats) -> some View {
        VStack(spacing: .spacingM) {
            Text(stats.childName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(stats.totalGames) Games Played")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            HStack(spacing: .spacingL) {
                statColumn(title: "PPG", value: String(format: "%.1f", stats.pointsPerGame))
                statColumn(title: "RPG", value: String(format: "%.1f", stats.reboundsPerGame))
                statColumn(title: "APG", value: String(format: "%.1f", stats.assistsPerGame))
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func shootingSection(stats: CareerStats) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Shooting")
                .font(.headline)
            
            VStack(spacing: .spacingS) {
                shootingRow(
                    label: "FG",
                    made: stats.fieldGoalMade,
                    attempted: stats.fieldGoalAttempted,
                    percentage: stats.fieldGoalPercentage
                )
                
                shootingRow(
                    label: "3PT",
                    made: stats.threePointMade,
                    attempted: stats.threePointAttempted,
                    percentage: stats.threePointPercentage
                )
                
                shootingRow(
                    label: "FT",
                    made: stats.freeThrowMade,
                    attempted: stats.freeThrowAttempted,
                    percentage: stats.freeThrowPercentage
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func shootingRow(label: String, made: Int, attempted: Int, percentage: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .leading)
            
            Text("\(made)/\(attempted)")
                .font(.body)
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Text(String(format: "%.1f%%", percentage))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(percentageColor(percentage))
        }
    }
    
    private func careerHighsSection(stats: CareerStats) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Career Highs")
                .font(.headline)
            
            HStack(spacing: .spacingL) {
                careerHighColumn(title: "Points", value: stats.careerHighPoints)
                careerHighColumn(title: "Rebounds", value: stats.careerHighRebounds)
                careerHighColumn(title: "Assists", value: stats.careerHighAssists)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func teamBreakdownSection(stats: CareerStats) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("By Team")
                .font(.headline)
            
            VStack(spacing: .spacingS) {
                ForEach(stats.teamStats, id: \.teamName) { teamStat in
                    teamStatRow(teamStat: teamStat)
                }
            }
        }
    }
    
    private func teamStatRow(teamStat: TeamSeasonStats) -> some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            HStack {
                VStack(alignment: .leading) {
                    Text(teamStat.teamName)
                        .font(.headline)
                    
                    Text(teamStat.season)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Text("\(teamStat.wins)-\(teamStat.losses)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: .spacingL) {
                Text(String(format: "%.1f PPG", teamStat.pointsPerGame))
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Text(String(format: "%.1f RPG", teamStat.reboundsPerGame))
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Text(String(format: "%.1f APG", teamStat.assistsPerGame))
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
    
    // MARK: - Helper Views
    
    private func statColumn(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
    }
    
    private func careerHighColumn(title: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
    }
    
    private func percentageColor(_ percentage: Double) -> Color {
        if percentage >= 45 { return .green }
        if percentage >= 35 { return .orange }
        return .red
    }
    
    // MARK: - Empty States
    
    private var emptyState: some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("No Children Yet")
                .font(.title2)
            
            Text("Add a child in the Home tab to track their stats")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStatsState: some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("No Stats Yet")
                .font(.title2)
            
            Text("Play some games to see career statistics")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingState: some View {
        VStack(spacing: .spacingL) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading stats...")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorState(message: String) -> some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func shareCareerStats() {
        guard let stats = viewModel.careerStats else { return }
        
        shareText = """
        🏀 \(stats.childName) - Career Stats
        
        📊 Overall Performance
        Games Played: \(stats.totalGames)
        PPG: \(String(format: "%.1f", stats.pointsPerGame)) | RPG: \(String(format: "%.1f", stats.reboundsPerGame)) | APG: \(String(format: "%.1f", stats.assistsPerGame))
        
        🎯 Shooting
        FG: \(stats.fieldGoalMade)/\(stats.fieldGoalAttempted) (\(String(format: "%.1f%%", stats.fieldGoalPercentage)))
        3PT: \(stats.threePointMade)/\(stats.threePointAttempted) (\(String(format: "%.1f%%", stats.threePointPercentage)))
        FT: \(stats.freeThrowMade)/\(stats.freeThrowAttempted) (\(String(format: "%.1f%%", stats.freeThrowPercentage)))
        
        🏆 Career Highs
        Points: \(stats.careerHighPoints) | Rebounds: \(stats.careerHighRebounds) | Assists: \(stats.careerHighAssists)
        
        📈 Total Stats
        Points: \(stats.totalPoints) | Rebounds: \(stats.totalRebounds) | Assists: \(stats.totalAssists)
        Steals: \(stats.totalSteals) | Blocks: \(stats.totalBlocks)
        
        Generated with MyKidStats
        """
        
        showingShareSheet = true
    }
}

#Preview {
    StatsView()
        .environment(\.managedObjectContext, CoreDataStack.shared.mainContext)
}
