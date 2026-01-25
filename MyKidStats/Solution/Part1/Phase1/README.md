# MyKidStats — Part 1 / Phase 1

This folder contains the Phase 1 implementation and required prerequisites to build the minimal app for Phase 1.

Included:
- Core/CoreDataStack.swift — lightweight Core Data stack used for the app
- UI/ContentView.swift — simple SwiftUI view demonstrating the app status
- UI/MyKidStatsApp.swift — main app entry that wires the Core Data stack

Quick run (from Xcode):
1. Open `MyKidStats.xcodeproj` or workspace in Xcode.
2. In Project Navigator, add this folder to the `MyKidStats` target if it's not already part of the target.
3. Make sure `MyKidStats.xcdatamodeld` is included in the target.
4. Build and run (⌘+B, then ⌘+R).

Notes:
- This Phase 1 bundle is intentionally minimal — it focuses on wiring Core Data and the initial UI.
- If you prefer to keep a single source layout, move these files into the main `Core` / top-level folders and remove duplicates.
