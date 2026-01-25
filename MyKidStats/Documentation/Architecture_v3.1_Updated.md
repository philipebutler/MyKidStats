# Basketball Stats Tracker - Architecture Document v3.1

## Updated: Multi-Child Support + iOS-Native UI/UX Patterns

**Last Updated:** January 2026  
**Version:** 3.1  
**Status:** Updated based on comprehensive UI/UX interview

---

## Document Information

- **Version:** 3.1
- **Previous Version:** 2.0 (single child, custom UI patterns)
- **Major Changes:** Multi-child support, iOS-native design system, refined navigation
- **Interview Date:** January 2026

---

## Executive Summary

### What Changed from v2.0

#### Multi-Child Support
- **Before:** Track ONE child across multiple teams
- **After:** Track 2+ children, each with independent career stats
- **Game Flow:** One focus child per game with smart default selection

#### Navigation Pattern
- **Before:** Undefined navigation structure
- **After:** Tab bar (Home/Live/Stats/Teams) + Sidebar for secondary features

#### Design System
- **Before:** Custom hex colors, arbitrary button sizes, generic iOS patterns
- **After:** iOS semantic colors, SF Symbols, Dynamic Type, 56pt optimized buttons

#### User Experience Refinements
- Smart default child selection (remembers last used)
- Segmented control for switching between children in stats view
- Floating undo button (iOS standard pattern)
- Auto-navigate to game summary with season comparison
- Minimal visual feedback for performance (haptic + counter updates only)

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Multi-Child Architecture](#2-multi-child-architecture)
3. [Core Data Model](#3-core-data-model)
4. [Navigation & User Flow](#4-navigation--user-flow)
5. [iOS-Native Design System](#5-ios-native-design-system)
6. [Live Game Performance](#6-live-game-performance)
7. [Career Stats System](#7-career-stats-system)
8. [Export & Sharing](#8-export--sharing)
9. [Implementation Phases](#9-implementation-phases)
10. [Success Criteria](#10-success-criteria)

---

## 1. System Overview

### 1.1 Application Purpose

A native iOS app for real-time basketball statistics tracking with focus on:

- **PRIMARY:** Detailed stats for YOUR CHILDREN (2+) across multiple teams/seasons
- **SECONDARY:** Team scoring for all teammates
- **TERTIARY:** Individual career statistics per child regardless of team changes

### 1.2 Key Architectural Principles

#### Speed First
- **Target:** < 50ms stat recording latency
- **Approach:** Synchronous UI updates, asynchronous data persistence
- **Rationale:** User must capture stats in 3-second game action windows

#### iOS-Native Design
- Semantic color system (automatic dark mode)
- SF Symbols throughout
- Dynamic Type support (accessibility)
- Standard iOS navigation patterns
- Haptic feedback using system generators

#### Offline First
- No network required for core functionality
- All data stored locally in Core Data
- Optional iCloud sync for backup only

#### Multi-Child Career Tracking
- Each child marked with unique `childId`
- One focus child per game
- Career stats calculated per child across all teams
- Team switching preserves all historical data

### 1.3 Technology Stack

```
┌─────────────────────────────────────────────────┐
│         Presentation Layer (SwiftUI)            │
│    Tab Bar + Sidebar Navigation + Sheets        │
├─────────────────────────────────────────────────┤
│        Business Logic Layer (MVVM)              │
│   ViewModels + Use Cases + Calculators          │
├─────────────────────────────────────────────────┤
│      Data Access Layer (Repositories)           │
│        Repositories + DTOs + Mappers            │
├─────────────────────────────────────────────────┤
│      Persistence Layer (Core Data)              │
│   Core Data + CloudKit (optional) + UserDefaults│
└─────────────────────────────────────────────────┘
```

**Platform & Frameworks:**
- **Platform:** iOS 16+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (100% SwiftUI, no UIKit except export)
- **Data:** Core Data with optional CloudKit sync
- **Reactive:** Combine publishers
- **Export:** Native share sheet, Files framework, CSV generation

**Zero External Dependencies:**
- All functionality using native Apple frameworks
- No third-party libraries

---

## 2. Multi-Child Architecture

### 2.1 Child Management System

The app supports tracking multiple children (typically 2, theoretically unlimited). Each child has their own career stats tracked independently.

#### Key Concepts

| Concept | Description |
|---------|-------------|
| **Child Entity** | Core identity (name, photo, DOB) - exists independently of teams |
| **Player Entity** | Child + Team linkage (jersey #, position) - join entity |
| **Focus Child** | The child being tracked in the current game |
| **Smart Default** | App remembers last-used child for quick game start |

#### Data Relationships

```
Child ──┬─→ Player (Warriors) ──→ StatEvents (Game 1, 2, 3...)
        │
        ├─→ Player (Eagles) ──→ StatEvents (Game 4, 5, 6...)
        │
        └─→ Player (Thunder) ──→ StatEvents (Game 7, 8, 9...)

Career Stats = Aggregate ALL StatEvents across ALL Player instances for this Child
```

### 2.2 Game Start Flow

**Scenario:** User has two children - Alex and Jordan

#### Step 1: User opens app
Home screen shows:
```
Ready for today's game?
[▶ Start Game for Alex]  ← Last used child (smart default)
[Switch to Jordan →]
```

#### Step 2A: If user taps "Start Game for Alex"
1. App finds Alex's active team (e.g., Warriors)
2. Creates new Game entity linked to Warriors
3. Sets Alex as `focusChildId` for the game
4. Navigates to Live Game screen
5. Updates Alex's `lastUsed` timestamp

#### Step 2B: If user taps "Switch to Jordan"
1. Button text updates to "Start Game for Jordan"
2. Shows Jordan's team info
3. User taps to start Jordan's game
4. Same flow as Step 2A but for Jordan

### 2.3 Career Stats Calculation

**Query Pattern:**
```swift
// Find all Player instances for this child
let players = Player.fetchAll(where: childId == targetChildId)

// Get all stat events across all those players
let allStats = StatEvent.fetchAll(where: playerId IN players.map { $0.id })

// Aggregate
let careerStats = calculateAggregatedStats(allStats)
```

This automatically includes stats from:
- Current team
- Past teams
- Any team the child has ever played on

---

## 3. Core Data Model

### 3.1 Entity Overview

| Entity | Purpose | Key Changes from v2.0 |
|--------|---------|----------------------|
| **Child** | Core identity (name, photo, DOB) | **NEW ENTITY** |
| **Player** | Links Child to Team (jersey #, position) | Added `childId`, removed `isYourChild` and `name` |
| **Team** | Team identity (name, season, organization) | Added `isActive` flag |
| **Game** | Game instance (opponent, date, score) | Added `focusChildId` |
| **StatEvent** | Individual stat occurrence | No changes |

### 3.2 NEW: Child Entity

```swift
/// Core identity - exists independently of teams
@objc(Child)
public class Child: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var photoData: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var lastUsed: Date  // For smart defaults
    
    // Relationships
    @NSManaged public var playerInstances: NSSet?  // All Player entities across teams
}

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

**Usage Pattern:**
- One `Child` entity per actual child
- Child can have multiple `Player` instances (one per team)
- `lastUsed` field enables smart default selection
- Career stats query aggregates all `Player` instances for this `Child`

### 3.3 UPDATED: Player Entity

```swift
/// Links Child to Team with team-specific information
@objc(Player)
public class Player: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var childId: UUID      // ← NEW: Foreign key to Child
    @NSManaged public var teamId: UUID       // Foreign key to Team
    @NSManaged public var jerseyNumber: String?
    @NSManaged public var position: String?
    @NSManaged public var createdAt: Date
    
    // Relationships
    @NSManaged public var child: Child?
    @NSManaged public var team: Team?
    @NSManaged public var statEvents: NSSet?
}

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

**Key Changes from v2.0:**
- ❌ **REMOVED:** `isYourChild: Bool` (replaced by `childId` reference)
- ✅ **ADDED:** `childId: UUID` (links to Child entity)
- ❌ **REMOVED:** `name: String` (now stored in Child entity)
- Player is now purely a join entity between Child and Team

### 3.4 UPDATED: Team Entity

```swift
@objc(Team)
public class Team: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var season: String
    @NSManaged public var organization: String?  // "YMCA U12", "School League"
    @NSManaged public var isActive: Bool         // ← NEW: Only one active per child
    @NSManaged public var createdAt: Date
    @NSManaged public var colorHex: String?
    
    @NSManaged public var players: NSSet?
    @NSManaged public var games: NSSet?
}

extension Team {
    /// Find active team for a specific child
    static func fetchActive(forChildId childId: UUID, context: NSManagedObjectContext) -> Team? {
        // Find player with this childId where team.isActive = true
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

### 3.5 UPDATED: Game Entity

```swift
@objc(Game)
public class Game: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var teamId: UUID
    @NSManaged public var focusChildId: UUID    // ← NEW: Which child was tracked
    @NSManaged public var opponentName: String
    @NSManaged public var opponentScore: Int32
    @NSManaged public var gameDate: Date
    @NSManaged public var location: String?
    @NSManaged public var isComplete: Bool
    @NSManaged public var duration: Int32
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    @NSManaged public var team: Team?
    @NSManaged public var statEvents: NSSet?
    
    // Computed team score
    var teamScore: Int {
        guard let events = statEvents as? Set<StatEvent> else { return 0 }
        return events
            .filter { $0.isPointEvent && !$0.isDeleted }
            .reduce(0) { $0 + Int($1.value) }
    }
    
    var result: GameResult {
        guard isComplete else { return .inProgress }
        if teamScore > opponentScore { return .win }
        if teamScore < opponentScore { return .loss }
        return .tie
    }
}
```

### 3.6 StatEvent Entity (No Changes)

```swift
@objc(StatEvent)
public class StatEvent: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var playerId: UUID
    @NSManaged public var gameId: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var statType: String  // StatType enum rawValue
    @NSManaged public var value: Int32
    @NSManaged public var isDeleted: Bool   // For undo functionality
    
    @NSManaged public var player: Player?
    @NSManaged public var game: Game?
    
    var isPointEvent: Bool {
        guard let type = StatType(rawValue: statType) else { return false }
        return type.pointValue > 0
    }
}
```

### 3.7 Database Indexing Strategy

**Indexed Fields:**
- `Child.id`
- `Child.lastUsed` ← NEW (for smart defaults)
- `Player.id`
- `Player.childId` ← NEW (for career queries)
- `Player.teamId`
- `Team.id`
- `Team.isActive` ← NEW
- `Game.id`
- `Game.teamId`
- `Game.focusChildId` ← NEW
- `Game.isComplete`
- `StatEvent.id`
- `StatEvent.playerId`
- `StatEvent.gameId`
- `StatEvent.isDeleted`
- `StatEvent.timestamp`

**Compound Indexes:**
- `(Player.childId, Player.teamId)` - Find child's player on specific team
- `(StatEvent.gameId, StatEvent.playerId, StatEvent.isDeleted)` - Most common query
- `(Game.focusChildId, Game.isComplete)` - Career stats query

---

## 4. Navigation & User Flow

### 4.1 Navigation Pattern: Tab Bar + Sidebar

#### Tab Bar (Primary Navigation)
Always visible at bottom of screen:

```
┌─────────────────────────────────────────┐
│                                         │
│         [Main Content Area]             │
│                                         │
└─────────────────────────────────────────┘
  [Home] [Live] [Stats] [Teams]
    🏠     ▶️     📊      👥
```

| Tab | Purpose | Icon |
|-----|---------|------|
| **Home** | Quick start, recent activity, smart child selection | `house.fill` (SF Symbol) |
| **Live** | Active game or start new game | `play.circle.fill` |
| **Stats** | Career stats with child switcher | `chart.bar.fill` |
| **Teams** | Team management, rosters | `person.3.fill` |

#### Sidebar/Menu (Secondary Navigation)
Accessible via hamburger menu or swipe gesture:

- Game History (all games across all children)
- Children Management (add/edit children)
- Export & Sharing (bulk export options)
- Settings (preferences, iCloud sync)
- Help & Support

#### Why This Pattern?

✅ **Pros:**
- Single tap to core functions (Home/Live/Stats/Teams)
- Less-frequent features don't clutter main UI
- Standard iOS pattern (familiar to users)
- iPad-friendly (sidebar can be permanent on larger screens)
- Maintains focus on live game tracking

❌ **What We Avoided:**
- Deep hierarchical navigation (too many taps during games)
- All-tab-bar approach (5+ tabs is cluttered)
- All-sidebar approach (core functions need quick access)

### 4.2 Screen Hierarchy

#### Primary Screens (Tab Bar)

**1. Home Screen**
- Purpose: Quick game start with smart defaults
- Shows: Last-used child, quick toggle, recent activity
- Actions: Start game (1 tap), switch child, view recent games

**2. Live Game Screen**
- Purpose: Real-time stat tracking (95% of usage time)
- Shows: Focus child stats, team scoring, opponent score
- Actions: Record stats, undo, end game

**3. Stats Screen**
- Purpose: Career statistics per child
- Shows: Segmented control (child switcher), career totals, breakdown by team
- Actions: Switch between children, drill into team details, export career stats

**4. Teams Screen**
- Purpose: Team management
- Shows: Active team per child, roster, team info
- Actions: Switch active team, edit roster, view team games

#### Modal/Sheet Screens

**Game Summary Sheet**
- Triggered: Auto-shows after ending game
- Shows: Focus child stats, season comparison, team performance
- Actions: Share (text/files), save to Files, view details

**Team Creation Sheet**
- Triggered: "Create New Team" button
- Shows: Team name, season, organization, age group
- Actions: Create team, add child to roster

**Child Management Sheet**
- Triggered: Settings → Manage Children
- Shows: List of children, add/edit forms
- Actions: Add child, edit child info, set photo

### 4.3 Navigation Implementation

```swift
// Main app structure
struct BasketballStatsApp: App {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
    var body: some View {
        TabView(selection: $navigationCoordinator.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(Tab.home)
            
            LiveGameView()
                .tabItem { Label("Live", systemImage: "play.circle.fill") }
                .tag(Tab.live)
            
            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                .tag(Tab.stats)
            
            TeamsView()
                .tabItem { Label("Teams", systemImage: "person.3.fill") }
                .tag(Tab.teams)
        }
        .sheet(item: $navigationCoordinator.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
    }
}

enum Tab {
    case home, live, stats, teams
}
```

---

## 5. iOS-Native Design System

### 5.1 Color System

**⚠️ CRITICAL: Use iOS Semantic Colors, NOT Custom Hex Values**

#### Why Semantic Colors?

✅ **Benefits:**
- Automatic light/dark mode support
- Respects user's accessibility settings (high contrast)
- Consistent with iOS system appearance
- Future-proof (adapts to OS updates)
- Better battery life (dark mode uses less power on OLED)

❌ **Problems with Hex Colors:**
- Manual dark mode implementation required
- Inconsistent with system appearance
- Accessibility issues (contrast ratios)
- Maintenance overhead

#### Color Definitions

```swift
extension Color {
    // STAT BUTTONS - Use iOS system colors
    static let statMade = Color.green        // Made shots
    static let statMissed = Color.red        // Missed shots
    static let statPositive = Color.blue     // REB, AST, STL, BLK
    static let statNegative = Color.orange   // TO, FOUL
    
    // BACKGROUNDS - Automatic light/dark mode
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let appBackground = Color(uiColor: .systemGroupedBackground)
    
    // TEXT - Semantic hierarchy
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
    
    // SYSTEM ELEMENTS
    static let separator = Color(uiColor: .separator)
    static let fill = Color(uiColor: .systemFill)
}
```

#### Color Usage Table

| Use Case | Light Mode | Dark Mode | Code |
|----------|------------|-----------|------|
| Made shots | Green | Green (adjusted) | `Color.green` |
| Missed shots | Red | Red (adjusted) | `Color.red` |
| Positive stats | Blue | Blue (adjusted) | `Color.blue` |
| Negative stats | Orange | Orange (adjusted) | `Color.orange` |
| Card backgrounds | White/Light Gray | Dark Gray | `Color(uiColor: .secondarySystemGroupedBackground)` |
| App background | Light Gray | Black | `Color(uiColor: .systemGroupedBackground)` |

### 5.2 Typography System

**Use Dynamic Type - NOT Fixed Point Sizes**

#### Why Dynamic Type?

✅ **Benefits:**
- Automatic text size scaling (user preference)
- Accessibility compliance (larger text for vision impaired)
- iOS standard behavior (familiar to users)
- Less code (system handles scaling)

#### Typography Definitions

```swift
extension Font {
    // SCORES & LARGE NUMBERS
    static let scoreLarge = Font.system(.largeTitle, design: .rounded, weight: .bold)
    // Example: "52" (team score) - auto-scales from ~34pt to ~53pt
    
    // PLAYER NAMES & HEADINGS
    static let playerName = Font.system(.title2, design: .default, weight: .semibold)
    // Example: "Alex Johnson" - auto-scales from ~22pt to ~34pt
    
    // STAT LABELS (on buttons)
    static let statLabel = Font.system(.caption, design: .rounded, weight: .medium)
    // Example: "REB" - auto-scales from ~12pt to ~19pt
    
    // STAT VALUES (counts on buttons)
    static let statValue = Font.system(.title3, design: .rounded, weight: .bold)
    // Example: "5" (rebound count) - auto-scales from ~20pt to ~31pt
    
    // TEAM SCORING ROWS
    static let teamRow = Font.system(.body, design: .default, weight: .regular)
    // Example: "#12 Sarah Johnson" - auto-scales from ~17pt to ~27pt
    
    // SUMMARY TEXT
    static let summaryText = Font.system(.caption, design: .default, weight: .regular)
    // Example: "4/8 FG (50%)" - auto-scales from ~12pt to ~19pt
}
```

#### Text Style Scale Ranges

| Style | Default Size | Large Accessibility | Extra Large |
|-------|--------------|---------------------|-------------|
| `.largeTitle` | 34pt | 43pt | 53pt |
| `.title` | 28pt | 36pt | 44pt |
| `.title2` | 22pt | 28pt | 34pt |
| `.title3` | 20pt | 25pt | 31pt |
| `.body` | 17pt | 22pt | 27pt |
| `.caption` | 12pt | 15pt | 19pt |

### 5.3 SF Symbols Integration

**Use System Icons, NOT Custom Images**

#### Why SF Symbols?

✅ **Benefits:**
- Matches iOS system aesthetic
- Automatic weight/size variants
- Multicolor support
- Free (built into iOS)
- 5000+ symbols available

#### Key Symbols for This App

```swift
// Navigation
"house.fill"           // Home tab
"play.circle.fill"     // Live game tab
"chart.bar.fill"       // Stats tab
"person.3.fill"        // Teams tab

// Actions
"square.and.arrow.up"  // Share/Export
"arrow.uturn.backward" // Undo
"plus.circle.fill"     // Add team/player
"checkmark.circle"     // Complete game
"xmark.circle"         // Cancel/Delete

// Stats
"basketball.fill"      // Basketball/scoring
"figure.basketball"    // Player icon
"chart.line.uptrend"   // Trending up
"trophy.fill"          // Win/achievement

// Settings
"gear"                 // Settings
"cloud.fill"           // iCloud sync
"bell.fill"            // Notifications
```

### 5.4 Button Sizing

**Refined Button Dimensions Based on Usage**

| Button Type | Size | Usage | Rationale |
|-------------|------|-------|-----------|
| **Focus Player Stats** | 56x56pt | Most frequent (dozens per game) | Large enough to tap accurately, doesn't waste screen space |
| **Team Scoring** | 48x48pt | Frequent (several per game) | Slightly smaller, still comfortable |
| **Opponent Scoring** | 52x52pt | Moderate frequency | Middle ground |
| **Undo Button** | 50x50pt | Occasional but important | Noticeable but not intrusive |

#### Why 56pt for Focus Player?

✅ **Advantages:**
- 27% larger than minimum 44pt (very comfortable)
- 20% smaller than original 70pt plan (better screen utilization)
- Fits 12 buttons in 4x3 grid without scrolling (iPhone SE compatible)
- Tested optimal for rapid tapping in 3-second windows
- Allows room for stat count display on button

❌ **Why NOT 70pt?**
- Forces scrolling on smaller iPhones
- Wastes valuable screen real estate
- Makes interface feel cramped
- Team scoring section gets pushed too far down

### 5.5 Spacing & Layout

**iOS Standard Spacing Units**

```swift
extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 24
    
    static let cornerRadiusButton: CGFloat = 12
    static let cornerRadiusCard: CGFloat = 16
}
```

**Layout Grid:**
- Base unit: 4pt
- Button spacing: 12pt (3 units)
- Card padding: 16pt (4 units)
- Section spacing: 20pt (5 units)

### 5.6 Dark Mode Implementation

**Automatic - No Manual Switching Needed**

```swift
// Colors automatically adapt
struct StatButton: View {
    let type: StatType
    
    var body: some View {
        Button(action: recordStat) {
            VStack {
                Image(systemName: type.icon)
                Text(type.label)
                Text("\(count)")
                    .foregroundColor(.secondaryText)  // Auto light/dark
            }
            .frame(width: 56, height: 56)
            .background(type.color.opacity(0.15))     // Auto light/dark
            .cornerRadius(.cornerRadiusButton)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusButton)
                    .stroke(type.color, lineWidth: 2)
            )
        }
    }
}
```

**User Preference:**
- Setting: Follow iOS system setting (auto)
- No in-app toggle needed
- Respects system's auto-switching (based on time or manual toggle)

---

## 6. Live Game Performance

### 6.1 Performance Requirements

| Operation | Target | Maximum | Critical? |
|-----------|--------|---------|-----------|
| Stat tap → Haptic | < 10ms | 20ms | Yes |
| Stat tap → UI update | < 50ms | 100ms | **CRITICAL** |
| UI update → DB save | N/A | 500ms | No (background) |
| Undo operation | < 100ms | 200ms | Yes |
| Screen transition | < 300ms | 500ms | No |

### 6.2 Optimization Strategies

#### Synchronous Operations (Main Thread)
- Haptic feedback generation
- UI state updates (`@Published` properties)
- Creating Core Data objects in memory
- Counter increments

#### Asynchronous Operations (Background)
- Core Data saves to disk
- Complex stat calculations
- Large data fetches
- Export generation

### 6.3 Feedback Implementation

**Minimal Visual Feedback** (User Choice from Interview Q7)

```swift
@MainActor
class LiveGameViewModel: ObservableObject {
    @Published var currentStats: LiveStats = LiveStats()
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        hapticGenerator.prepare()  // Pre-warm for instant response
    }
    
    func recordFocusPlayerStat(_ statType: StatType) {
        // 1. Haptic feedback (< 10ms)
        hapticGenerator.impactOccurred()
        
        // 2. Update UI state (synchronous, < 50ms target)
        updateCurrentStats(with: statType)  // Counter updates only, no animation
        
        // 3. Create stat event
        let event = createStatEvent(statType)
        
        // 4. Store for undo
        lastAction = .focusPlayerStat(eventId: event.id, statType: statType)
        canUndo = true
        
        // 5. Save to Core Data (asynchronous, background)
        Task.detached(priority: .userInitiated) {
            try? await saveToDatabase(event)
        }
    }
}
```

**What User Sees:**
- Button tap
- Immediate haptic buzz
- Counter updates: "REB 5" → "REB 6"
- NO flash, NO pulse, NO animation
- Total time: < 50ms

**Why This Approach:**
- User chose "Option A: Minimal (Performance Priority)" in interview
- Fastest possible confirmation
- No visual distraction during rapid recording
- Battery friendly
- Haptic provides sufficient feedback

### 6.4 Haptic Strategy

**Same Haptic for All Actions** (User Choice from Interview Q19)

```swift
// One haptic pattern for everything - simple & consistent
let generator = UIImpactFeedbackGenerator(style: .medium)

// Focus player stat: Medium impact
generator.impactOccurred()

// Team scoring: Medium impact
generator.impactOccurred()

// Opponent scoring: Medium impact
generator.impactOccurred()

// Undo: Medium impact (same as recording)
generator.impactOccurred()
```

**Why Same Haptic for Everything:**
- User chose "Option A: Same Haptic for Everything" in interview
- Simpler implementation
- Lower battery usage
- One less thing to think about
- Consistent feel throughout app

---

## 7. Career Stats System

### 7.1 Career Stats Calculation

**Multi-Child Query Pattern:**

```swift
class CalculateCareerStatsUseCase {
    func execute(for childId: UUID) async throws -> CareerStats {
        // Step 1: Find all Player instances for this child
        let players = Player.fetchForChild(childId, context: context)
        
        // Step 2: Get all stat events across all those players
        let playerIds = players.map { $0.id }
        let allStats = StatEvent.fetchAll(where: playerId IN playerIds)
        
        // Step 3: Get all games where child participated
        let gameIds = Set(allStats.map { $0.gameId })
        let allGames = Game.fetchAll(where: id IN gameIds && isComplete == true)
        
        // Step 4: Aggregate stats
        return aggregateStats(allStats, allGames, players)
    }
}
```

### 7.2 Stats Display with Child Switcher

**Segmented Control Implementation** (User Choice from Interview Q4)

```swift
struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @State private var selectedChildId: UUID
    
    var body: some View {
        VStack {
            // Segmented control to switch between children
            Picker("Child", selection: $selectedChildId) {
                ForEach(viewModel.children) { child in
                    Text(child.name).tag(child.id)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Career stats for selected child
            CareerStatsView(childId: selectedChildId)
        }
        .onChange(of: selectedChildId) { newId in
            viewModel.loadStats(for: newId)
        }
    }
}
```

### 7.3 Career Stats Breakdown

**Combined Overview with Drill-Down** (User Choice from Interview Q14)

```
┌─────────────────────────────────────┐
│ ALEX JOHNSON - 47 Career Games     │
├─────────────────────────────────────┤
│ Overall: 12.3 PPG, 5.1 RPG, 3.2 APG│
│                                     │
│ By Team:                            │
│ Warriors (current): 12.1 PPG - 11 games  │
│ Eagles: 13.2 PPG - 18 games         │
│ Thunder: 11.8 PPG - 18 games        │
│                                     │
│ [View Trends] [View All Games] [Export] │
└─────────────────────────────────────┘
```

**Data Structure:**

```swift
struct CareerStats {
    let childId: UUID
    let totalGames: Int
    
    // Overall averages
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
    
    // Totals
    let totalPoints: Int
    let totalRebounds: Int
    let totalAssists: Int
    // ... other stats
    
    // Shooting percentages
    let fieldGoalPercentage: Double
    let threePointPercentage: Double
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
    let games: Int
    let wins: Int
    let losses: Int
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
}
```

---

## 8. Export & Sharing

### 8.1 Export Formats

**Priority Formats** (User Choice from Interview Q13)

| Format | Use Case | Priority |
|--------|----------|----------|
| **Text Message** | Quick share to family after game | HIGH |
| **CSV** | Personal record keeping, spreadsheets | HIGH |
| **PDF** | Professional reports (Phase 2) | LOW |
| **Screenshot** | Social media (Phase 2) | LOW |

### 8.2 Text Message Template

```swift
class TextMessageGenerator {
    func generateGameSummary(game: Game, focusChild: Child) -> String {
        let player = game.focusPlayer
        let stats = calculateGameStats(game, player)
        let teamName = game.team?.name ?? "Team"
        let result = game.result.emoji
        
        return """
        🏀 \(focusChild.name)'s Game - \(formatDate(game.gameDate))
        
        \(teamName) \(game.teamScore), \(game.opponentName) \(game.opponentScore) \(result)
        
        \(focusChild.name): \(stats.points) PTS, \(stats.rebounds) REB, \(stats.assists) AST
        \(stats.fgMade)-\(stats.fgAttempted) FG (\(stats.fgPercentage)%) | \(stats.threeMade)-\(stats.threeAttempted) 3PT | \(stats.ftMade)-\(stats.ftAttempted) FT
        \(stats.turnovers) TO | \(stats.fouls) PF
        
        Season: \(seasonAvgs.pointsPerGame) PPG, \(seasonAvgs.reboundsPerGame) RPG
        """
    }
}

extension GameResult {
    var emoji: String {
        switch self {
        case .win: return "✓ WIN"
        case .loss: return "✗ LOSS"
        case .tie: return "TIE"
        case .inProgress: return "IP"
        }
    }
}
```

### 8.3 CSV Export

```swift
class CSVExporter {
    func exportGame(_ game: Game) throws -> URL {
        var csv = "Game Statistics\n"
        csv += "Date,Opponent,Player,Number,Points,FGM,FGA,FG%,3PM,3PA,3P%,FTM,FTA,FT%,REB,AST,STL,BLK,TO,PF\n"
        
        // Export all players who participated
        for player in game.participatingPlayers {
            let stats = calculateStats(player, game)
            csv += formatPlayerRow(player, stats, game)
        }
        
        return try saveToTemporaryFile(csv, filename: makeFilename(game))
    }
}
```

### 8.4 Share Sheet Integration

**iOS Native Share Sheet**

```swift
struct GameSummaryView: View {
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        VStack {
            // ... game summary content ...
            
            HStack(spacing: 12) {
                Button(action: shareAsText) {
                    Label("Text Stats", systemImage: "message.fill")
                }
                
                Button(action: saveToFiles) {
                    Label("Save to Files", systemImage: "folder.fill")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
    }
    
    func shareAsText() {
        let text = TextMessageGenerator().generateGameSummary(game, focusChild)
        shareItems = [text]
        showingShareSheet = true
    }
    
    func saveToFiles() {
        let csvURL = try? CSVExporter().exportGame(game)
        if let url = csvURL {
            shareItems = [url]
            showingShareSheet = true
        }
    }
}
```

---

## 9. Implementation Phases

### Phase 1: MVP (6-8 weeks)

#### Week 1-2: Multi-Child Core Data Foundation
**Deliverables:**
- Create `Child` entity with migrations
- Update `Player` entity (add `childId`, remove `isYourChild`, remove `name`)
- Update `Game` entity (add `focusChildId`)
- Child selection and smart defaults logic
- Database migrations from v2.0 schema

**Tasks:**
- [ ] Design Core Data model v3
- [ ] Write migration code
- [ ] Implement `Child` entity and extensions
- [ ] Update `Player` entity
- [ ] Update `Game` entity
- [ ] Write unit tests for data layer
- [ ] Test migrations with sample v2.0 data

#### Week 3-4: iOS-Native UI Foundation
**Deliverables:**
- Semantic color system implemented
- Dynamic Type support across all text
- SF Symbols integration
- Tab bar navigation structure
- Home screen with smart child selection

**Tasks:**
- [ ] Create `Color` extension with semantic colors
- [ ] Create `Font` extension with dynamic type styles
- [ ] Replace all custom icons with SF Symbols
- [ ] Implement tab bar structure
- [ ] Build home screen UI
- [ ] Smart default child selection logic
- [ ] Test dark mode appearance
- [ ] Test with various text sizes

#### Week 5-6: Live Game Interface
**Deliverables:**
- Focus player stat buttons (12 stats, 56pt size)
- Team scoring section (smart collapse)
- Opponent scoring header
- Floating undo button
- Real-time stat calculations
- Performance optimization (< 50ms target)

**Tasks:**
- [ ] Design stat button component (56x56pt)
- [ ] Implement all 12 stat types
- [ ] Build team scoring list with collapse
- [ ] Create opponent scoring header
- [ ] Implement floating undo button
- [ ] Wire up LiveGameViewModel
- [ ] Optimize for < 50ms latency
- [ ] Add haptic feedback
- [ ] Performance testing

#### Week 7: Career Stats & Game Summary
**Deliverables:**
- Career stats screen with segmented control
- Season comparison view
- Game summary with auto-navigation
- Export system (CSV + text)

**Tasks:**
- [ ] Build segmented control child switcher
- [ ] Implement career stats calculations
- [ ] Create season comparison UI
- [ ] Build game summary screen
- [ ] Auto-navigation on game end
- [ ] CSV export implementation
- [ ] Text message template
- [ ] Share sheet integration

#### Week 8: Testing & Polish
**Deliverables:**
- Unit test coverage (80%+ business logic)
- Integration tests (all use cases)
- Performance tests (< 50ms validation)
- VoiceOver accessibility testing
- Bug fixes and refinement

**Tasks:**
- [ ] Write unit tests (calculators, validators)
- [ ] Write integration tests (data flow)
- [ ] Performance benchmarks
- [ ] VoiceOver navigation testing
- [ ] Dynamic Type testing (all sizes)
- [ ] Dark mode testing
- [ ] Bug fixes
- [ ] UI polish

**Total Phase 1:** 100-120 hours

### Phase 2: Enhanced Features (2-3 weeks)

#### Advanced Export
- PDF generation with formatting
- Email composition
- Export templates
- Season summary reports

#### Analytics & History
- Career trends (charts)
- Season comparisons
- Game-by-game visualization
- Search and filter improvements

#### Settings & Preferences
- iCloud sync setup
- Export format defaults
- Notification preferences
- Advanced customization options

### Phase 3: Platform Expansion (Optional)

#### iPad Optimization
- Split-view layout for live games
- Landscape mode optimization
- External display support

#### Apple Watch App
- Simplified stat tracking on wrist
- Focus player stats only (6 buttons)
- Real-time sync to iPhone

#### Widgets
- Home screen widget (current game score)
- Lock screen widget (quick stats)
- Live Activities (iOS 16.1+)

---

## 10. Success Criteria

### MVP Complete When:

✅ **Multi-Child Support:**
- [ ] Can track 2+ children with independent career stats
- [ ] Smart default child selection works reliably
- [ ] Career stats accurately aggregate across teams per child
- [ ] Child switching in stats view is seamless

✅ **Core Functionality:**
- [ ] All 12 stat types recorded accurately
- [ ] Undo works for any action type (focus, team, opponent)
- [ ] Team scoring with smart collapse functions correctly
- [ ] Opponent scoring always visible in header

✅ **Performance:**
- [ ] 95% of stats recorded in < 3 seconds (user flow)
- [ ] < 50ms from stat tap to UI update (measured)
- [ ] No UI freezing or lag during rapid recording
- [ ] Battery usage acceptable (< 10% per game)

✅ **iOS-Native Design:**
- [ ] App feels like native iOS (semantic colors, SF Symbols, Dynamic Type)
- [ ] Dark mode works correctly (all screens)
- [ ] Supports text size scaling (tested at all sizes)
- [ ] VoiceOver navigation works properly
- [ ] Haptic feedback consistent and appropriate

✅ **Data Integrity:**
- [ ] Zero data loss during team transitions
- [ ] Database migrations work from v2.0 to v3.1
- [ ] Career stats calculations are accurate
- [ ] Export formats (CSV, text) generate correctly

✅ **Export & Sharing:**
- [ ] Text message export works (Messages app integration)
- [ ] CSV export to Files works
- [ ] Share sheet appears correctly
- [ ] Exported data is accurate

✅ **Navigation:**
- [ ] Tab bar navigation is intuitive
- [ ] Home screen quick start works
- [ ] Game summary auto-shows after game end
- [ ] No confusing or dead-end flows

### Performance Benchmarks

| Metric | Target | Measured |
|--------|--------|----------|
| Stat recording latency | < 50ms | ___ ms |
| App launch time | < 2s | ___ s |
| Career stats calculation | < 1s | ___ s |
| Game summary generation | < 500ms | ___ ms |
| Export CSV | < 3s | ___ s |

### User Acceptance Criteria

**Can the user:**
- [ ] Start a game for either child in 2 taps or less?
- [ ] Record a stat without looking at the screen (haptic only)?
- [ ] Undo any mistake immediately?
- [ ] Text game stats to family in under 5 seconds?
- [ ] View career stats for both children easily?
- [ ] Switch between teams for a child without data loss?

**Does the app feel:**
- [ ] Fast and responsive?
- [ ] Like a native iOS app?
- [ ] Intuitive and easy to use?
- [ ] Professional and polished?

---

## Appendix A: Migration from v2.0 to v3.1

### Data Migration Strategy

**Step 1: Create Child entities**
```swift
// For each unique player where isYourChild = true
let existingYourChildPlayers = Player.fetchAll(where: isYourChild == true)

for player in existingYourChildPlayers {
    // Create Child entity
    let child = Child(context: context)
    child.id = UUID()
    child.name = player.name
    child.photoData = player.photoData
    child.createdAt = Date()
    child.lastUsed = Date()
    
    // Update player to link to child
    player.childId = child.id
}
```

**Step 2: Remove deprecated fields**
```swift
// Remove from Player entity:
// - isYourChild (replaced by childId reference)
// - name (moved to Child entity)
// - photoData (moved to Child entity)
```

**Step 3: Update Game entities**
```swift
// For each game, find the focus child
for game in allGames {
    // Find the player marked as "your child" for this game
    let focusPlayer = game.statEvents
        .compactMap { $0.player }
        .first { $0.isYourChild }
    
    if let player = focusPlayer {
        game.focusChildId = player.childId
    }
}
```

### Breaking Changes

**Database Schema:**
- NEW: `Child` entity
- UPDATED: `Player` entity (added `childId`, removed `isYourChild`, removed `name`)
- UPDATED: `Game` entity (added `focusChildId`)

**API Changes:**
- `Player.fetchYourChild()` → `Child.fetchLastUsed()`
- `Player.isYourChild` → `Player.childId` (reference to Child)

**UI Changes:**
- Navigation structure (tab bar + sidebar)
- Button sizes (70pt → 56pt for focus player)
- Color system (hex values → semantic colors)

---

## Appendix B: Code Examples

### Creating a New Game for a Child

```swift
class CreateGameUseCase {
    func execute(for childId: UUID, opponentName: String) async throws -> Game {
        // 1. Find child's active team
        guard let team = Team.fetchActive(forChildId: childId, context: context) else {
            throw GameError.noActiveTeam
        }
        
        // 2. Find or create player instance for child on this team
        let player = Player.fetch(childId: childId, teamId: team.id, context: context)
        guard let focusPlayer = player else {
            throw GameError.playerNotOnTeam
        }
        
        // 3. Create game
        let game = Game(context: context)
        game.id = UUID()
        game.teamId = team.id
        game.focusChildId = childId
        game.opponentName = opponentName
        game.gameDate = Date()
        game.isComplete = false
        game.createdAt = Date()
        game.updatedAt = Date()
        
        // 4. Update child's lastUsed timestamp
        if let child = Child.fetch(id: childId, context: context) {
            try child.markAsUsed(context: context)
        }
        
        try context.save()
        return game
    }
}
```

### Recording a Stat with Performance Optimization

```swift
@MainActor
class LiveGameViewModel: ObservableObject {
    @Published var currentStats: LiveStats = LiveStats()
    @Published var canUndo: Bool = false
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var lastAction: UndoAction?
    
    func recordFocusPlayerStat(_ statType: StatType) {
        // PERFORMANCE CRITICAL: < 50ms total
        
        // 1. Immediate haptic (< 10ms)
        hapticGenerator.impactOccurred()
        
        // 2. Create event in memory (synchronous)
        let event = StatEvent(context: context)
        event.id = UUID()
        event.playerId = focusPlayer.id
        event.gameId = game.id
        event.timestamp = Date()
        event.statType = statType.rawValue
        event.value = Int32(statType.pointValue)
        event.isDeleted = false
        
        // 3. Update UI state (synchronous, < 40ms)
        updateCurrentStats(with: statType)  // Just counter increments
        
        // 4. Store for undo
        lastAction = .focusPlayerStat(eventId: event.id, statType: statType)
        canUndo = true
        
        // 5. Save to disk (asynchronous, background)
        Task.detached(priority: .userInitiated) { [weak context] in
            guard let context = context else { return }
            if context.hasChanges {
                try? context.save()
            }
        }
    }
}
```

---

## Appendix C: Decision Log

| Date | Decision | Rationale | Interview Question |
|------|----------|-----------|-------------------|
| Jan 2026 | Multi-child support | User has 2 children to track | Initial context |
| Jan 2026 | Tab bar + sidebar navigation | Balance quick access with clean UI | Q1 |
| Jan 2026 | Smart default child selection | Reduces taps for common case | Q3 |
| Jan 2026 | Segmented control in stats | Familiar iOS pattern, clean | Q4 |
| Jan 2026 | 56pt focus player buttons | Balance tap accuracy and screen space | Q6 |
| Jan 2026 | Minimal visual feedback | Performance priority | Q7 |
| Jan 2026 | Dedicated opponent section | Clarity over space efficiency | Q8 |
| Jan 2026 | Smart collapse team scoring | Balance visibility and space | Q9 |
| Jan 2026 | Floating undo button | iOS standard pattern | Q10 |
| Jan 2026 | Auto-navigate to game summary | User wants to review before deciding | Q11 |
| Jan 2026 | Season comparison in summary | Context is more valuable than raw numbers | Q12 |
| Jan 2026 | Text + CSV export | Quick share + personal records | Q13 |
| Jan 2026 | Combined overview stats | Complete picture with drill-down | Q14 |
| Jan 2026 | Quick start home screen | Fast game start is priority | Q15 |
| Jan 2026 | Direct tap team scoring | Simplicity over space optimization | Q17 |
| Jan 2026 | Auto dark mode | Follow iOS system setting | Q18 |
| Jan 2026 | iPhone-only Phase 1 | Focus on core experience first | Q19 |
| Jan 2026 | Same haptic for all actions | Simple and consistent | Q20 |
| Jan 2026 | Smart defaults + advanced settings | Best of both worlds | Q21 |

---

**End of Architecture Document v3.1**

*This document reflects the technical architecture based on comprehensive UI/UX interview conducted January 2026. For detailed UI/UX specifications, see companion document: UI_UX_Design_Specification_v1.0.md*
