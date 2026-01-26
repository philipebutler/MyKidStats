# Basketball Stats Tracker - AI Implementation Plan Part 1
## Foundation & Data Layer (Weeks 1-2)

**Document:** Part 1 of 3  
**Focus:** Project setup, Core Data, Design System  
**Estimated Time:** 30-40 hours  
**Prerequisites:** Xcode 15+, iOS development knowledge

---

## Table of Contents

1. [Overview](#overview)
2. [Development Environment Setup](#development-environment-setup)
3. [Phase 1: Core Data Foundation](#phase-1-core-data-foundation)
4. [Phase 2: Design System](#phase-2-design-system)
5. [Testing Foundation](#testing-foundation)
6. [Common Pitfalls](#common-pitfalls)
7. [Checkpoint & Next Steps](#checkpoint)

---

## Overview

### What This Document Covers

This is the first phase of implementation focusing on:
- ✅ Xcode project setup
- ✅ Core Data model (5 entities)
- ✅ Entity extensions with helper methods
- ✅ Design system (colors, fonts, spacing)
- ✅ Foundation models (LiveStats, CareerStats)
- ✅ Unit tests for data layer

### What Comes Next

- **Part 2:** UI Framework & Components (Weeks 3-4)
- **Part 3:** Live Game & Features (Weeks 5-8)

### Success Criteria

By the end of this phase:
By the end of this phase:
- [x] Core Data stack functional
- [x] Can create and fetch all entities
- [x] Design system implemented
- [x] Unit tests passing (80%+ coverage)
- [x] No compiler warnings

---

## Development Environment Setup

### Task 1.0: Create Xcode Project

**Time Estimate:** 15 minutes

**Steps:**

1. Open Xcode → File → New → Project
2. Select "iOS App"
3. Configure project:
   - **Product Name:** `BasketballStats`
   - **Team:** Your team
   - **Organization Identifier:** `com.yourcompany`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** ✅ Use Core Data
   - **Include Tests:** ✅ Yes
   - **Minimum Deployment:** iOS 16.0

4. Click "Next" and save

**Verification:**
```bash
# Build the project
⌘+B

# Expected: Build Succeeds
# No errors, no warnings
```

**Acceptance Criteria:**
- [x] Project builds successfully
- [ ] SwiftUI preview works (ContentView)
- [x] Core Data stack file present (`BasketballStats.xcdatamodeld`)
- [ ] Can run in simulator

---

### Task 1.1: Configure Project Settings

**Time Estimate:** 10 minutes

**File:** `Info.plist`

Add these keys (select Info.plist → right-click → Add Row):

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>

<key>NSPhotoLibraryUsageDescription</key>
<string>Add photos of your children to personalize their profiles</string>
```

**File:** Project Settings → Build Settings

- **iOS Deployment Target:** 16.0
- **Swift Language Version:** Swift 5
- **Supported Destinations:** iPhone Only

**Verification:**
- [x] App only allows portrait orientation
- [x] Photo library permission string present
- [x] Runs on iOS 16+ only

---

### Task 1.2: Create Folder Structure

**Time Estimate:** 10 minutes

Create these groups in Xcode (Groups, not file system folders):

```
BasketballStats/
├── App/
│   ├── BasketballStatsApp.swift (already exists)
│   └── ContentView.swift (already exists)
├── Core/
│   ├── Data/
│   │   ├── CoreData/
│   │   │   ├── Entities/
│   │   │   └── Extensions/
│   │   └── Repositories/
│   ├── Domain/
│   │   ├── Models/
│   │   ├── UseCases/
│   │   └── Enums/
│   └── Utilities/
├── Features/
│   ├── Home/
│   ├── LiveGame/
│   ├── Stats/
│   └── Teams/
├── DesignSystem/
│   └── Components/
└── Resources/
```

**How to Create Groups:**
- Right-click project → New Group
- Name the group
- Nested groups: Right-click parent group → New Group

**Acceptance Criteria:**
- [x] All folders visible in Xcode sidebar
- [x] Project still compiles (empty folders OK)
- [x] Organized structure matches above

---

## Phase 1: Core Data Foundation

### Task 1.3: Define Core Data Schema

**Time Estimate:** 45 minutes

**File:** `BasketballStats.xcdatamodeld`

Open the Core Data model file (click on `.xcdatamodeld` in project navigator).

#### Entity 1: Child

**Create Entity:**
1. Click "+" at bottom → Add Entity
2. Name: `Child`

**Add Attributes:**

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | No | - |
| name | String | No | - |
| dateOfBirth | Date | Yes | - |
| photoData | Binary Data | Yes | - |
| createdAt | Date | No | Current Date |
| lastUsed | Date | No | Current Date |

**How to Add Attributes:**
- Select Child entity
- Click "+" in Attributes section
- Set name, type, and optional checkbox

**Add Indexes:**
1. Select Child entity
2. Scroll to "Indexes" section
3. Add index on: `id`, `lastUsed`

---

#### Entity 2: Player

**Create Entity:** Player

**Add Attributes:**

| Name | Type | Optional |
|------|------|----------|
| id | UUID | No |
| childId | UUID | No |
| teamId | UUID | No |
| jerseyNumber | String | Yes |
| position | String | Yes |
| createdAt | Date | No |

**Add Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| child | Child | To One | playerInstances | Nullify |
| team | Team | To One | players | Nullify |
| statEvents | StatEvent | To Many | player | Cascade |

**How to Add Relationships:**
- Select Player entity
- Click "+" in Relationships section
- Set destination entity, type, inverse

**Add Indexes:**
- `id`, `childId`, `teamId`

---

#### Entity 3: Team

**Create Entity:** Team

**Add Attributes:**

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | No | - |
| name | String | No | - |
| season | String | No | - |
| organization | String | Yes | - |
| isActive | Bool | No | NO |
| createdAt | Date | No | Current Date |
| colorHex | String | Yes | - |

**Add Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| players | Player | To Many | team | Cascade |
| games | Game | To Many | team | Cascade |

**Add Indexes:**
- `id`, `isActive`

---

#### Entity 4: Game

**Create Entity:** Game

**Add Attributes:**

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | No | - |
| teamId | UUID | No | - |
| focusChildId | UUID | No | - |
| opponentName | String | No | - |
| opponentScore | Integer 32 | No | 0 |
| gameDate | Date | No | Current Date |
| location | String | Yes | - |
| isComplete | Bool | No | NO |
| duration | Integer 32 | No | 0 |
| notes | String | Yes | - |
| createdAt | Date | No | Current Date |
| updatedAt | Date | No | Current Date |

**Add Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| team | Team | To One | games | Nullify |
| statEvents | StatEvent | To Many | game | Cascade |

**Add Indexes:**
- `id`, `teamId`, `focusChildId`, `isComplete`

---

#### Entity 5: StatEvent

**Create Entity:** StatEvent

**Add Attributes:**

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | No | - |
| playerId | UUID | No | - |
| gameId | UUID | No | - |
| timestamp | Date | No | Current Date |
| statType | String | No | - |
| value | Integer 32 | No | 0 |
| isDeleted | Bool | No | NO |

**Add Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|-------------|------|---------|-------------|
| player | Player | To One | statEvents | Nullify |
| game | Game | To One | statEvents | Nullify |

**Add Indexes:**
- `id`, `playerId`, `gameId`, `isDeleted`, `timestamp`

**Compound Index:**
- Create index with: `gameId`, `playerId`, `isDeleted`

---

#### Configure Code Generation

For EACH entity:
1. Select entity
2. Open Data Model Inspector (right sidebar)
3. Set **Codegen:** "Class Definition"
4. Set **Module:** Current Product Module

**Verification:**
**Verification:**
- [x] All 5 entities created
- [x] All attributes configured correctly
- [x] All relationships have inverses
- [x] All indexes created
- [x] Codegen set to "Class Definition"
- [x] Build succeeds (⌘+B)

---

### Task 1.4: Create Core Data Stack

**Time Estimate:** 20 minutes

**File:** `Core/Data/CoreData/CoreDataStack.swift`

Create new Swift file in Core/Data/CoreData folder.

```swift
import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BasketballStats")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // CRITICAL: Auto-merge changes from background contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func save() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Core Data save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Testing Support
    static func createInMemoryStack() -> CoreDataStack {
        let stack = CoreDataStack()
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        stack.persistentContainer.persistentStoreDescriptions = [description]
        
        // Force load
        _ = stack.persistentContainer.viewContext
        
        return stack
    }
}
```

**Test It:**

Add this to `BasketballStatsApp.swift`:

```swift
import SwiftUI

@main
struct BasketballStatsApp: App {
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.mainContext)
        }
    }
}
```

**Verification:**
- [x] File compiles
- [ ] App runs without crashing
- [ ] No error messages in console
- [x] CoreDataStack.shared accessible

---

### Task 1.5: Create Entity Extensions

**Time Estimate:** 60 minutes

Create separate files for each entity extension.

#### File: `Core/Data/CoreData/Entities/Child+CoreDataClass.swift`

```swift
import Foundation
import CoreData

extension Child {
    
    /// Fetch the most recently used child for smart defaults
    static func fetchLastUsed(context: NSManagedObjectContext) -> Child? {
        let request = Child.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastUsed", ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    /// Fetch all children sorted by name
    static func fetchAll(context: NSManagedObjectContext) -> [Child] {
        let request = Child.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    /// Update last used timestamp (call when starting a game)
    func markAsUsed(context: NSManagedObjectContext) throws {
        self.lastUsed = Date()
        try context.save()
    }
}
```

#### File: `Core/Data/CoreData/Entities/Player+CoreDataClass.swift`

```swift
import Foundation
import CoreData

extension Player {
    
    /// Fetch all player instances for a specific child
    static func fetchForChild(_ childId: UUID, context: NSManagedObjectContext) -> [Player] {
        let request = Player.fetchRequest()
        request.predicate = NSPredicate(format: "childId == %@", childId as CVarArg)
        return (try? context.fetch(request)) ?? []
    }
    
    /// Fetch player instance for child on specific team
    static func fetch(childId: UUID, teamId: UUID, context: NSManagedObjectContext) -> Player? {
        let request = Player.fetchRequest()
        request.predicate = NSPredicate(
            format: "childId == %@ AND teamId == %@",
            childId as CVarArg,
            teamId as CVarArg
        )
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
```

#### File: `Core/Data/CoreData/Entities/Team+CoreDataClass.swift`

```swift
import Foundation
import CoreData

extension Team {
    
    /// Find active team for a specific child
    static func fetchActive(forChildId childId: UUID, context: NSManagedObjectContext) -> Team? {
        let playerRequest = Player.fetchRequest()
        playerRequest.predicate = NSPredicate(format: "childId == %@", childId as CVarArg)
        
        guard let players = try? context.fetch(playerRequest) else { return nil }
        
        return players.first { player in
            player.team?.isActive == true
        }?.team
    }
    
    /// Deactivate all teams, activate this one
    func makeActive(context: NSManagedObjectContext) throws {
        let allTeams = try context.fetch(Team.fetchRequest())
        allTeams.forEach { $0.isActive = false }
        self.isActive = true
        try context.save()
    }
}
```

#### File: `Core/Data/CoreData/Entities/Game+CoreDataClass.swift`

```swift
import Foundation
import CoreData

enum GameResult: String {
    case win = "W"
    case loss = "L"
    case tie = "T"
    case inProgress = "IP"
    
    var emoji: String {
        switch self {
        case .win: return "✓"
        case .loss: return "✗"
        case .tie: return "–"
        case .inProgress: return "IP"
        }
    }
}

extension Game {
    
    /// Computed team score from stat events
    var teamScore: Int {
        guard let events = statEvents as? Set<StatEvent> else { return 0 }
        return events
            .filter { $0.isPointEvent && !$0.isDeleted }
            .reduce(0) { $0 + Int($1.value) }
    }
    
    /// Game result
    var result: GameResult {
        guard isComplete else { return .inProgress }
        if teamScore > opponentScore { return .win }
        if teamScore < opponentScore { return .loss }
        return .tie
    }
}
```

#### File: `Core/Data/CoreData/Entities/StatEvent+CoreDataClass.swift`

```swift
import Foundation
import CoreData

extension StatEvent {
    
    var isPointEvent: Bool {
        guard let type = StatType(rawValue: statType) else { return false }
        return type.pointValue > 0
    }
}
```

**Verification:**
- [x] All 5 extension files compile
- [ ] No errors in console
- [ ] Can call static methods (test in playground or app)

---

### Task 1.6: Create StatType Enum

**Time Estimate:** 30 minutes

**File:** `Core/Domain/Enums/StatType.swift`

```swift
import Foundation
import SwiftUI

enum StatType: String, CaseIterable {
    // Shooting - Made
    case twoPointMade = "TWO_MADE"
    case threePointMade = "THREE_MADE"
    case freeThrowMade = "FT_MADE"
    
    // Shooting - Missed
    case twoPointMiss = "TWO_MISS"
    case threePointMiss = "THREE_MISS"
    case freeThrowMiss = "FT_MISS"
    
    // Other stats
    case rebound = "REBOUND"
    case assist = "ASSIST"
    case steal = "STEAL"
    case block = "BLOCK"
    case turnover = "TURNOVER"
    case foul = "FOUL"
    
    // Team scoring
    case teamPoint = "TEAM_POINT"
    
    var pointValue: Int {
        switch self {
        case .freeThrowMade: return 1
        case .twoPointMade, .teamPoint: return 2
        case .threePointMade: return 3
        default: return 0
        }
    }
    
    var displayName: String {
        switch self {
        case .twoPointMade: return "2PT ✓"
        case .twoPointMiss: return "2PT ✗"
        case .threePointMade: return "3PT ✓"
        case .threePointMiss: return "3PT ✗"
        case .freeThrowMade: return "FT ✓"
        case .freeThrowMiss: return "FT ✗"
        case .rebound: return "REB"
        case .assist: return "AST"
        case .steal: return "STL"
        case .block: return "BLK"
        case .turnover: return "TO"
        case .foul: return "PF"
        case .teamPoint: return "+PTS"
        }
    }
    
    var icon: String {
        switch self {
        case .twoPointMade, .threePointMade:
            return "basketball.fill"
        case .twoPointMiss, .threePointMiss:
            return "xmark.circle"
        case .freeThrowMade:
            return "checkmark.circle.fill"
        case .freeThrowMiss:
            return "xmark.circle.fill"
        case .rebound:
            return "arrow.up.circle.fill"
        case .assist:
            return "hand.raised.fill"
        case .steal:
            return "hand.point.up.left.fill"
        case .block:
            return "hand.raised.slash.fill"
        case .turnover:
            return "arrow.triangle.2.circlepath"
        case .foul:
            return "exclamationmark.triangle.fill"
        case .teamPoint:
            return "plus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .twoPointMade, .threePointMade, .freeThrowMade:
            return .statMade
        case .twoPointMiss, .threePointMiss, .freeThrowMiss:
            return .statMissed
        case .rebound, .assist, .steal, .block:
            return .statPositive
        case .turnover, .foul:
            return .statNegative
        case .teamPoint:
            return .statTeam
        }
    }
}
```

**Verification:**
- [x] Enum compiles
- [x] All 13 stat types defined
- [x] Point values correct (1, 2, 3, or 0)
- [x] All SF Symbol names valid (check in SF Symbols app)

---

### Task 1.7: Create Domain Models

**Time Estimate:** 40 minutes

#### File: `Core/Domain/Models/LiveStats.swift`

```swift
import Foundation

struct LiveStats {
    var points: Int = 0
    var fgMade: Int = 0
    var fgAttempted: Int = 0
    var fgPercentage: Double = 0.0
    var threeMade: Int = 0
    var threeAttempted: Int = 0
    var threePercentage: Double = 0.0
    var ftMade: Int = 0
    var ftAttempted: Int = 0
    var ftPercentage: Double = 0.0
    var rebounds: Int = 0
    var assists: Int = 0
    var steals: Int = 0
    var blocks: Int = 0
    var turnovers: Int = 0
    var fouls: Int = 0
    
    mutating func updatePercentages() {
        fgPercentage = fgAttempted > 0 ? Double(fgMade) / Double(fgAttempted) * 100 : 0
        threePercentage = threeAttempted > 0 ? Double(threeMade) / Double(threeAttempted) * 100 : 0
        ftPercentage = ftAttempted > 0 ? Double(ftMade) / Double(ftAttempted) * 100 : 0
    }
    
    mutating func recordStat(_ statType: StatType) {
        switch statType {
        case .freeThrowMade:
            ftMade += 1
            ftAttempted += 1
            points += 1
        case .freeThrowMiss:
            ftAttempted += 1
        case .twoPointMade:
            fgMade += 1
            fgAttempted += 1
            points += 2
        case .twoPointMiss:
            fgAttempted += 1
        case .threePointMade:
            threeMade += 1
            threeAttempted += 1
            fgMade += 1
            fgAttempted += 1
            points += 3
        case .threePointMiss:
            threeAttempted += 1
            fgAttempted += 1
        case .rebound:
            rebounds += 1
        case .assist:
            assists += 1
        case .steal:
            steals += 1
        case .block:
            blocks += 1
        case .turnover:
            turnovers += 1
        case .foul:
            fouls += 1
        case .teamPoint:
            break
        }
        
        updatePercentages()
    }
    
    mutating func reverseStat(_ statType: StatType) {
        switch statType {
        case .freeThrowMade:
            ftMade -= 1
            ftAttempted -= 1
            points -= 1
        case .freeThrowMiss:
            ftAttempted -= 1
        case .twoPointMade:
            fgMade -= 1
            fgAttempted -= 1
            points -= 2
        case .twoPointMiss:
            fgAttempted -= 1
        case .threePointMade:
            threeMade -= 1
            threeAttempted -= 1
            fgMade -= 1
            fgAttempted -= 1
            points -= 3
        case .threePointMiss:
            threeAttempted -= 1
            fgAttempted -= 1
        case .rebound:
            rebounds -= 1
        case .assist:
            assists -= 1
        case .steal:
            steals -= 1
        case .block:
            blocks -= 1
        case .turnover:
            turnovers -= 1
        case .foul:
            fouls -= 1
        case .teamPoint:
            break
        }
        
        updatePercentages()
    }
}
```

#### File: `Core/Domain/Models/CareerStats.swift`

```swift
import Foundation

struct CareerStats {
    let childId: UUID
    let childName: String
    let totalGames: Int
    
    // Overall averages
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
    let stealsPerGame: Double
    let blocksPerGame: Double
    
    // Totals
    let totalPoints: Int
    let totalRebounds: Int
    let totalAssists: Int
    let totalSteals: Int
    let totalBlocks: Int
    let totalTurnovers: Int
    let totalFouls: Int
    
    // Shooting
    let fieldGoalMade: Int
    let fieldGoalAttempted: Int
    let fieldGoalPercentage: Double
    
    let threePointMade: Int
    let threePointAttempted: Int
    let threePointPercentage: Double
    
    let freeThrowMade: Int
    let freeThrowAttempted: Int
    let freeThrowPercentage: Double
    
    // Career highs
    let careerHighPoints: Int
    let careerHighRebounds: Int
    let careerHighAssists: Int
    
    // Team breakdown
    let teamStats: [TeamSeasonStats]
}

struct TeamSeasonStats {
    let teamName: String
    let season: String
    let organization: String?
    let games: Int
    let wins: Int
    let losses: Int
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
}
```

**Verification:**
- [x] Both files compile
- [x] LiveStats can record and reverse stats
- [x] Percentages calculate correctly

---

## Phase 2: Design System

### Task 2.1: Create Color System

**Time Estimate:** 15 minutes

**File:** `DesignSystem/Colors.swift`

```swift
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
```

**Test in Preview:**

```swift
struct ColorsPreview: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Color.statMade.frame(width: 50, height: 50)
                Text("Made")
            }
            HStack {
                Color.statMissed.frame(width: 50, height: 50)
                Text("Missed")
            }
            HStack {
                Color.appBackground.frame(width: 50, height: 50)
                Text("Background")
            }
        }
        .padding()
    }
}

struct ColorsPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ColorsPreview()
                .preferredColorScheme(.light)
            ColorsPreview()
                .preferredColorScheme(.dark)
        }
    }
}
```

**Verification:**
- [ ] Colors compile
- [ ] Preview shows different colors in light/dark mode
- [ ] No custom hex values used

---

### Task 2.2: Create Typography System

**Time Estimate:** 15 minutes

**File:** `DesignSystem/Fonts.swift`

```swift
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
```

**Test in Preview:**

```swift
struct FontsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("52").font(.scoreLarge)
            Text("Alex Johnson").font(.playerName)
            Text("REB").font(.statLabel)
            Text("5").font(.statValue)
            Text("#12 Marcus Williams").font(.teamRow)
            Text("4/8 FG (50%)").font(.summaryText)
        }
        .padding()
    }
}
```

**Verification:**
- [ ] Fonts compile
- [ ] Preview shows different text sizes
- [ ] Works with Dynamic Type (test in Settings → Accessibility)

---

### Task 2.3: Create Spacing System

**Time Estimate:** 10 minutes

**File:** `DesignSystem/Spacing.swift`

```swift
import SwiftUI

