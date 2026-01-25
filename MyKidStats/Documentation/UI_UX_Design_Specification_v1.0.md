# Basketball Stats Tracker - UI/UX Design Specification v1.0

## iOS-Native Interface Design

**Document Version:** 1.0  
**Created:** January 2026  
**Based On:** User interview session + Architecture v3.1  
**Platform:** iOS 16+

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Screen-by-Screen Specifications](#2-screen-by-screen-specifications)
3. [Component Library](#3-component-library)
4. [Interaction Patterns](#4-interaction-patterns)
5. [Accessibility](#5-accessibility)
6. [Responsive Design](#6-responsive-design)
7. [Animation & Transitions](#7-animation--transitions)
8. [Error States & Empty States](#8-error-states--empty-states)

---

## 1. Design Philosophy

### 1.1 Core Principles

**Speed Over Aesthetics**
- Every design decision prioritizes recording speed
- Tap targets optimized for 3-second action windows
- Minimal visual feedback to avoid distraction
- No animations during active stat recording

**iOS-Native First**
- Uses iOS semantic colors (automatic dark mode)
- SF Symbols for all icons
- Dynamic Type for all text
- Standard iOS patterns (tab bar, sheets, segmented controls)
- Respects user accessibility settings

**Progressive Disclosure**
- Most important actions always visible
- Secondary features collapsed or in menus
- Team scoring uses smart collapse
- Advanced settings hidden by default

**Consistent & Predictable**
- Same haptic for all stat recordings
- Buttons in logical groups (shooting together, other stats together)
- Navigation follows iOS conventions
- No surprises or hidden gestures

### 1.2 Design Constraints

**Performance Constraints:**
- < 50ms from tap to UI update (measured)
- No animations on critical path
- Asynchronous database saves

**Device Constraints:**
- Must work on iPhone SE (smallest screen)
- Portrait orientation only (for MVP)
- One-handed operation for stat recording

**Accessibility Constraints:**
- Minimum 44pt tap targets (secondary actions)
- Support text sizes from -3 to +7
- VoiceOver navigation must be logical
- High contrast mode support

---

## 2. Screen-by-Screen Specifications

### 2.1 Home Screen

**Purpose:** Quick game start with smart default child selection

#### Layout

```
┌─────────────────────────────────────────┐
│ 🏀 Basketball Stats       [⚙️ Settings] │ ← Navigation Bar
├─────────────────────────────────────────┤
│                                         │
│  Ready for today's game?                │ ← Large Title (Dynamic Type)
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  [▶️ Start Game for Alex]         │ │ ← Primary CTA (56pt height)
│  │  Smart Default                    │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [Switch to Jordan →]                  │ ← Secondary action (48pt)
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Last Game:                             │
│  Warriors 52, Eagles 45 ✓              │
│  Alex: 12 PTS, 5 REB, 3 AST            │
│  Nov 15, 2025                          │
│  [View Summary →]                      │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Recent Activity:                       │
│  • Jordan's game vs Thunder (Nov 12)   │
│  • Alex joined Warriors Fall 2025      │
│  • Exported game stats to Files        │
│                                         │
└─────────────────────────────────────────┘
  [Home] [Live] [Stats] [Teams]           ← Tab Bar
    🏠     ▶️     📊      👥
```

#### Visual Specifications

**Colors:**
- Background: `Color(uiColor: .systemGroupedBackground)`
- Card background: `Color(uiColor: .secondarySystemGroupedBackground)`
- Primary CTA: `Color.blue` with opacity 0.15 background
- Primary text: `Color(uiColor: .label)`
- Secondary text: `Color(uiColor: .secondaryLabel)`

**Typography:**
- Screen title: `.largeTitle` (34pt default, scales to 53pt)
- "Ready for today's game?": `.title2` (22pt default)
- Button labels: `.body` bold (17pt default)
- Recent activity: `.subheadline` (15pt default)
- Timestamps: `.caption` (12pt default)

**Spacing:**
- Screen padding: 16pt horizontal
- Section spacing: 24pt vertical
- Card internal padding: 16pt
- Element spacing: 12pt

**Interactions:**
- **Primary CTA Tap:** Immediately creates game for default child, navigates to Live tab
- **Switch Child Tap:** Toggles default child, updates button text to "Start Game for [Other Child]"
- **View Summary Tap:** Navigates to game detail screen
- **Settings Tap:** Opens settings sheet

#### States

**Initial State (No Children):**
```
Ready to get started?

[+ Add Your First Child]

Get started by adding a child to track stats for.
```

**One Child:**
```
Ready for today's game?

[▶️ Start Game for Alex]

(No toggle needed - only one child)
```

**Two+ Children:**
```
Ready for today's game?

[▶️ Start Game for Alex]  ← Shows last used
[Switch to Jordan →]

(Toggle between children)
```

---

### 2.2 Live Game Screen

**Purpose:** Real-time stat tracking (95% of app usage time)

#### Layout Overview

```
┌─────────────────────────────────────────┐
│ Warriors vs Eagles          [End Game] │ ← Compact Nav Bar
├─────────────────────────────────────────┤
│ Opponent Scoring:                       │ ← Always visible
│ Warriors 52 • Eagles 45                 │
│ [+1] [+2] [+3]                         │
├─────────────────────────────────────────┤
│                                         │
│ 👤 Alex Johnson #7                      │ ← Focus player header
│                                         │
│ ┌────┬────┬────┬────┐                  │ ← Shooting stats
│ │2PT │2PT │3PT │3PT │                  │   (56x56pt each)
│ │ ✓  │ ✗  │ ✓  │ ✗  │                  │
│ │ 4  │ 4  │ 2  │ 2  │ ← Live counts    │
│ └────┴────┴────┴────┘                  │
│ ┌────┬────┐                            │
│ │FT  │FT  │                            │
│ │ ✓  │ ✗  │                            │
│ │ 2  │ 0  │                            │
│ └────┴────┘                            │
│                                         │
│ ┌────┬────┬────┬────┐                  │ ← Other stats
│ │REB │AST │STL │BLK │                  │
│ │ 5  │ 3  │ 2  │ 1  │                  │
│ └────┴────┴────┴────┘                  │
│ ┌────┬────┐                            │
│ │ TO │ PF │                            │
│ │ 1  │ 2  │                            │
│ └────┴────┘                            │
│                                         │
│ 12 PTS • 4/8 FG (50%) • 2/2 FT         │ ← Quick summary
│                                         │
├─────────────────────────────────────────┤
│ Team Scoring                            │
│ #4  Marcus    12  [1][2][3]            │
│ #12 Sarah      8  [1][2][3]            │
│ #23 Jordan     6  [1][2][3]            │
│ ▼ 4 more players                        │
│                                         │
│         [↶ Undo]                        │ ← Floating (when available)
└─────────────────────────────────────────┘
```

#### Detailed Component Specs

**Opponent Scoring Section**
```
┌─────────────────────────────────────────┐
│ Opponent Scoring:                       │
│ Warriors 52 • Eagles 45                 │
│ [+1] [+2] [+3]                         │
└─────────────────────────────────────────┘
```
- Background: Light gray tint (`systemFill`)
- Padding: 12pt all sides
- Button size: 52x52pt
- Button spacing: 8pt
- Score typography: `.title` bold (28pt)
- Section height: ~100pt total

**Focus Player Stats - Stat Button Component**
```
┌────────┐
│   🏀   │ ← SF Symbol (24pt)
│  2PT   │ ← Label (.caption2, 11pt)
│   ✓    │ ← Indicator
│   4    │ ← Count (.title3 bold, 20pt)
└────────┘
   56pt square
```

Visual States:
- **Default:** Color tint at 15% opacity, 2pt border
- **Pressed:** Slight scale (0.95), immediate return
- **After Tap:** Counter increments (no animation)

Colors by Type:
- Made shots (✓): Green tint + border
- Missed shots (✗): Red tint + border
- Positive stats (REB/AST/STL/BLK): Blue tint + border
- Negative stats (TO/PF): Orange tint + border

**Team Scoring Row**
```
┌─────────────────────────────────────────┐
│ #4  Marcus Williams    12  [1][2][3]    │
└─────────────────────────────────────────┘
```
- Row height: 44pt
- Typography: `.body` (17pt)
- Button size: 48x48pt
- Background: Alternating rows (subtle stripe)
- Buttons: Purple tint

**Smart Collapse Implementation**
```
Top 2-3 Scorers (Expanded):
#4  Marcus    12  [1][2][3]
#12 Sarah      8  [1][2][3]
#23 Jordan     6  [1][2][3]

Others (Collapsed):
▼ 4 more players

(Tap to expand):
#15 Taylor     4  [1][2][3]
#8  Casey      2  [1][2][3]
#11 Morgan     0  [1][2][3]
#3  Riley      0  [1][2][3]
```

**Floating Undo Button**
```
         ┌──────────┐
         │ ↶ Undo   │
         └──────────┘
```
- Position: Bottom-right, 16pt margin
- Size: 50x50pt (circular)
- Elevation: Shadow (iOS standard)
- Appears: Fade in (150ms) when action recorded
- Disappears: Fade out (150ms) after use
- Color: Red tint (warning color)

#### Interaction Flow

**Recording a Stat:**
1. User taps stat button
2. **Immediate:** Haptic buzz (< 10ms)
3. **Immediate:** Counter updates (< 50ms)
4. **Background:** Database save (asynchronous)
5. **Immediate:** Undo button fades in

**Undoing a Stat:**
1. User taps undo button
2. **Immediate:** Haptic buzz (medium)
3. **Immediate:** Counter decrements
4. **Immediate:** Undo button fades out
5. **Background:** Mark event as deleted in database

**Team Scoring:**
1. User taps [+2] next to Marcus
2. **Immediate:** Haptic buzz
3. **Immediate:** "12" → "14"
4. **Immediate:** Team total updates
5. **Immediate:** Undo button appears

#### Edge Cases & States

**No Stats Recorded Yet:**
- All counters show 0
- Summary shows "0 PTS • 0/0 FG"
- Undo button not visible

**High Stat Counts:**
- If count > 99, use abbreviated display
- Example: "102" → "99+"
- Hover/tap for exact count tooltip

**Team Scoring All Collapsed:**
```
Team Scoring: 40 pts (7 players)
▼ Show all players
```

**Opponent Score Editing:**
- Long-press on opponent score
- Shows alert: "Edit opponent score"
- Number pad for direct entry
- [Cancel] [Save]

---

### 2.3 Game Summary Screen

**Purpose:** Post-game review with season context and quick export

**Trigger:** Auto-shows after tapping "End Game" (modal sheet, full screen)

#### Layout

```
┌─────────────────────────────────────────┐
│                [✕ Done]                 │
├─────────────────────────────────────────┤
│                                         │
│        Warriors 52, Eagles 45 ✓         │ ← Large result
│      Nov 15, 2025 • Fall 2025          │
│                                         │
├─────────────────────────────────────────┤
│  ALEX JOHNSON - GAME STATS              │
│  ═════════════════════════              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │        Today    Season Avg      │   │ ← Comparison table
│  │ PTS    12       12.1  →         │   │
│  │ REB    5        5.5   ↓         │   │
│  │ AST    3        3.0   →         │   │
│  │ STL    2        1.9   ↑         │   │
│  │ BLK    1        0.7   ↑         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Shooting:                              │
│  4-8 FG (50%) | 2-4 3PT (50%) | 2-2 FT │
│                                         │
│  Complete Stats:                        │
│  1 TO | 2 PF                           │
│                                         │
├─────────────────────────────────────────┤
│  📤 QUICK EXPORT                        │
│                                         │
│  [💬 Text Stats]  [💾 Save to Files]   │ ← Primary actions
│                                         │
│  Email to: _______________  [Send]     │ ← Optional
│                                         │
├─────────────────────────────────────────┤
│  Team Performance:                      │
│  Top Scorers:                           │
│  1. Taylor Smith - 14 pts              │
│  2. ALEX JOHNSON - 12 pts ⭐            │
│  3. Marcus Williams - 12 pts           │
│                                         │
│  [View Full Team Stats →]              │
│                                         │
└─────────────────────────────────────────┘
```

#### Visual Elements

**Result Header:**
- Win: Green checkmark ✓
- Loss: Red X ✗
- Tie: Yellow dash –
- Typography: `.title` bold
- Color: Semantic (green/red/orange)

**Comparison Table:**
- Trend indicators:
  - ↑ Green (above average)
  - ↓ Red (below average)
  - → Gray (at average, ±0.5)
- Grid layout with light borders
- Header row: light gray background

**Export Buttons:**
- Size: Full width, 48pt height
- Style: Filled buttons (primary color)
- Icons: SF Symbols
- Spacing: 12pt between

#### Interactions

**Text Stats Button:**
1. Generates formatted text summary
2. Opens iOS share sheet
3. Pre-fills Messages app
4. User selects contacts and sends

**Save to Files Button:**
1. Generates CSV file
2. Opens Files app picker
3. User selects destination
4. Saves file, shows confirmation

**Email Input:**
- Shows keyboard when tapped
- Validates email format
- Send button enabled when valid
- Sends email with PDF attachment (Phase 2)

**Done Button:**
1. Dismisses sheet
2. Returns to Home tab
3. Clears undo history

---

### 2.4 Stats Screen (Career Stats)

**Purpose:** View and compare career statistics across children

#### Layout

```
┌─────────────────────────────────────────┐
│  Career Stats                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │ ← Segmented Control
│  │   Alex   │  Jordan  │             │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ALEX JOHNSON                           │
│  47 Career Games                        │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 12.3 PPG │ 5.1 RPG │ 3.2 APG    │   │ ← Key stats
│  └─────────────────────────────────┘   │
│                                         │
│  Overall Stats:                         │
│  578 Total Points                       │
│  241 Total Rebounds                     │
│  149 Total Assists                      │
│                                         │
│  Shooting:                              │
│  189-421 FG (44.9%)                    │
│  45-134 3PT (33.6%)                    │
│  110-145 FT (75.9%)                    │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Career Highs:                          │
│  24 PTS vs Tigers (Oct 2025)           │
│  11 REB vs Spartans (Sep 2025)         │
│  7 AST vs Hawks (Aug 2025)             │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  By Team:                               │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ Warriors - Fall 2025 (Active)     │ │
│  │ 11 games | 12.1 PPG, 5.5 RPG     │ │
│  │ [View Details →]                  │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ Eagles - Summer 2025              │ │
│  │ 18 games | 13.2 PPG, 5.2 RPG     │ │
│  │ [View Details →]                  │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ Thunder - Spring 2025             │ │
│  │ 18 games | 11.8 PPG, 4.8 RPG     │ │
│  │ [View Details →]                  │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [📤 Export Career Stats]              │
│                                         │
└─────────────────────────────────────────┘
```

#### Segmented Control Behavior

**Appearance:**
- iOS standard segmented control
- Tint color: Blue
- Selected segment: Filled blue
- Unselected: Transparent with border

**Interaction:**
1. User taps "Jordan" segment
2. Fade out Alex's stats (200ms)
3. Fade in Jordan's stats (200ms)
4. Scroll position resets to top

**States:**
- Selected: Filled with blue background
- Unselected: Clear background
- Disabled: Grayed out (if only one child)

#### Team Card Design

```
┌───────────────────────────────────┐
│ Warriors - Fall 2025 (Active)     │ ← Title + badge
│ 11 games | 12.1 PPG, 5.5 RPG     │ ← Quick stats
│ [View Details →]                  │ ← Action
└───────────────────────────────────┘
```

- Card background: `secondarySystemGroupedBackground`
- Active badge: Small blue pill
- Typography: `.body` for title, `.subheadline` for stats
- Tap: Navigates to team detail screen

#### Empty State

```
No Stats Yet

Start tracking games to see career stats for Alex.

[▶️ Start First Game]
```

---

### 2.5 Teams Screen

**Purpose:** Manage teams and rosters

#### Layout

```
┌─────────────────────────────────────────┐
│  Teams                    [+ New Team]  │
├─────────────────────────────────────────┤
│                                         │
│  ACTIVE TEAMS                           │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ 👤 Alex's Team                    │ │
│  │ Warriors - Fall 2025 YMCA U12     │ │
│  │ Record: 8-3 | 11 games played     │ │
│  │                                   │ │
│  │ Roster: 12 players                │ │
│  │                                   │ │
│  │ [View Games] [Edit Roster]        │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ 👤 Jordan's Team                  │ │
│  │ Eagles - Summer 2025 Travel       │ │
│  │ Record: 12-6 | 18 games played    │ │
│  │                                   │ │
│  │ Roster: 10 players                │ │
│  │                                   │ │
│  │ [View Games] [Edit Roster]        │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  INACTIVE TEAMS                         │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ Thunder - Spring 2025 School      │ │
│  │ 18 games | Season Complete        │ │
│  │ [Make Active] [View Games]        │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

#### Team Card States

**Active Team:**
- Green indicator dot
- "Active" badge
- Full stats visible
- Primary actions available

**Inactive Team:**
- Gray indicator dot
- Collapsed view
- "Make Active" button available

#### New Team Flow

**Sheet Presentation:**
```
┌─────────────────────────────────────────┐
│  Create New Team          [✕]           │
├─────────────────────────────────────────┤
│                                         │
│  Which child?                           │
│  ○ Alex   ● Jordan                      │ ← Radio buttons
│                                         │
│  Team Name:                             │
│  [Warriors_________________]            │
│                                         │
│  Season/Year:                           │
│  [Fall 2025_______________]            │
│                                         │
│  Organization:                          │
│  [YMCA U12________________]            │
│                                         │
│  Age Group:                             │
│  [U12_____________________]            │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  This will:                             │
│  • Create new team                      │
│  • Add Jordan to roster                 │
│  • Make this the active team            │
│  • Keep all historical data             │
│                                         │
│            [Cancel] [Create Team]       │
│                                         │
└─────────────────────────────────────────┘
```

---

## 3. Component Library

### 3.1 Button Components

#### Primary Button (CTA)

**Usage:** Main actions (Start Game, Create Team)

```swift
struct PrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.body.bold())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.blue.opacity(0.15))
            .foregroundColor(.blue)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
    }
}
```

#### Stat Button

**Usage:** Recording stats during live game

```swift
struct StatButton: View {
    let type: StatType
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.title2)
                Text(type.label)
                    .font(.caption2.bold())
                Text("\(count)")
                    .font(.title3.bold())
                    .foregroundColor(.secondaryText)
            }
            .frame(width: 56, height: 56)
            .background(type.color.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(type.color, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)  // Prevent default iOS button styling
    }
}

enum StatType {
    case twoMade, twoMiss, threeMade, threeMiss
    case ftMade, ftMiss
    case rebound, assist, steal, block, turnover, foul
    
    var icon: String {
        switch self {
        case .twoMade, .threeMade: return "basketball.fill"
        case .twoMiss, .threeMiss: return "xmark.circle"
        case .ftMade: return "checkmark.circle.fill"
        case .ftMiss: return "xmark.circle.fill"
        case .rebound: return "arrow.up.circle.fill"
        case .assist: return "hand.raised.fill"
        case .steal: return "hand.point.up.left.fill"
        case .block: return "hand.raised.slash.fill"
        case .turnover: return "arrow.triangle.2.circlepath"
        case .foul: return "exclamationmark.triangle.fill"
        }
    }
    
    var label: String {
        switch self {
        case .twoMade: return "2PT ✓"
        case .twoMiss: return "2PT ✗"
        case .threeMade: return "3PT ✓"
        case .threeMiss: return "3PT ✗"
        case .ftMade: return "FT ✓"
        case .ftMiss: return "FT ✗"
        case .rebound: return "REB"
        case .assist: return "AST"
        case .steal: return "STL"
        case .block: return "BLK"
        case .turnover: return "TO"
        case .foul: return "PF"
        }
    }
    
    var color: Color {
        switch self {
        case .twoMade, .threeMade, .ftMade: return .green
        case .twoMiss, .threeMiss, .ftMiss: return .red
        case .rebound, .assist, .steal, .block: return .blue
        case .turnover, .foul: return .orange
        }
    }
}
```

#### Team Scoring Button

**Usage:** Quick +1/+2/+3 for team players

```swift
struct TeamScoreButton: View {
    let points: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("+\(points)")
                .font(.body.bold())
                .frame(width: 48, height: 48)
                .background(Color.purple.opacity(0.15))
                .foregroundColor(.purple)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
```

### 3.2 Card Components

#### Game Card

**Usage:** Game history list, recent games

```swift
struct GameCard: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(game.gameDate))
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                Spacer()
                Text(game.result.emoji)
                    .font(.title3)
            }
            
            Text("\(game.team?.name ?? "Team") \(game.teamScore), \(game.opponentName) \(game.opponentScore)")
                .font(.body.bold())
            
            if let focusChild = game.focusChild {
                Text("\(focusChild.name): \(game.focusChildStats)")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}
