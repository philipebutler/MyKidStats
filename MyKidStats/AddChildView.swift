//
//  AddChildView.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/26/26.
//

import SwiftUI
import CoreData

struct AddChildView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var coordinator: NavigationCoordinator
    
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
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
            showError = true
        }
    }
}

#Preview {
    let context = CoreDataStack.createInMemoryStack().mainContext
    let coordinator = NavigationCoordinator()
    
    return AddChildView(coordinator: coordinator)
        .environment(\.managedObjectContext, context)
}