extension CGFloat {
    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 24
    
    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusButton: CGFloat = 12
    static let cornerRadiusCard: CGFloat = 16
    
    // MARK: - Button Sizes
    static let buttonSizeFocus: CGFloat = 56
    static let buttonSizeTeam: CGFloat = 48
    static let buttonSizeOpponent: CGFloat = 52
    static let buttonSizeUndo: CGFloat = 50
}
```

**Verification:**
- [ ] File compiles
- [ ] Values can be used: `.padding(.spacingL)`
- [ ] Button sizes match specification

---

## Testing Foundation

### Task 3.1: Create Unit Tests for LiveStats

**Time Estimate:** 45 minutes

**File:** `Tests/BasketballStatsTests/LiveStatsTests.swift`

```swift
import XCTest
@testable import BasketballStats

class LiveStatsTests: XCTestCase {
    var sut: LiveStats!
    
    override func setUp() {
        super.setUp()
        sut = LiveStats()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Two Point Tests
    func testRecordTwoPointMade() {
        sut.recordStat(.twoPointMade)
        
        XCTAssertEqual(sut.points, 2)
        XCTAssertEqual(sut.fgMade, 1)
        XCTAssertEqual(sut.fgAttempted, 1)
        XCTAssertEqual(sut.fgPercentage, 100.0)
    }
    
    func testRecordTwoPointMiss() {
        sut.recordStat(.twoPointMiss)
        
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.fgMade, 0)
        XCTAssertEqual(sut.fgAttempted, 1)
        XCTAssertEqual(sut.fgPercentage, 0.0)
    }
    
