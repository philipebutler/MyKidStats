//
//  CreateTeamView.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/26/26.
//

import SwiftUI
import CoreData

struct CreateTeamView: View {
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
        
        // Create team
        let team = Team(context: context)
        team.id = UUID()
        team.name = trimmedName
        team.season = trimmedSeason
        team.organization = organization.isEmpty ? nil : organization
        team.isActive = true
        team.createdAt = Date()
        team.colorHex = selectedColor.toHex()
        
        // Create player instance for this child on this team
        let player = Player(context: context)
        player.id = UUID()
        player.childId = child.id
        player.teamId = team.id
        player.jerseyNumber = jerseyNumber.isEmpty ? nil : jerseyNumber
        player.position = position.isEmpty ? nil : position
        player.createdAt = Date()
        
        // Save
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

// Color to Hex extension
extension Color {
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

#Preview {
    let context = CoreDataStack.createInMemoryStack().mainContext
    let coordinator = NavigationCoordinator()
    
    let child = Child(context: context)
    child.id = UUID()
    child.name = "Sam"
    
    return CreateTeamView(child: child, coordinator: coordinator) { _ in }
        .environment(\.managedObjectContext, context)
}
