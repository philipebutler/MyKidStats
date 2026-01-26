//
//  ContentView.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/23/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            LiveGameView()
                .tabItem {
                    Label("Live", systemImage: "timer")
                }

            TeamsView()
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

// Reuse previous setup content as the Home tab
struct HomeView: View {
    var body: some View {
        VStack(spacing: .spacingL) {
            Image(systemName: "basketball.fill")
                .imageScale(.large)
                .foregroundColor(.statMade)
                .font(.system(size: 60))

            Text("MyKidStats")
                .font(.playerName)
                .foregroundColor(.primaryText)

            Text("Setup Complete!")
                .font(.teamRow)
                .foregroundColor(.secondaryText)

            VStack(alignment: .leading, spacing: .spacingM) {
                Text("✅ Directory structure created")
                Text("✅ Design system ready")
                Text("✅ Domain models ready")
                Text("⚠️ Core Data model needs setup")
            }
            .font(.summaryText)
            .foregroundColor(.tertiaryText)
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(.cornerRadiusCard)

            Text("See PROJECT_SETUP_README.md for next steps")
                .font(.caption)
                .foregroundColor(.statNegative)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

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