    // MARK: - Three Point Tests
    func testRecordThreePointMade() {
        sut.recordStat(.threePointMade)
        
        XCTAssertEqual(sut.points, 3)
        XCTAssertEqual(sut.fgMade, 1)
        XCTAssertEqual(sut.fgAttempted, 1)
        XCTAssertEqual(sut.threeMade, 1)
        XCTAssertEqual(sut.threeAttempted, 1)
        XCTAssertEqual(sut.fgPercentage, 100.0)
        XCTAssertEqual(sut.threePercentage, 100.0)
    }
    
    // MARK: - Percentage Calculation Tests
    func testFieldGoalPercentage() {
        sut.recordStat(.twoPointMade)
        sut.recordStat(.twoPointMade)
        sut.recordStat(.twoPointMiss)
        sut.recordStat(.twoPointMiss)
        
        XCTAssertEqual(sut.fgMade, 2)
        XCTAssertEqual(sut.fgAttempted, 4)
        XCTAssertEqual(sut.fgPercentage, 50.0)
    }
    
    func testPercentageWithZeroAttempts() {
        XCTAssertEqual(sut.fgPercentage, 0.0)
        XCTAssertEqual(sut.threePercentage, 0.0)
        XCTAssertEqual(sut.ftPercentage, 0.0)
    }
    
