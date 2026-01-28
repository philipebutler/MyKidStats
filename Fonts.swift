//
//  Fonts.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/24/26.
//

import SwiftUI

extension Font {
    // MARK: - Custom Fonts for Stats
    static let playerName = Font.title3.weight(.semibold)
    static let scoreLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let scoreMedium = Font.system(size: 32, weight: .bold, design: .rounded)
    static let statNumber = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let summaryText = Font.body
}
