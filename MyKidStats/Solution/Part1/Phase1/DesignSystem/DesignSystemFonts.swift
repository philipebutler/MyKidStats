//
//  Fonts.swift
//  MyKidStats - Phase1 Solution
//

import SwiftUI

extension Font {
    // MARK: - Scores & Large Numbers
    static let scoreLarge = Font.system(.largeTitle, design: .rounded, weight: .bold)
    
    // MARK: - Headings
    static let playerName = Font.system(.title2, design: .default, weight: .semibold)
    
    // MARK: - Stat Labels
    static let statLabel = Font.system(.caption2, design: .rounded, weight: .medium)
    static let statValue = Font.system(.title3, design: .rounded, weight: .bold)
    
    // MARK: - Body Text
    static let teamRow = Font.system(.body, design: .default, weight: .regular)
    static let summaryText = Font.system(.caption, design: .default, weight: .regular)
}