    // MARK: - Reverse Stat Tests
    func testReverseTwoPointMade() {
        sut.recordStat(.twoPointMade)
        XCTAssertEqual(sut.points, 2)
        
        sut.reverseStat(.twoPointMade)
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.fgMade, 0)
        XCTAssertEqual(sut.fgAttempted, 0)
    }
    
    func testReverseThreePointMade() {
        sut.recordStat(.threePointMade)
        XCTAssertEqual(sut.points, 3)
        XCTAssertEqual(sut.threeMade, 1)
        
        sut.reverseStat(.threePointMade)
        XCTAssertEqual(sut.points, 0)
        XCTAssertEqual(sut.threeMade, 0)
        XCTAssertEqual(sut.fgMade, 0)
    }
    
    // MARK: - Other Stats Tests
    func testRecordRebound() {
        sut.recordStat(.rebound)
        XCTAssertEqual(sut.rebounds, 1)
    }
    
    func testRecordAssist() {
        sut.recordStat(.assist)
        XCTAssertEqual(sut.assists, 1)
    }
    
    func testRecordMultipleStats() {
        sut.recordStat(.twoPointMade)
        sut.recordStat(.rebound)
        sut.recordStat(.assist)
        
        XCTAssertEqual(sut.points, 2)
        XCTAssertEqual(sut.rebounds, 1)
        XCTAssertEqual(sut.assists, 1)
    }
}
```

**Run Tests:**
```
⌘+U (Run all tests)
```

**Verification:**
- [ ] All tests pass
- [ ] Code coverage > 80% for LiveStats
- [ ] No test failures

---

## Common Pitfalls

### Pitfall 1: NSManagedObject Subclass Conflicts

**Problem:**
```swift
// ❌ WRONG: Manual class definition
class Child: NSManagedObject {
    var id: UUID
    var name: String
}
```

**Solution:**
- Set Codegen to "Class Definition" in Core Data model
- Only write extensions, never the class itself
- Xcode auto-generates the class

---

### Pitfall 2: Background Context Crashes

**Problem:**
```swift
// ❌ WRONG: Using main context objects in background
Task.detached {
    let event = StatEvent(context: mainContext) // Crash!
}
```

**Solution:**
```swift
// ✅ CORRECT: Use background context
Task.detached {
    let context = CoreDataStack.shared.newBackgroundContext()
    let event = StatEvent(context: context)
}
```

---

### Pitfall 3: Relationship Delete Rules

**Problem:** Deleting Team doesn't delete Players

**Solution:**
- Team → Players: Delete Rule = Cascade
- Player → Team: Delete Rule = Nullify
- Set in Core Data model inspector

---

## Checkpoint

### Before Moving to Part 2

Verify all these items:

**Core Data:**
**Core Data:**
- [x] All 5 entities created with correct attributes
- [x] All relationships configured with inverses
- [x] Indexes created
- [x] Entity extensions compile and work
- [x] Can create, save, and fetch entities
- [x] CoreDataStack functional

**Domain Models:**
**Domain Models:**
- [x] StatType enum compiles (13 types)
- [x] LiveStats model works
- [x] CareerStats model defined

**Design System:**
**Design System:**
- [x] Colors defined (semantic, not hex)
- [x] Fonts defined (Dynamic Type)
- [x] Spacing values defined
- [x] Dark mode works

**Testing:**
**Testing:**
- [x] LiveStats tests pass (all green)
- [ ] Code coverage > 80%
- [x] No compiler warnings
- [x] App builds and runs

**Quality:**
- [ ] No force unwraps
- [ ] No print statements in production code
- [ ] Proper error handling
- [ ] Code formatted consistently

---

## Next Steps

Once this checkpoint is complete:

**→ Continue to Part 2:** UI Framework & Components (Weeks 3-4)

Part 2 will cover:
- Component library (StatButton, TeamScoreButton, etc.)
- Navigation structure (Tab bar, coordinator)
- Home screen implementation
- SwiftUI best practices

---

**End of Part 1**

*Estimated completion: 30-40 hours*  
*When complete, you'll have a solid foundation for building the UI in Part 2*
