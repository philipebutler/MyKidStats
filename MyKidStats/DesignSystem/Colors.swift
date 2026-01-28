//
//  Colors.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/24/26.
//

import SwiftUI
import UIKit

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
    
    // MARK: - Hex Color Initializer
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    // MARK: - Convert Color to Hex String
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
