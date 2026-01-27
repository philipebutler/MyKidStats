//
//  DesignSystemPreview.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/24/26.
//

import SwiftUI

/// Preview view to verify Design System implementation
struct DesignSystemPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: .spacingXL) {
                // Header
                VStack(spacing: .spacingM) {
                    Text("Design System Preview")
                        .font(.playerName)
                        .foregroundColor(.primaryText)
                    
                    Text("Verify all colors, fonts, and spacing")
                        .font(.summaryText)
                        .foregroundColor(.secondaryText)
                }
                .padding(.top, .spacingXL)
                
                // Colors Section
                colorSection
                
                // Typography Section
                typographySection
                
                // Spacing Section
                spacingSection
                
                // Stat Types Section
                statTypesSection
            }
            .padding(.horizontal, .spacingL)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Color Section
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Colors")
                .font(.playerName)
                .foregroundColor(.primaryText)
            
            VStack(spacing: .spacingS) {
                colorRow(name: "Stat Made", color: .statMade)
                colorRow(name: "Stat Missed", color: .statMissed)
                colorRow(name: "Stat Positive", color: .statPositive)
                colorRow(name: "Stat Negative", color: .statNegative)
                colorRow(name: "Stat Team", color: .statTeam)
                
                Divider()
                    .padding(.vertical, .spacingXS)
                
                colorRow(name: "App Background", color: .appBackground)
                colorRow(name: "Card Background", color: .cardBackground)
                
                Divider()
                    .padding(.vertical, .spacingXS)
                
                colorRow(name: "Primary Text", color: .primaryText)
                colorRow(name: "Secondary Text", color: .secondaryText)
                colorRow(name: "Tertiary Text", color: .tertiaryText)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(.cornerRadiusCard)
        }
    }
    
    private func colorRow(name: String, color: Color) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                .fill(color)
                .frame(width: 40, height: 40)
            
            Text(name)
                .font(.teamRow)
                .foregroundColor(.primaryText)
            
            Spacer()
        }
    }
    
    // MARK: - Typography Section
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Typography")
                .font(.playerName)
                .foregroundColor(.primaryText)
            
            VStack(alignment: .leading, spacing: .spacingM) {
                VStack(alignment: .leading, spacing: .spacingXS) {
                    Text("Score Large")
                        .font(.statLabel)
                        .foregroundColor(.secondaryText)
                    Text("42")
                        .font(.scoreLarge)
                        .foregroundColor(.primaryText)
                }
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    Text("Player Name")
                        .font(.statLabel)
                        .foregroundColor(.secondaryText)
                    Text("John Smith")
                        .font(.playerName)
                        .foregroundColor(.primaryText)
                }
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    Text("Stat Value")
                        .font(.statLabel)
                        .foregroundColor(.secondaryText)
                    Text("12")
                        .font(.statValue)
                        .foregroundColor(.primaryText)
                }
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    Text("Team Row")
                        .font(.statLabel)
                        .foregroundColor(.secondaryText)
                    Text("#25 Warriors - Spring 2026")
                        .font(.teamRow)
                        .foregroundColor(.primaryText)
                }
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    Text("Summary Text")
                        .font(.statLabel)
                        .foregroundColor(.secondaryText)
                    Text("8/15 FG (53.3%) • 3/7 3PT (42.9%)")
                        .font(.summaryText)
                        .foregroundColor(.tertiaryText)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(.cornerRadiusCard)
        }
    }
    
    // MARK: - Spacing Section
    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Spacing & Sizes")
                .font(.playerName)
                .foregroundColor(.primaryText)
            
            VStack(alignment: .leading, spacing: .spacingS) {
                spacingRow(name: "XS (4pt)", size: .spacingXS)
                spacingRow(name: "S (8pt)", size: .spacingS)
                spacingRow(name: "M (12pt)", size: .spacingM)
                spacingRow(name: "L (16pt)", size: .spacingL)
                spacingRow(name: "XL (20pt)", size: .spacingXL)
                spacingRow(name: "XXL (24pt)", size: .spacingXXL)
                
                Divider()
                    .padding(.vertical, .spacingXS)
                
                cornerRadiusRow(name: "Small (8pt)", radius: .cornerRadiusSmall)
                cornerRadiusRow(name: "Button (12pt)", radius: .cornerRadiusButton)
                cornerRadiusRow(name: "Card (16pt)", radius: .cornerRadiusCard)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(.cornerRadiusCard)
        }
    }
    
    private func spacingRow(name: String, size: CGFloat) -> some View {
        HStack {
            Rectangle()
                .fill(Color.statPositive)
                .frame(width: size, height: 20)
            
            Text(name)
                .font(.teamRow)
                .foregroundColor(.primaryText)
            
            Spacer()
        }
    }
    
    private func cornerRadiusRow(name: String, radius: CGFloat) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color.statMade)
                .frame(width: 40, height: 40)
            
            Text(name)
                .font(.teamRow)
                .foregroundColor(.primaryText)
            
            Spacer()
        }
    }
    
    // MARK: - Stat Types Section
    private var statTypesSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Stat Types")
                .font(.playerName)
                .foregroundColor(.primaryText)
            
            VStack(spacing: .spacingS) {
                ForEach(StatType.allCases, id: \.self) { statType in
                    statTypeRow(statType)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(.cornerRadiusCard)
        }
    }
    
    private func statTypeRow(_ statType: StatType) -> some View {
        HStack {
            Image(systemName: statType.icon)
                .foregroundColor(statType.color)
                .frame(width: 30)
            
            Text(statType.displayName)
                .font(.teamRow)
                .foregroundColor(.primaryText)
                .frame(width: 80, alignment: .leading)
            
            Text(statType.rawValue)
                .font(.summaryText)
                .foregroundColor(.tertiaryText)
            
            Spacer()
            
            if statType.pointValue > 0 {
                Text("+\(statType.pointValue)")
                    .font(.statValue)
                    .foregroundColor(.statMade)
            }
        }
    }
}

#Preview("Light Mode") {
    DesignSystemPreview()
}

#Preview("Dark Mode") {
    DesignSystemPreview()
        .preferredColorScheme(.dark)
}
