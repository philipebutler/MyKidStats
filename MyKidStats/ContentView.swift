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

            LiveGameView()
                .tabItem {
                    Label("Live", systemImage: "play.circle.fill")
                }
                .tag(AppTab.live)

            TeamsView()
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }
                .tag(AppTab.teams)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.stats)
        }
        .environmentObject(coordinator)
    }
}

// HomeView is provided in Features/Home/HomeView.swift

// Placeholder views for tabs
struct LiveGameView: View {
    var body: some View {
        VStack {
            Text("Live Game")
                .font(.title2)
            Text("Implement live game UI here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

struct TeamsView: View {
    var body: some View {
        VStack {
            Text("Teams")
                .font(.title2)
            Text("List teams and players here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
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