```

#### Stats Summary Card

**Usage:** Quick stat overview

```swift
struct StatsSummaryCard: View {
    let title: String
    let stats: [(label: String, value: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            LazyVGrid(columns: [.init(), .init(), .init()], spacing: 12) {
                ForEach(stats, id: \.label) { stat in
                    VStack {
                        Text(stat.value)
                            .font(.title2.bold())
                        Text(stat.label)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}
```

### 3.3 List Components

#### Team Scoring Row

**Usage:** Team player with score buttons

```swift
struct TeamScoringRow: View {
    let player: Player
    let currentScore: Int
    let onScore: (Int) -> Void
    
    var body: some View {
        HStack {
            Text("#\(player.jerseyNumber ?? "")")
                .font(.body.bold())
                .foregroundColor(.secondaryText)
                .frame(width: 40)
            
            Text(player.child?.name ?? "")
                .font(.body)
            
            Spacer()
            
            Text("\(currentScore)")
                .font(.title3.bold())
                .foregroundColor(.secondaryText)
                .frame(width: 40)
            
            HStack(spacing: 4) {
                TeamScoreButton(points: 1) { onScore(1) }
                TeamScoreButton(points: 2) { onScore(2) }
                TeamScoreButton(points: 3) { onScore(3) }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.appBackground)
    }
}
```

---

## 4. Interaction Patterns

### 4.1 Haptic Feedback Specification

**Generator Setup:**
```swift
class HapticManager {
    static let shared = HapticManager()
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        impactGenerator.prepare()  // Pre-warm for instant response
    }
    
    func impact() {
        impactGenerator.impactOccurred()
    }
    
    func prepare() {
        impactGenerator.prepare()
    }
}
```

**Usage Pattern:**
- **All stat recordings:** Medium impact
- **Undo:** Medium impact (same as recording)
- **Game end:** Medium impact
- **No haptics:** Navigation, scrolling, sheet presentation

### 4.2 Sheet Presentations

**Modal Sheets:**
- Game Summary: Full screen, can't dismiss by swipe
- Team Creation: Medium size, swipe to dismiss
- Settings: Medium size, swipe to dismiss
- Child Management: Medium size, swipe to dismiss

**Implementation:**
```swift
.sheet(isPresented: $showingSheet) {
    GameSummaryView(game: completedGame)
        .interactiveDismissDisabled()  // Can't swipe away
}
```

### 4.3 Navigation Transitions

**Tab Switching:**
- No animation (instant)
- Maintains scroll position
- Preserves view state

**Push Navigation:**
- Standard iOS slide transition
- Back button auto-generated
- Swipe back gesture enabled

**Sheet Presentation:**
- Standard iOS bottom-up
- Drag indicator visible
- Swipe-down to dismiss (unless disabled)

### 4.4 Gestures

**Standard iOS Gestures:**
- Tap: Primary interaction
- Long press: Secondary actions (edit opponent score)
- Swipe back: Navigate back
- Swipe down: Dismiss sheet
- Pull to refresh: Refresh data (in lists)

**No Custom Gestures:**
- No swipe actions on stat buttons (too risky)
- No double-tap shortcuts
- No pinch to zoom
- Keep it simple and predictable

---

## 5. Accessibility

### 5.1 VoiceOver Support

**Screen Reader Labels:**
```swift
StatButton(type: .twoMade, count: 4, action: recordStat)
    .accessibilityLabel("Two point made. Current count: 4")
    .accessibilityHint("Double tap to record")
```

**Navigation Order:**
1. Top navigation (opponent score first)
2. Focus player header
3. Shooting stats (left to right, top to bottom)
4. Other stats (left to right, top to bottom)
5. Summary text
6. Team scoring (top to bottom)
7. Undo button (if visible)

**Custom Actions:**
```swift
.accessibilityAction(named: "Undo last stat") {
    undoLastAction()
}
```

### 5.2 Dynamic Type Support

**Minimum Sizes:**
- Stat button labels remain readable at smallest size
- Stat counts scale with Dynamic Type
- If text overflows button, truncate with "..."

**Maximum Sizes:**
- At largest text size, may require scrolling
- Button grids may collapse to 3 columns instead of 4
- Maintain minimum 44pt tap targets

**Testing Matrix:**

| Size Level | Text Scale | Notes |
|------------|------------|-------|
| Extra Small (-3) | 76% | Test truncation |
| Small (-1) | 88% | Common size |
| Default (0) | 100% | Design baseline |
| Large (+2) | 129% | Common accessibility size |
| Extra Large (+5) | 170% | Test overflow |
| Accessibility (+7) | 200% | Maximum supported |

### 5.3 High Contrast Mode

**Adjustments:**
- Border widths increase from 2pt to 3pt
- Background opacity increases from 15% to 25%
- Text colors use `.label` (automatically higher contrast)
- Separator lines become more prominent

**Implementation:**
```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

var backgroundOpacity: Double {
    reduceTransparency ? 0.25 : 0.15
}
```

### 5.4 Reduce Motion

**Adjustments:**
- Fade transitions replace slide transitions
- No bounce effects
- No spring animations
- Instant state changes preferred

**Implementation:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var transition: AnyTransition {
    reduceMotion ? .opacity : .slide
}
```

---

## 6. Responsive Design

### 6.1 Device Size Classes

**iPhone SE (Compact Width, Compact Height):**
- Most constrained layout
- 4x3 stat button grid
- Team scoring shows 3 players expanded
- May require scrolling for all content

**iPhone Pro (Regular Width, Regular Height):**
- Standard layout as designed
- 4x3 stat button grid
- Team scoring shows 3 players expanded
- Minimal scrolling needed

**iPhone Pro Max (Regular Width, Regular Height):**
- Spacious layout
- 4x3 stat button grid with extra spacing
- Team scoring shows 4 players expanded
- No scrolling needed for live game

**iPad (Regular Width, Regular Height) - Phase 2:**
- Split view: Focus player | Team scoring
- Larger stat buttons (70x70pt feasible)
- Sidebar always visible
- Landscape orientation supported

### 6.2 Safe Area Handling

**Top Safe Area:**
- Navigation bar respects notch/dynamic island
- Content starts below safe area
- No content clipped by notch

**Bottom Safe Area:**
- Tab bar respects home indicator
- Floating buttons positioned above home indicator
- Minimum 16pt above home indicator

**Implementation:**
```swift
VStack {
    // Content
}
.padding(.bottom, geometry.safeAreaInsets.bottom)
```

### 6.3 Orientation

**Phase 1: Portrait Only**
- All screens locked to portrait
- Simplifies layout logic
- Matches typical usage pattern (courtside with phone)

**Phase 2: Landscape Support (iPad)**
- iPad gets landscape optimizations
- iPhone remains portrait-only
- Split-view layouts for landscape iPad

---

## 7. Animation & Transitions

### 7.1 Animation Budget

**No Animations:**
- Stat button presses (critical path)
- Counter updates (instant)
- Score changes (instant)
- Undo button appearance (subtle fade only)

**Minimal Animations:**
- Sheet presentations (iOS default)
- Navigation transitions (iOS default)
- Segmented control selection (iOS default)

**Acceptable Animations:**
- Fade transitions for non-critical elements
- Loading indicators (when necessary)
- Success confirmations (brief)

### 7.2 Loading States

**Initial App Launch:**
```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│             🏀                          │ ← App icon
│       Basketball Stats                  │
│                                         │
│         (Loading...)                    │
│                                         │
└─────────────────────────────────────────┘
```
- Maximum 2 seconds
- If > 2s, show "Loading data..." message

**Data Loading (Lists):**
```
┌─────────────────────────────────────────┐
│  Career Stats                           │
├─────────────────────────────────────────┤
│                                         │
│         (Calculating stats...)          │ ← Spinner
│                                         │
└─────────────────────────────────────────┘
```
- Spinner appears after 500ms delay
- Progress bar if > 3 seconds

**Background Saves:**
- No loading indicator
- Silent background saves
- Only show error if save fails

---

## 8. Error States & Empty States

### 8.1 Error Messages

**Database Error:**
```
┌─────────────────────────────────────────┐
│  ⚠️ Unable to Save                      │
├─────────────────────────────────────────┤
│                                         │
│  Your stats couldn't be saved.          │
│  Please try again.                      │
│                                         │
│  [Retry] [Cancel]                       │
│                                         │
└─────────────────────────────────────────┘
```

**Network Error (iCloud Sync):**
```
┌─────────────────────────────────────────┐
│  ☁️ Sync Unavailable                    │
├─────────────────────────────────────────┤
│                                         │
│  Your stats are saved locally but       │
│  couldn't sync to iCloud. They'll sync  │
│  automatically when you're back online. │
│                                         │
│  [OK]                                   │
│                                         │
└─────────────────────────────────────────┘
```

**Export Error:**
```
┌─────────────────────────────────────────┐
│  📤 Export Failed                       │
├─────────────────────────────────────────┤
│                                         │
│  Couldn't create the file. Please       │
│  check your storage and try again.      │
│                                         │
│  [Try Again] [Cancel]                   │
│                                         │
└─────────────────────────────────────────┘
```

### 8.2 Empty States

**No Games Yet:**
```
┌─────────────────────────────────────────┐
│  Career Stats                           │
├─────────────────────────────────────────┤
│                                         │
│             📊                          │
│                                         │
│      No Games Recorded Yet              │
│                                         │
│  Start tracking games to see career     │
│  statistics for Alex.                   │
│                                         │
│  [▶️ Start First Game]                  │
│                                         │
└─────────────────────────────────────────┘
```

**No Teams:**
```
┌─────────────────────────────────────────┐
│  Teams                                  │
├─────────────────────────────────────────┤
│                                         │
│             👥                          │
│                                         │
│      No Teams Yet                       │
│                                         │
│  Create a team to start tracking        │
│  games and statistics.                  │
│                                         │
│  [+ Create First Team]                  │
│                                         │
└─────────────────────────────────────────┘
```

**No Children:**
```
┌─────────────────────────────────────────┐
│  Welcome to Basketball Stats! 🏀        │
├─────────────────────────────────────────┤
│                                         │
│  Let's get started by adding a child    │
│  to track stats for.                    │
│                                         │
│  Name: [___________________]            │
│                                         │
│  Date of Birth (optional):              │
│  [MM/DD/YYYY___________]                │
│                                         │
│  [Add Photo] (optional)                 │
│                                         │
│  [Continue →]                           │
│                                         │
└─────────────────────────────────────────┘
```

---

## Appendix: Design Tokens

### Colors

```swift
extension Color {
    // Stat colors
    static let statMade = Color.green
    static let statMissed = Color.red
    static let statPositive = Color.blue
    static let statNegative = Color.orange
    static let statTeam = Color.purple
    
    // Backgrounds
    static let appBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    // Text
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
    
    // System
    static let separator = Color(uiColor: .separator)
    static let fill = Color(uiColor: .systemFill)
}
```

### Spacing

```swift
extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 24
    
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusButton: CGFloat = 12
    static let cornerRadiusCard: CGFloat = 16
}
```

### Typography

```swift
extension Font {
    static let scoreLarge = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let playerName = Font.system(.title2, design: .default, weight: .semibold)
    static let statLabel = Font.system(.caption2, design: .rounded, weight: .medium)
    static let statValue = Font.system(.title3, design: .rounded, weight: .bold)
    static let teamRow = Font.system(.body, design: .default, weight: .regular)
}
```

---

**End of UI/UX Design Specification v1.0**

*This document defines the complete visual and interaction design for the Basketball Stats Tracker iOS app. For technical implementation details, see Architecture_v3.1_Updated.md*
