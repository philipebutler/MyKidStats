//
//  MyKidStatsApp.swift
//  MyKidStats
//
//  Created by Philip Butler on 1/23/26.
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
