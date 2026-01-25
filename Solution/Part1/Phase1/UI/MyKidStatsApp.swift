//
//  MyKidStatsApp.swift
//  MyKidStats - Phase1 Solution
//

import SwiftUI

@main
struct MyKidStatsApp: App {
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.mainContext)
        }
    }
}
