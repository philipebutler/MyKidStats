```markdown
# MyKidsStats – Application Implementation Plan

## Purpose

This document defines the complete technical implementation plan for **MyKidsStats**.  
It is optimized for **AI-assisted implementation**, providing deterministic rules, explicit module boundaries, and vertical feature slices that can be implemented incrementally with minimal ambiguity.

This plan directly maps to the prioritized product backlog and non-functional requirements.

---

## 1. Guiding Principles

1. **Offline-first**
2. **Event-sourced stat tracking**
3. **Aggregates are derived, never stored**
4. **One-tap live game interactions**
5. **Explicit game lifecycle states**
6. **User owns all data locally**
7. **Apple out-of-the-box technologies only**

---

## 2. Platform & Technology Decisions

### Platform
- **iOS**
- **Swift + SwiftUI**

### Persistence (Committed Choice)
- **Core Data**
- Backed by SQLite (managed automatically by iOS)
- No direct SQLite usage in application code

### Architecture Style
- Clean Architecture (UI → Domain → Data)
- Repository pattern
- Event sourcing for stats

---

## 3. High-Level Architecture

```

MyKidsStats
├── App
├── UI
│   ├── LiveGame
│   ├── GameSummary
│   ├── Teams
│   ├── Children
│   └── Export
├── Domain
│   ├── Models
│   ├── UseCases
│   ├── StatEngine
│   └── Aggregation
├── Data
│   ├── CoreData
│   ├── Repositories
│   └── Migrations
├── Services
│   ├── ExportCSV
│   ├── Share
│   └── Lifecycle
└── Tests
├── DomainTests
├── DataTests
└── UITests

```

---

## 4. Core Domain Model

### 4.1 Entities (Core Data)

#### Child
- id (UUID)
- name
- createdAt

#### Team
- id
- childId
- name
- season

#### Player
- id
- teamId
- name
- isFocusChild (Bool)

#### Game
- id
- teamId
- startTime
- endTime (nullable)
- status (active | completed | autoClosed)
- opponentScore (Int)

---

### 4.2 Event-Sourced Stat Model (Source of Truth)

#### StatEvent
- id
- gameId
- playerId
- statType (enum)
- value (Int: +1 or -1)
- timestamp
- isVoided (Bool)

**Rules**
- StatEvents are never physically deleted
- Undo/edit operations mark events as `isVoided = true`
- Aggregates always ignore voided events

---

## 5. Enumerations (Single Source of Truth)

### StatType
- twoMade
- twoMiss
- threeMade
- threeMiss
- ftMade
- ftMiss
- rebound
- assist
- steal
- block

### GameStatus
- active
- completed
- autoClosed

---

## 6. Deterministic Aggregation Rules

```

Points = (2 * twoMade) + (3 * threeMade) + (1 * ftMade)

FGA = twoMade + twoMiss + threeMade + threeMiss
FGM = twoMade + threeMade
FG% = FGM / max(FGA, 1)

3PA = threeMade + threeMiss
3P% = threeMade / max(3PA, 1)

FTA = ftMade + ftMiss
FT% = ftMade / max(FTA, 1)

```

All aggregates are computed **on demand** from StatEvents.

---

## 7. Game Lifecycle Rules

### Start Game
- Creates Game with status = `active`
- Persists immediately

### End Game
- Sets status = `completed`
- Locks stat entry

### Auto-End
- Triggered if:
  - Game active for > 3 hours
  - App relaunched with stale active game
- Status set to `autoClosed`

### Resume Logic
- On app launch:
  - If active game exists and < 3 hours → resume
  - Else → auto-close

---

## 8. Editing & Undo Rules (Deterministic)

### Undo Last Action
- Locate most recent non-voided StatEvent
- Set `isVoided = true`

### Correct Stat
- Void original event
- Create new StatEvent with corrected stat

---

## 9. Vertical Implementation Slices (AI-Friendly)

Each slice must meet its **Definition of Done (DoD)** before proceeding.

---

### Slice 0 – Persistence Foundation
**Includes**
- Core Data stack
- Entities + migrations
- Repositories

**DoD**
- CRUD tests for Child, Team, Player, Game
- App relaunch retains data

---

### Slice 1 – Game Lifecycle
**Includes**
- StartGameUseCase
- EndGameUseCase
- ResumeActiveGameUseCase

**DoD**
- Game resumes after app kill
- Auto-close after 3 hours

---

### Slice 2 – Record Stat Event (Live Game)
**Includes**
- RecordStatEventUseCase
- One-tap UI buttons
- Immediate visual feedback

**DoD**
- <100ms UI response
- StatEvent persisted
- Aggregates recompute correctly

---

### Slice 3 – Undo & Correction
**Includes**
- UndoLastEventUseCase
- CorrectEventUseCase

**DoD**
- Voided events excluded from aggregates
- Undo does not corrupt totals

---

### Slice 4 – Opponent Score & Game Summary
**Includes**
- Opponent score tracking
- Win/loss calculation
- Summary screen

**DoD**
- Summary totals match event log

---

### Slice 5 – Season & Career Aggregation
**Includes**
- Season totals
- Career totals

**DoD**
- Aggregates span all games correctly

---

### Slice 6 – Export & Share
**Includes**
- CSV export (game, season, career)
- Native share sheet

**CSV Columns**
```

Child, Team, Season, GameDate, Opponent,
Points, FGM, FGA, FG%, 3PM, 3PA, 3P%, FTM, FTA, FT%, Rebounds, Assists, Steals, Blocks

```

**DoD**
- Exported totals match in-app values exactly

---

## 10. Non-Functional Requirements (Implementation)

### Performance
- Stat tap → UI update ≤ 100ms
- Cold start ≤ 3s

### Reliability
- Durable local writes ≤ 1s
- No data loss on crash or background

### Scalability
- ≥ 50,000 StatEvents supported
- ≥ 1,000 games per child

### Accessibility
- 44x44pt minimum tap targets
- Dynamic Type supported

---

## 11. Testing Strategy

### Required Tests per Slice
- Domain aggregation tests
- Repository round-trip tests
- Game lifecycle recovery tests
- CSV export validation tests

No slice is considered complete without tests.

---

## 12. Future-Proofing (Intentional)

- Stat types enum-driven (multi-sport ready)
- Event sourcing enables:
  - Play-by-play
  - Analytics
  - Optional cloud sync later
- Core Data abstracts SQLite details safely

---

## 13. Outcome

This plan produces:
- A fast, reliable live stat tracking MVP
- Zero dependency on network connectivity
- Fully auditable, user-owned data
- A clean foundation for long-term growth

---

## End of Implementation Plan
```
