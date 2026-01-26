//
//  ContentView.swift
//  MyKidStats - Phase1 Solution
//

import SwiftUI

struct ContentView: View {
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

#Preview {
    ContentView()
}
