//
//  ContentView.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/23/26.
//

import SwiftUI

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
                        TeamDetailRow(team: team)
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
