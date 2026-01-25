//
//  Colors.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/24/26.
//

import SwiftUI

extension Color {
    // MARK: - Stat Colors (iOS Semantic)
    static let statMade = Color.green
    static let statMissed = Color.red
    static let statPositive = Color.blue
    static let statNegative = Color.orange
    static let statTeam = Color.purple
    
    // MARK: - Backgrounds (Auto Dark Mode)
    static let appBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    // MARK: - Text (Semantic Hierarchy)
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
    
    // MARK: - System Elements
    static let separator = Color(uiColor: .separator)
    static let fill = Color(uiColor: .systemFill)
}
