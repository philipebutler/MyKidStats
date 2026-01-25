//
//  DateFormatter+Extensions.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/24/26.
//

import Foundation

extension DateFormatter {
    static let gameDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
