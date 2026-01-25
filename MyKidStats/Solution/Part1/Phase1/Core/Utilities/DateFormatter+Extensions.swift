//
//  DateFormatter+Extensions.swift
//  MyKidStats - Phase1 Solution
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
