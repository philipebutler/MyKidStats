# Basketball Stats Tracker - Architectural Design Document

## Document Version: 1.0
## Target Platform: iOS 16+
## Language: Swift 5.9+
## Framework: SwiftUI + Combine
## Document Part: 1 of 8

---

# TABLE OF CONTENTS

1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)

---

<a name="executive-summary"></a>
# 1. EXECUTIVE SUMMARY

## 1.1 Application Purpose

A native iOS application designed for real-time basketball statistics tracking with focus on individual player detailed metrics while maintaining team-level scoring. Optimized for single-parent operation during live youth basketball games.

### Primary Use Case
Parent sitting in bleachers during youth basketball game needs to:
- Track detailed statistics for their child (points, rebounds, assists, steals, blocks, shooting percentages)
- Maintain scoring for all team members
- Complete stat entry within 3 seconds to keep pace with game action
- Operate with both hands on phone
- Function without network connectivity
- Minimize context switching between players

### Key Differentiators from Existing Solutions
1. **Dual-Mode Interface**: Automatically simplifies when focus player is on bench
2. **Single-Tap Recording**: Maximum one tap per stat event
3. **Context-Aware Design**: Interface adapts to whether focus player is active
4. **Offline-First**: No network dependency during game
5. **Speed-Optimized**: Built for 3-second action intervals

## 1.2 Core Requirements

### Functional Requirements

#### FR-1: Player Management
- Create and manage team roster
- Designate one focus player per team
- Store player details (name, jersey number, position, photo)
- Support multiple teams/seasons

#### FR-2: Live Game Tracking
- Record stats in real-time during games
- Support dual-mode interface (focus player active/inactive)
- Track detailed stats for focus player:
  - Free throws (made/missed)
  - 2-point shots (made/missed)
  - 3-point shots (made/missed)
  - Rebounds
  - Assists
  - Steals
  - Blocks
- Track points only for other team members
- Track opponent score
- Auto-calculate shooting percentages and totals

#### FR-3: Data Persistence
- Store all games and statistics locally
- Support offline operation (no network required during games)
- Auto-save every 30 seconds during live games
- Crash recovery with state restoration
- Optional cloud backup via iCloud

#### FR-4: Historical Analytics
- View individual game summaries
- Aggregate season statistics
- Calculate lifetime statistics
- Display trends and averages over time
- Compare performance across games

#### FR-5: Export & Sharing
- Export single game data (CSV, PDF)
- Export season data (CSV, PDF)
- Export lifetime data (CSV, PDF)
- Share via email, Messages, Files app
- Formatted reports with standard basketball statistics

#### FR-6: Undo Functionality
- Maintain last 10 actions in undo stack
- Support undo via dedicated button
- Visual indicator when undo available
- Soft-delete mechanism for stats

### Non-Functional Requirements

#### NFR-1: Performance
- **Response Time**: Maximum 100ms from tap to visual feedback
- **Battery Life**: Support 2+ hour games on single charge
- **Memory Usage**: Maximum 150MB during active game
- **Storage**: Efficient data storage (typical season < 50MB)

#### NFR-2: Usability
- **Minimum Tap Target**: 44x44 points (Apple HIG compliance)
- **Primary Action Buttons**: 60x60 points or larger
- **Haptic Feedback**: Confirm all stat recordings
- **Visual Feedback**: Animation on button press
- **Error Prevention**: 100ms debounce on buttons
- **Accessibility**: Full VoiceOver support, Dynamic Type support

#### NFR-3: Reliability
- **Offline Operation**: 100% functionality without network
- **Data Integrity**: No data loss on app crash/termination
- **Auto-Save**: Every 30 seconds during active game
- **State Restoration**: Resume interrupted games

#### NFR-4: Compatibility
- **iOS Version**: iOS 16.0 or later
- **Devices**: iPhone (primary), iPad (supported)
- **Screen Sizes**: All iPhone sizes from iPhone SE to iPhone 15 Pro Max
- **Orientation**: Portrait mode (primary), landscape (supported)
- **Appearance**: Light mode and dark mode support

#### NFR-5: Security & Privacy
- **Data Privacy**: All data stored locally by default
- **iCloud**: Optional, user-controlled
- **No Analytics**: No third-party tracking
- **COPPA Compliance**: Safe for children's data

## 1.3 Technical Constraints

### Platform Constraints
- **Development**: Xcode 15+ required
- **Language**: Swift 5.9+ only (no Objective-C)
- **Framework**: SwiftUI (no UIKit except where necessary)
- **Minimum Deployment**: iOS 16.0
- **Distribution**: App Store only (no enterprise/ad-hoc)

### Hardware Constraints
- **Minimum Device**: iPhone SE (2nd generation)
- **Storage**: Minimum 50MB free space required
- **Battery**: Must not drain >20% per hour during active use

### Network Constraints
- **Core Functionality**: Must work 100% offline
- **Cloud Sync**: Optional feature, graceful degradation
- **Export**: Local first, cloud optional

### Design Constraints
- **Apple HIG Compliance**: Full adherence to Human Interface Guidelines
- **Accessibility**: WCAG 2.1 AA compliance minimum
- **Dark Mode**: Full support required
- **System Integration**: Files app, Share Sheet, Shortcuts

## 1.4 Success Criteria

### Quantitative Metrics
1. **Speed**: 95% of stat entries completed in <3 seconds
2. **Accuracy**: <2% accidental tap rate
3. **Reliability**: <1 crash per 100 games
4. **Battery**: <15% drain per 2-hour game
5. **User Retention**: >80% completion of first game setup

### Qualitative Metrics
1. **Usability**: User can track stats without missing game action
2. **Simplicity**: Onboarding completed in <5 minutes
3. **Intuitiveness**: Core features discoverable without tutorial
4. **Satisfaction**: Users prefer this app over current solutions

## 1.5 Out of Scope (Phase 1)

The following features are explicitly excluded from the initial release:

### Phase 2 Features
- Apple Watch companion app
- Video integration/replay
- Advanced shot charts with location tracking
- Team sharing/collaboration features
- Coach mode with lineup management
- Play-by-play notation

### Future Considerations
- Android version
- Web dashboard
- AI-powered insights
- Integration with league management systems
- Social sharing features
- Gamification/achievements

---

<a name="system-architecture"></a>
# 2. SYSTEM ARCHITECTURE

## 2.1 Architectural Pattern: MVVM + Repository Pattern

The application follows a layered architecture based on MVVM (Model-View-ViewModel) with the Repository pattern for data access. This separation ensures:

- **Testability**: Each layer can be tested independently
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features
- **Reusability**: Business logic decoupled from UI

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ SwiftUI Views│  │  ViewModels  │  │  Coordinators│      │
│  │              │  │              │  │              │      │
│  │ - LiveGame   │  │ - LiveGame   │  │ - App        │      │
│  │ - GameList   │  │ - GameList   │  │ - MainTab    │      │
│  │ - Stats      │  │ - Stats      │  │ - Onboarding │      │
│  │ - Settings   │  │ - Settings   │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                   │             │
└─────────┼──────────────────┼───────────────────┼─────────────┘
          │                  │                   │
          │                  ▼                   │
          │         ┌──────────────┐             │
          │         │  Combine     │             │
          │         │  Publishers  │             │
          │         └──────────────┘             │
          │                  │                   │
          ▼                  ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                       │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Use Cases    │  │  Services    │  │  Calculators │      │
│  │              │  │              │  │              │      │
│  │ - RecordStat │  │ - StatsCalc  │  │ - Shooting%  │      │
│  │ - CreateGame │  │ - GameTimer  │  │ - Averages   │      │
│  │ - ExportData │  │ - Validator  │  │ - Trends     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                   │             │
└─────────┼──────────────────┼───────────────────┼─────────────┘
          │                  │                   │
          ▼                  ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                         │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Repositories │  │  DTOs        │  │  Mappers     │      │
│  │              │  │              │  │              │      │
│  │ - Team       │  │ - TeamDTO    │  │ Entity<->DTO │      │
│  │ - Player     │  │ - PlayerDTO  │  │ Conversions  │      │
│  │ - Game       │  │ - GameDTO    │  │              │      │
│  │ - StatEvent  │  │ - StatDTO    │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                                                     │
└─────────┼─────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                   PERSISTENCE LAYER                          │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Core Data   │  │  CloudKit    │  │UserDefaults  │      │
│  │              │  │  (Optional)  │  │              │      │
│  │ - Entities   │  │ - Sync       │  │ - Preferences│      │
│  │ - Context    │  │ - Backup     │  │ - Settings   │      │
│  │ - Stack      │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                   │             │
└─────────┼──────────────────┼───────────────────┼─────────────┘
          │                  │                   │
          ▼                  ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      STORAGE LAYER                           │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ SQLite DB    │  │ iCloud Drive │  │ File System  │      │
│  │ (Local)      │  │ (Optional)   │  │ (Exports)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### Presentation Layer
- **Views**: SwiftUI views that render UI
- **ViewModels**: State management and business logic coordination
- **Coordinators**: Navigation flow management

**Key Principles**:
- Views are dumb: only render state from ViewModels
- ViewModels don't know about Views
- Navigation logic in Coordinators, not Views

#### Business Logic Layer
- **Use Cases**: Single-purpose business operations
- **Services**: Reusable business logic components
- **Calculators**: Statistical and mathematical operations

**Key Principles**:
- Framework-independent (pure Swift)
- Fully unit testable
- Single Responsibility Principle

#### Data Access Layer
- **Repositories**: Abstract data source operations
- **DTOs**: Data Transfer Objects (immutable)
- **Mappers**: Convert between entities and DTOs

**Key Principles**:
- Hide Core Data implementation details
- Provide clean, type-safe interfaces
- Domain models independent of persistence

#### Persistence Layer
- **Core Data Stack**: Managed object contexts
- **CloudKit Integration**: Optional sync (disabled by default)
- **UserDefaults**: App preferences and settings

**Key Principles**:
- Encapsulate persistence implementation
- Support for offline-first operation
- Optional cloud sync

## 2.2 Module Organization

### Project Structure

```
BasketballStatsTracker/
├── App/
│   ├── BasketballStatsTrackerApp.swift      # App entry point
│   ├── AppDelegate.swift                     # App lifecycle
│   └── Info.plist                            # App configuration
│
├── Core/
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   ├── Date+Extensions.swift
│   │   └── Bundle+Extensions.swift
│   ├── Utilities/
│   │   ├── HapticManager.swift
│   │   ├── Logger.swift
│   │   └── DateFormatter+Shared.swift
│   ├── Constants/
│   │   ├── Spacing.swift
│   │   ├── CornerRadius.swift
│   │   ├── ButtonSize.swift
│   │   └── AppConstants.swift
│   └── Protocols/
│       ├── Repository.swift
│       ├── UseCase.swift
│       └── Coordinator.swift
│
├── Data/
│   ├── Models/
│   │   ├── CoreData/
│   │   │   ├── BasketballStats.xcdatamodeld
│   │   │   ├── Team+CoreDataClass.swift
│   │   │   ├── Player+CoreDataClass.swift
│   │   │   ├── Game+CoreDataClass.swift
│   │   │   ├── StatEvent+CoreDataClass.swift
│   │   │   ├── GamePlayer+CoreDataClass.swift
│   │   │   └── Season+CoreDataClass.swift
│   │   └── Enums/
│   │       ├── StatType.swift
│   │       ├── PlayerPosition.swift
│   │       └── GameStatus.swift
│   ├── Repositories/
│   │   ├── BaseRepository.swift
│   │   ├── TeamRepository.swift
│   │   ├── PlayerRepository.swift
│   │   ├── GameRepository.swift
│   │   ├── StatEventRepository.swift
│   │   └── RepositoryError.swift
│   ├── DTOs/
│   │   ├── TeamDTO.swift
│   │   ├── PlayerDTO.swift
│   │   ├── GameDTO.swift
│   │   ├── StatEventDTO.swift
│   │   └── PlayerStatsDTO.swift
│   └── CoreData/
│       └── CoreDataStack.swift
│
├── Domain/
│   ├── Entities/
│   │   └── (Domain models if needed)
│   ├── UseCases/
│   │   ├── RecordStatUseCase.swift
│   │   ├── CreateGameUseCase.swift
│   │   ├── EndGameUseCase.swift
│   │   ├── ExportGameUseCase.swift
│   │   └── CalculateStatsUseCase.swift
│   └── Services/
│       ├── StatsCalculationService.swift
│       ├── GameTimerService.swift
│       ├── ValidationService.swift
│       └── ExportService.swift
│
├── Presentation/
│   ├── Coordinators/
│   │   ├── AppCoordinator.swift
│   │   ├── MainTabCoordinator.swift
│   │   ├── OnboardingCoordinator.swift
│   │   └── LiveGameCoordinator.swift
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   ├── WelcomeView.swift
│   │   │   ├── TeamSetupView.swift
│   │   │   └── PlayerSetupView.swift
│   │   ├── LiveGame/
│   │   │   ├── LiveGameView.swift
│   │   │   ├── StatButton.swift
│   │   │   ├── PlayerRowView.swift
│   │   │   └── GameStatusBar.swift
│   │   ├── Games/
│   │   │   ├── GamesListView.swift
│   │   │   ├── GameDetailView.swift
│   │   │   ├── GameSummaryView.swift
│   │   │   └── NewGameView.swift
│   │   ├── Team/
│   │   │   ├── TeamView.swift
│   │   │   ├── PlayerListView.swift
│   │   │   ├── PlayerDetailView.swift
│   │   │   └── EditPlayerView.swift
│   │   ├── Stats/
│   │   │   ├── StatsView.swift
│   │   │   ├── SeasonStatsView.swift
│   │   │   ├── PlayerStatsView.swift
│   │   │   └── ChartsView.swift
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── PreferencesView.swift
│   │   │   └── AboutView.swift
│   │   └── Home/
│   │       └── HomeView.swift
│   ├── ViewModels/
│   │   ├── LiveGameViewModel.swift
│   │   ├── GamesListViewModel.swift
│   │   ├── GameDetailViewModel.swift
│   │   ├── TeamViewModel.swift
│   │   ├── StatsViewModel.swift
│   │   └── SettingsViewModel.swift
│   └── Components/
│       ├── StatButton.swift
│       ├── QuickScoreButton.swift
│       ├── StatSummaryItem.swift
│       ├── PlayerRow.swift
│       ├── GameCard.swift
│       └── CustomButtons.swift
│
├── Infrastructure/
│   ├── Export/
│   │   ├── CSVExporter.swift
│   │   ├── PDFExporter.swift
│   │   └── ExportManager.swift
│   ├── Analytics/
│   │   └── AnalyticsManager.swift (optional)
│   └── Networking/
│       └── (Future API integration)
│
└── Resources/
    ├── Assets.xcassets/
    │   ├── Colors/
    │   │   ├── StatGreen.colorset
    │   │   ├── StatRed.colorset
    │   │   ├── StatBlue.colorset
    │   │   ├── StatOrange.colorset
    │   │   └── StatPurple.colorset
    │   ├── Icons/
    │   │   └── AppIcon.appiconset
    │   └── Images/
    ├── Localizable.strings
    └── LaunchScreen.storyboard
```

## 2.3 Dependency Flow

### Dependency Rules

1. **Inner layers don't depend on outer layers**
   - Domain layer independent of Presentation
   - Data layer independent of Presentation

2. **Dependencies point inward**
   - Presentation → Domain → Data → Persistence
   - Never: Data → Presentation

3. **Use dependency injection**
   - ViewModels receive repositories via initializer
   - Repositories receive context via initializer
   - No singletons except for Core Data stack

### Example Dependency Injection

```swift
// Bad: Direct dependency on Core Data
class LiveGameViewModel {
    private let context = CoreDataStack.shared.mainContext
    
    func recordStat() {
        let event = StatEvent(context: context)
        // ...
    }
}

// Good: Dependency injection with repository
class LiveGameViewModel {
    private let statRepository: StatEventRepository
    
    init(statRepository: StatEventRepository = StatEventRepository()) {
        self.statRepository = statRepository
    }
    
    func recordStat() {
        try statRepository.recordStat(...)
    }
}
```

## 2.4 Data Flow Patterns

### Unidirectional Data Flow

The app follows a unidirectional data flow pattern:

```
User Action → ViewModel → Use Case → Repository → Core Data
                ↑                                       │
                └───────── Published State ←────────────┘
```

### Example Flow: Recording a Stat

```swift
// 1. User taps stat button
StatButton(type: .twoPointMade) {
    viewModel.recordStat(.twoPointMade)  // User action
}

// 2. ViewModel processes action
@MainActor
class LiveGameViewModel: ObservableObject {
    @Published var stats: [StatEventDTO] = []
    private let recordStatUseCase: RecordStatUseCase
    
    func recordStat(_ type: StatType) {
        Task {
            do {
                // 3. Use case executes business logic
                let event = try await recordStatUseCase.execute(
                    playerId: focusPlayer.id,
                    gameId: game.id,
                    statType: type
                )
                
                // 4. Update published state
                stats.append(event)
                
            } catch {
                // Handle error
            }
        }
    }
}

// 3. Use case coordinates operation
class RecordStatUseCase {
    private let statRepository: StatEventRepository
    
    func execute(playerId: UUID, gameId: UUID, statType: StatType) async throws -> StatEventDTO {
        // Validation
        guard statType != .teamPoint else {
            throw UseCaseError.invalidStatType
        }
        
        // 4. Repository persists data
        let event = try statRepository.recordStat(
            playerId: playerId,
            gameId: gameId,
            statType: statType
        )
        
        // 5. Return DTO
        return StatEventDTO(from: event)
    }
}

// 4. Repository handles Core Data
class StatEventRepository: BaseRepository<StatEvent> {
    func recordStat(...) throws -> StatEvent {
        let event = StatEvent(context: context)
        event.id = UUID()
        event.playerId = playerId
        // ... set properties
        
        try save()  // Persist to Core Data
        return event
    }
}

// 5. View automatically updates
struct LiveGameView: View {
    @StateObject var viewModel: LiveGameViewModel
    
    var body: some View {
        // View re-renders when stats changes
        Text("Points: \(viewModel.totalPoints)")
    }
}
```

## 2.5 Communication Patterns

### Between Layers

1. **Presentation → Domain**: Direct method calls
2. **Domain → Data**: Protocol-based repository interfaces
3. **Data → Persistence**: Core Data operations
4. **State Updates**: Combine publishers (@Published)

### Between Components

1. **View → ViewModel**: Direct method calls, binding
2. **ViewModel → ViewModel**: Avoid (use shared service instead)
3. **Coordinator → View**: Environment objects, dependency injection

### Asynchronous Operations

```swift
// Use async/await for asynchronous operations
class GameRepository {
    func fetchGames() async throws -> [Game] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let games = try fetch()
                continuation.resume(returning: games)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

// Use Combine for reactive state
class LiveGameViewModel: ObservableObject {
    @Published var teamScore: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // React to stat changes
        $stats
            .map { stats in
                stats.filter { $0.statType.isPointType }
                     .reduce(0) { $0 + $1.value }
            }
            .assign(to: &$teamScore)
    }
}
```

## 2.6 Error Handling Strategy

### Error Types

```swift
// Domain errors
enum UseCaseError: LocalizedError {
    case invalidInput(String)
    case businessRuleViolation(String)
    case operationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let msg): return "Invalid input: \(msg)"
        case .businessRuleViolation(let msg): return msg
        case .operationFailed(let error): return error.localizedDescription
        }
    }
}

// Repository errors
enum RepositoryError: LocalizedError {
    case entityNotFound
    case invalidData
    case saveFailed(Error)
    case fetchFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .entityNotFound: return "Entity not found"
        case .invalidData: return "Invalid data"
        case .saveFailed(let error): return "Save failed: \(error.localizedDescription)"
        case .fetchFailed(let error): return "Fetch failed: \(error.localizedDescription)"
        }
    }
}
```

### Error Propagation

```swift
// Repository throws specific errors
class GameRepository {
    func fetchGame(byId id: UUID) throws -> Game? {
        do {
            return try fetch(predicate: ...).first
        } catch {
            throw RepositoryError.fetchFailed(error)
        }
    }
}

// Use case handles and transforms errors
class FetchGameUseCase {
    func execute(gameId: UUID) throws -> GameDTO {
        guard let game = try repository.fetchGame(byId: gameId) else {
            throw UseCaseError.invalidInput("Game not found")
        }
        return GameDTO(from: game)
    }
}

// ViewModel presents errors to user
class GameDetailViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    func loadGame(id: UUID) {
        do {
            let game = try fetchGameUseCase.execute(gameId: id)
            self.game = game
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## 2.7 State Management

### ViewModel State Pattern

```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

class GamesListViewModel: ObservableObject {
    @Published var state: ViewState<[GameDTO]> = .idle
    
    func loadGames() {
        state = .loading
        
        Task {
            do {
                let games = try await fetchGamesUseCase.execute()
                state = .loaded(games)
            } catch {
                state = .error(error)
            }
        }
    }
}

// View responds to state
struct GamesListView: View {
    @StateObject var viewModel: GamesListViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Text("Tap to load games")
            case .loading:
                ProgressView()
            case .loaded(let games):
                List(games) { game in
                    GameRow(game: game)
                }
            case .error(let error):
                ErrorView(error: error)
            }
        }
        .onAppear {
            viewModel.loadGames()
        }
    }
}
```


3. [Data Architecture](#data-architecture)
   - 3.1 [Core Data Model Schema](#core-data-model-schema)
   - 3.2 [Core Data Stack](#core-data-stack)
   - 3.3 [Repository Pattern Implementation](#repository-pattern)
   - 3.4 [Data Transfer Objects (DTOs)](#data-transfer-objects)
   - 3.5 [Data Mappers](#data-mappers)
   - 3.6 [Query Optimization](#query-optimization)

---
# Basketball Stats Tracker - Architectural Design Document

## Document Version: 1.0
## Target Platform: iOS 16+
## Language: Swift 5.9+
## Framework: SwiftUI + Combine
## Document Part: Section 3 - Data Architecture

---

# TABLE OF CONTENTS

3. [Data Architecture](#data-architecture)
   - 3.1 [Core Data Model Schema](#core-data-model-schema)
   - 3.2 [Core Data Stack](#core-data-stack)
   - 3.3 [Repository Pattern Implementation](#repository-pattern)
   - 3.4 [Data Transfer Objects (DTOs)](#data-transfer-objects)
   - 3.5 [Data Mappers](#data-mappers)
   - 3.6 [Query Optimization](#query-optimization)

---

<a name="data-architecture"></a>
# 3. DATA ARCHITECTURE

## 3.1 Core Data Model Schema

### 3.1.1 Entity Relationship Diagram

```
┌─────────────────────────┐
│        Season           │
│─────────────────────────│
│ id: UUID (PK)           │
│ teamId: UUID (FK)       │◀──────────┐
│ name: String            │           │
│ startDate: Date         │           │
│ endDate: Date?          │           │
│ isActive: Bool          │           │
└─────────────────────────┘           │
                                      │
┌─────────────────────────┐           │
│        Team             │           │
│─────────────────────────│           │
│ id: UUID (PK)           │───────────┘
│ name: String            │
│ season: String          │
│ createdAt: Date         │
│ colorHex: String?       │
│ logoData: Data?         │
└─────────────────────────┘
         │ 1
         │
         │ N
         ▼
┌─────────────────────────┐
│        Player           │
│─────────────────────────│
│ id: UUID (PK)           │
│ teamId: UUID (FK)       │
│ name: String            │
│ jerseyNumber: String?   │
│ isFocusPlayer: Bool     │
│ photoData: Data?        │
│ position: String?       │
│ height: String?         │
│ weight: String?         │
│ dateOfBirth: Date?      │
│ createdAt: Date         │
└─────────────────────────┘
         │ 1
         │
         │ N
         ▼
┌─────────────────────────┐         ┌─────────────────────────┐
│      StatEvent          │    N    │        Game             │
│─────────────────────────│◀────────│─────────────────────────│
│ id: UUID (PK)           │         │ id: UUID (PK)           │
│ playerId: UUID (FK)     │         │ teamId: UUID (FK)       │
│ gameId: UUID (FK)       │────────▶│ opponentName: String    │
│ timestamp: Date         │    N    │ opponentScore: Int32    │
│ statType: String        │         │ gameDate: Date          │
│ value: Int32            │         │ location: String?       │
│ period: Int32           │         │ duration: Int32         │
│ gameTime: String?       │         │ notes: String?          │
│ courtX: Float           │         │ isComplete: Bool        │
│ courtY: Float           │         │ homeAway: String?       │
│ isDeleted: Bool         │         │ weatherConditions: Str? │
└─────────────────────────┘         │ createdAt: Date         │
                                    │ updatedAt: Date         │
         ┌──────────────────────────└─────────────────────────┘
         │                                    │ 1
         │                                    │
         │ N                                  │ N
         ▼                                    ▼
┌─────────────────────────┐         ┌─────────────────────────┐
│      GamePlayer         │    N    │       Player            │
│  (Junction Table)       │◀────────│   (Reference above)     │
│─────────────────────────│         └─────────────────────────┘
│ id: UUID (PK)           │
│ gameId: UUID (FK)       │
│ playerId: UUID (FK)     │
│ minutesPlayed: Int32    │
│ starterStatus: Bool     │
│ plusMinus: Int32        │
└─────────────────────────┘
```

### 3.1.2 Core Data Entity Definitions

#### Team Entity

```swift
// Team+CoreDataClass.swift
import Foundation
import CoreData

@objc(Team)
public class Team: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var season: String
    @NSManaged public var createdAt: Date
    @NSManaged public var colorHex: String?
    @NSManaged public var logoData: Data?
    
    // Relationships
    @NSManaged public var players: NSSet?
    @NSManaged public var games: NSSet?
    @NSManaged public var seasonEntity: Season?
}

extension Team {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }
    
    var playersArray: [Player] {
        let set = players as? Set<Player> ?? []
        return set.sorted { 
            guard let num1 = $0.jerseyNumber, let num2 = $1.jerseyNumber else {
                return ($0.jerseyNumber ?? "") < ($1.jerseyNumber ?? "")
            }
            return (Int(num1) ?? 0) < (Int(num2) ?? 0)
        }
    }
    
    var gamesArray: [Game] {
        let set = games as? Set<Game> ?? []
        return set.sorted { $0.gameDate > $1.gameDate }
    }
    
    var completedGames: [Game] {
        return gamesArray.filter { $0.isComplete }
    }
    
    var inProgressGames: [Game] {
        return gamesArray.filter { !$0.isComplete }
    }
}

extension Team {
    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: Player)
    
    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: Player)
    
    @objc(addGamesObject:)
    @NSManaged public func addToGames(_ value: Game)
    
    @objc(removeGamesObject:)
    @NSManaged public func removeFromGames(_ value: Game)
}
```

#### Player Entity

```swift
// Player+CoreDataClass.swift
import Foundation
import CoreData

@objc(Player)
public class Player: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var teamId: UUID
    @NSManaged public var name: String
    @NSManaged public var jerseyNumber: String?
    @NSManaged public var isFocusPlayer: Bool
    @NSManaged public var photoData: Data?
    @NSManaged public var position: String?
    @NSManaged public var height: String?
    @NSManaged public var weight: String?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var createdAt: Date
    
    // Relationships
    @NSManaged public var team: Team?
    @NSManaged public var statEvents: NSSet?
    @NSManaged public var gamePlayers: NSSet?
}

extension Player {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }
    
    var displayName: String {
        if let number = jerseyNumber, !number.isEmpty {
            return "#\(number) \(name)"
        }
        return name
    }
    
    var positionEnum: PlayerPosition? {
        guard let pos = position else { return nil }
        return PlayerPosition(rawValue: pos)
    }
    
    var statEventsArray: [StatEvent] {
        let set = statEvents as? Set<StatEvent> ?? []
        return set.filter { !$0.isDeleted }
                  .sorted { $0.timestamp < $1.timestamp }
    }
    
    var age: Int? {
        guard let birthDate = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }
}

extension Player {
    @objc(addStatEventsObject:)
    @NSManaged public func addToStatEvents(_ value: StatEvent)
    
    @objc(removeStatEventsObject:)
    @NSManaged public func removeFromStatEvents(_ value: StatEvent)
}
```

#### Game Entity

```swift
// Game+CoreDataClass.swift
import Foundation
import CoreData

@objc(Game)
public class Game: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var teamId: UUID
    @NSManaged public var opponentName: String
    @NSManaged public var opponentScore: Int32
    @NSManaged public var gameDate: Date
    @NSManaged public var location: String?
    @NSManaged public var duration: Int32
    @NSManaged public var notes: String?
    @NSManaged public var isComplete: Bool
    @NSManaged public var homeAway: String?
    @NSManaged public var weatherConditions: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    // Relationships
    @NSManaged public var team: Team?
    @NSManaged public var statEvents: NSSet?
    @NSManaged public var gamePlayers: NSSet?
}

extension Game {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }
    
    var teamScore: Int32 {
        guard let events = statEvents as? Set<StatEvent> else { return 0 }
        return Int32(events.filter { $0.isPointEvent && !$0.isDeleted }
                           .reduce(0) { $0 + Int($1.value) })
    }
    
    var result: GameResult {
        if !isComplete { return .inProgress }
        if teamScore > opponentScore { return .win }
        if teamScore < opponentScore { return .loss }
        return .tie
    }
    
    var margin: Int32 {
        return teamScore - opponentScore
    }
    
    var statEventsArray: [StatEvent] {
        let set = statEvents as? Set<StatEvent> ?? []
        return set.filter { !$0.isDeleted }
                  .sorted { $0.timestamp < $1.timestamp }
    }
    
    var gamePlayersArray: [GamePlayer] {
        let set = gamePlayers as? Set<GamePlayer> ?? []
        return set.sorted { 
            ($0.player?.jerseyNumber ?? "") < ($1.player?.jerseyNumber ?? "")
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: gameDate)
    }
}

enum GameResult: String {
    case win = "W"
    case loss = "L"
    case tie = "T"
    case inProgress = "IP"
    
    var displayName: String {
        switch self {
        case .win: return "Win"
        case .loss: return "Loss"
        case .tie: return "Tie"
        case .inProgress: return "In Progress"
        }
    }
}

extension Game {
    @objc(addStatEventsObject:)
    @NSManaged public func addToStatEvents(_ value: StatEvent)
    
    @objc(removeStatEventsObject:)
    @NSManaged public func removeFromStatEvents(_ value: StatEvent)
}
```

#### StatEvent Entity

```swift
// StatEvent+CoreDataClass.swift
import Foundation
import CoreData

@objc(StatEvent)
public class StatEvent: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var playerId: UUID
    @NSManaged public var gameId: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var statType: String
    @NSManaged public var value: Int32
    @NSManaged public var period: Int32
    @NSManaged public var gameTime: String?
    @NSManaged public var courtX: Float
    @NSManaged public var courtY: Float
    @NSManaged public var isDeleted: Bool
    
    // Relationships
    @NSManaged public var player: Player?
    @NSManaged public var game: Game?
}

extension StatEvent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StatEvent> {
        return NSFetchRequest<StatEvent>(entityName: "StatEvent")
    }
    
    var statTypeEnum: StatType? {
        return StatType(rawValue: statType)
    }
    
    var isPointEvent: Bool {
        guard let type = statTypeEnum else { return false }
        return type.isPointType
    }
    
    var isMake: Bool {
        guard let type = statTypeEnum else { return false }
        return type.isMake
    }
    
    var isMiss: Bool {
        guard let type = statTypeEnum else { return false }
        return type.isMiss
    }
    
    var displayDescription: String {
        guard let type = statTypeEnum else { return "Unknown" }
        let playerName = player?.name ?? "Unknown"
        return "\(playerName) - \(type.displayName)"
    }
}
```

#### GamePlayer Entity

```swift
// GamePlayer+CoreDataClass.swift
import Foundation
import CoreData

@objc(GamePlayer)
public class GamePlayer: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var gameId: UUID
    @NSManaged public var playerId: UUID
    @NSManaged public var minutesPlayed: Int32
    @NSManaged public var starterStatus: Bool
    @NSManaged public var plusMinus: Int32
    
    // Relationships
    @NSManaged public var game: Game?
    @NSManaged public var player: Player?
}

extension GamePlayer {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GamePlayer> {
        return NSFetchRequest<GamePlayer>(entityName: "GamePlayer")
    }
    
    var formattedMinutes: String {
        let minutes = Int(minutesPlayed)
        return "\(minutes) min"
    }
    
    var formattedPlusMinus: String {
        let pm = Int(plusMinus)
        if pm > 0 {
            return "+\(pm)"
        } else if pm < 0 {
            return "\(pm)"
        } else {
            return "0"
        }
    }
}
```

#### Season Entity

```swift
// Season+CoreDataClass.swift
import Foundation
import CoreData

@objc(Season)
public class Season: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var teamId: UUID
    @NSManaged public var name: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var isActive: Bool
    
    // Relationships
    @NSManaged public var team: Team?
}

extension Season {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Season> {
        return NSFetchRequest<Season>(entityName: "Season")
    }
    
    var isCurrentSeason: Bool {
        guard let end = endDate else {
            return isActive
        }
        return Date() <= end && isActive
    }
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        let start = formatter.string(from: startDate)
        if let end = endDate {
            let endStr = formatter.string(from: end)
            return "\(start) - \(endStr)"
        }
        return "\(start) - Present"
    }
}
```

### 3.1.3 Enumerations

```swift
// StatType.swift
enum StatType: String, CaseIterable, Codable {
    // Scoring - Made
    case freeThrowMade = "FT_MADE"
    case twoPointMade = "TWO_MADE"
    case threePointMade = "THREE_MADE"
    
    // Scoring - Missed
    case freeThrowMiss = "FT_MISS"
    case twoPointMiss = "TWO_MISS"
    case threePointMiss = "THREE_MISS"
    
    // Rebounds
    case rebound = "REBOUND"
    case offensiveRebound = "OFF_REBOUND"
    case defensiveRebound = "DEF_REBOUND"
    
    // Other stats
    case assist = "ASSIST"
    case steal = "STEAL"
    case block = "BLOCK"
    case turnover = "TURNOVER"
    case foul = "FOUL"
    
    // Team-only stat
    case teamPoint = "TEAM_POINT"
    
    var pointValue: Int {
        switch self {
        case .freeThrowMade: return 1
        case .twoPointMade, .teamPoint: return 2
        case .threePointMade: return 3
        default: return 0
        }
    }
    
    var isPointType: Bool {
        return pointValue > 0
    }
    
    var isMake: Bool {
        switch self {
        case .freeThrowMade, .twoPointMade, .threePointMade:
            return true
        default:
            return false
        }
    }
    
    var isMiss: Bool {
        switch self {
        case .freeThrowMiss, .twoPointMiss, .threePointMiss:
            return true
        default:
            return false
        }
    }
    
    var isShot: Bool {
        return isMake || isMiss
    }
    
    var displayName: String {
        switch self {
        case .freeThrowMade: return "FT Made"
        case .freeThrowMiss: return "FT Miss"
        case .twoPointMade: return "2PT Made"
        case .twoPointMiss: return "2PT Miss"
        case .threePointMade: return "3PT Made"
        case .threePointMiss: return "3PT Miss"
        case .rebound: return "Rebound"
        case .offensiveRebound: return "Off. Rebound"
        case .defensiveRebound: return "Def. Rebound"
        case .assist: return "Assist"
        case .steal: return "Steal"
        case .block: return "Block"
        case .turnover: return "Turnover"
        case .foul: return "Foul"
        case .teamPoint: return "Team Point"
        }
    }
    
    var shortName: String {
        switch self {
        case .freeThrowMade, .freeThrowMiss: return "FT"
        case .twoPointMade, .twoPointMiss: return "2PT"
        case .threePointMade, .threePointMiss: return "3PT"
        case .rebound: return "REB"
        case .offensiveRebound: return "OREB"
        case .defensiveRebound: return "DREB"
        case .assist: return "AST"
        case .steal: return "STL"
        case .block: return "BLK"
        case .turnover: return "TO"
        case .foul: return "PF"
        case .teamPoint: return "PTS"
        }
    }
    
    var iconName: String {
        switch self {
        case .freeThrowMade, .freeThrowMiss: 
            return "figure.basketball"
        case .twoPointMade, .twoPointMiss: 
            return "basketball.fill"
        case .threePointMade, .threePointMiss: 
            return "3.circle.fill"
        case .rebound, .offensiveRebound, .defensiveRebound: 
            return "arrow.down.circle.fill"
        case .assist: 
            return "hand.thumbsup.fill"
        case .steal: 
            return "hand.raised.fill"
        case .block: 
            return "hand.raised.slash.fill"
        case .turnover: 
            return "xmark.circle.fill"
        case .foul: 
            return "exclamationmark.triangle.fill"
        case .teamPoint: 
            return "plus.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .freeThrowMade, .twoPointMade, .threePointMade:
            return "StatGreen"
        case .freeThrowMiss, .twoPointMiss, .threePointMiss:
            return "StatRed"
        case .rebound, .offensiveRebound, .defensiveRebound, .assist, .steal, .block:
            return "StatBlue"
        case .turnover, .foul:
            return "StatOrange"
        case .teamPoint:
            return "StatPurple"
        }
    }
    
    static var scoringStats: [StatType] {
        [.freeThrowMade, .freeThrowMiss, .twoPointMade, .twoPointMiss, 
         .threePointMade, .threePointMiss]
    }
    
    static var otherStats: [StatType] {
        [.rebound, .assist, .steal, .block, .turnover, .foul]
    }
}

// PlayerPosition.swift
enum PlayerPosition: String, CaseIterable, Codable {
    case pointGuard = "PG"
    case shootingGuard = "SG"
    case smallForward = "SF"
    case powerForward = "PF"
    case center = "C"
    case guard = "G"
    case forward = "F"
    
    var fullName: String {
        switch self {
        case .pointGuard: return "Point Guard"
        case .shootingGuard: return "Shooting Guard"
        case .smallForward: return "Small Forward"
        case .powerForward: return "Power Forward"
        case .center: return "Center"
        case .guard: return "Guard"
        case .forward: return "Forward"
        }
    }
    
    var abbreviation: String {
        return rawValue
    }
}

// GameStatus.swift
enum GameStatus: String, Codable {
    case notStarted = "NOT_STARTED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case abandoned = "ABANDONED"
    
    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .abandoned: return "Abandoned"
        }
    }
}
```

<a name="core-data-stack"></a>
## 3.2 Core Data Stack

### 3.2.1 Core Data Stack Implementation

```swift
// CoreDataStack.swift
import CoreData
import CloudKit

final class CoreDataStack {
    
    // MARK: - Singleton
    static let shared = CoreDataStack()
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "BasketballStats")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve persistent store description")
        }
        
        configureStoreDescription(description)
        
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                self?.handlePersistentStoreError(error)
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        return container
    }()
    
    private func configureStoreDescription(_ description: NSPersistentStoreDescription) {
        description.setOption(true as NSNumber,
                            forKey: NSPersistentHistoryTrackingKey)
        
        description.setOption(true as NSNumber,
                            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if UserDefaults.standard.bool(forKey: "cloudSyncEnabled") {
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.yourdomain.basketballstats"
            )
        }
    }
    
    private func handlePersistentStoreError(_ error: NSError) {
        print("Core Data error: \(error), \(error.userInfo)")
        // In production: log to analytics, attempt recovery
    }
    
    // MARK: - Contexts
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }
    
    // MARK: - Save Operations
    
    func saveContext() {
        saveContext(mainContext)
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Batch Operations
    
    func batchDelete(entityName: String, predicate: NSPredicate? = nil) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try mainContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
        
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [mainContext]
            )
        }
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    @objc private func contextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }
        
        if context === mainContext { return }
        
        mainContext.perform {
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
```

<a name="repository-pattern"></a>
## 3.3 Repository Pattern Implementation

### 3.3.1 Base Repository

```swift
// BaseRepository.swift
import CoreData

class BaseRepository<T: NSManagedObject> {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }
    
    func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
    
    func fetch(predicate: NSPredicate? = nil,
               sortDescriptors: [NSSortDescriptor]? = nil,
               fetchLimit: Int? = nil) throws -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let limit = fetchLimit {
            request.fetchLimit = limit
        }
        return try context.fetch(request) as? [T] ?? []
    }
    
    func fetchFirst(predicate: NSPredicate? = nil,
                   sortDescriptors: [NSSortDescriptor]? = nil) throws -> T? {
        return try fetch(predicate: predicate, 
                        sortDescriptors: sortDescriptors, 
                        fetchLimit: 1).first
    }
    
    func count(predicate: NSPredicate? = nil) throws -> Int {
        let request = T.fetchRequest()
        request.predicate = predicate
        return try context.count(for: request)
    }
    
    func delete(_ object: T) throws {
        context.delete(object)
        try save()
    }
    
    func deleteAll(predicate: NSPredicate? = nil) throws {
        let objects = try fetch(predicate: predicate)
        objects.forEach { context.delete($0) }
        try save()
    }
}

// Repository Error
enum RepositoryError: LocalizedError {
    case entityNotFound
    case invalidData
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .entityNotFound: 
            return "Entity not found"
        case .invalidData: 
            return "Invalid data"
        case .saveFailed(let error): 
            return "Save failed: \(error.localizedDescription)"
        case .fetchFailed(let error): 
            return "Fetch failed: \(error.localizedDescription)"
        case .deleteFailed(let error): 
            return "Delete failed: \(error.localizedDescription)"
        }
    }
}
```

### 3.3.2 Specific Repositories

```swift
// TeamRepository.swift
class TeamRepository: BaseRepository<Team> {
    func createTeam(name: String, season: String, colorHex: String? = nil) throws -> Team {
        let team = Team(context: context)
        team.id = UUID()
        team.name = name
        team.season = season
        team.createdAt = Date()
        team.colorHex = colorHex
        try save()
        return team
    }
    
    func fetchTeam(byId id: UUID) throws -> Team? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try fetchFirst(predicate: predicate)
    }
    
    func fetchAllTeams() throws -> [Team] {
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        return try fetch(sortDescriptors: [sortDescriptor])
    }
    
    func fetchTeams(forSeason season: String) throws -> [Team] {
        let predicate = NSPredicate(format: "season == %@", season)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func updateTeam(_ team: Team, name: String?, season: String?, colorHex: String?) throws {
        if let name = name { team.name = name }
        if let season = season { team.season = season }
        if let colorHex = colorHex { team.colorHex = colorHex }
        try save()
    }
    
    func deleteTeam(_ teamId: UUID) throws {
        guard let team = try fetchTeam(byId: teamId) else {
            throw RepositoryError.entityNotFound
        }
        try delete(team)
    }
}

// PlayerRepository.swift
class PlayerRepository: BaseRepository<Player> {
    func createPlayer(name: String,
                     teamId: UUID,
                     jerseyNumber: String? = nil,
                     isFocusPlayer: Bool = false,
                     position: PlayerPosition? = nil) throws -> Player {
        let player = Player(context: context)
        player.id = UUID()
        player.name = name
        player.teamId = teamId
        player.jerseyNumber = jerseyNumber
        player.isFocusPlayer = isFocusPlayer
        player.position = position?.rawValue
        player.createdAt = Date()
        try save()
        return player
    }
    
    func fetchPlayer(byId id: UUID) throws -> Player? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try fetchFirst(predicate: predicate)
    }
    
    func fetchPlayers(forTeam teamId: UUID) throws -> [Player] {
        let predicate = NSPredicate(format: "teamId == %@", teamId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "jerseyNumber", ascending: true)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchFocusPlayer(forTeam teamId: UUID) throws -> Player? {
        let predicate = NSPredicate(format: "teamId == %@ AND isFocusPlayer == true", 
                                   teamId as CVarArg)
        return try fetchFirst(predicate: predicate)
    }
    
    func setFocusPlayer(_ playerId: UUID, forTeam teamId: UUID) throws {
        // Remove focus from all players in team
        let allPlayers = try fetchPlayers(forTeam: teamId)
        allPlayers.forEach { $0.isFocusPlayer = false }
        
        // Set focus on specified player
        guard let player = try fetchPlayer(byId: playerId) else {
            throw RepositoryError.entityNotFound
        }
        player.isFocusPlayer = true
        
        try save()
    }
    
    func updatePlayer(_ player: Player,
                     name: String? = nil,
                     jerseyNumber: String? = nil,
                     position: PlayerPosition? = nil,
                     photoData: Data? = nil) throws {
        if let name = name { player.name = name }
        if let jerseyNumber = jerseyNumber { player.jerseyNumber = jerseyNumber }
        if let position = position { player.position = position.rawValue }
        if let photoData = photoData { player.photoData = photoData }
        try save()
    }
    
    func deletePlayer(_ playerId: UUID) throws {
        guard let player = try fetchPlayer(byId: playerId) else {
            throw RepositoryError.entityNotFound
        }
        try delete(player)
    }
}

// GameRepository.swift
class GameRepository: BaseRepository<Game> {
    func createGame(teamId: UUID,
                   opponentName: String,
                   gameDate: Date,
                   location: String? = nil,
                   homeAway: String? = nil) throws -> Game {
        let game = Game(context: context)
        game.id = UUID()
        game.teamId = teamId
        game.opponentName = opponentName
        game.gameDate = gameDate
        game.location = location
        game.homeAway = homeAway
        game.opponentScore = 0
        game.duration = 0
        game.isComplete = false
        game.createdAt = Date()
        game.updatedAt = Date()
        try save()
        return game
    }
    
    func fetchGame(byId id: UUID) throws -> Game? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try fetchFirst(predicate: predicate)
    }
    
    func fetchGames(forTeam teamId: UUID) throws -> [Game] {
        let predicate = NSPredicate(format: "teamId == %@", teamId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "gameDate", ascending: false)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchCompletedGames(forTeam teamId: UUID) throws -> [Game] {
        let predicate = NSPredicate(format: "teamId == %@ AND isComplete == true", 
                                   teamId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "gameDate", ascending: false)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchInProgressGames() throws -> [Game] {
        let predicate = NSPredicate(format: "isComplete == false")
        let sortDescriptor = NSSortDescriptor(key: "gameDate", ascending: false)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchRecentGames(forTeam teamId: UUID, limit: Int = 10) throws -> [Game] {
        let predicate = NSPredicate(format: "teamId == %@ AND isComplete == true", 
                                   teamId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "gameDate", ascending: false)
        return try fetch(predicate: predicate, 
                        sortDescriptors: [sortDescriptor], 
                        fetchLimit: limit)
    }
    
    func updateOpponentScore(_ gameId: UUID, score: Int) throws {
        guard let game = try fetchGame(byId: gameId) else {
            throw RepositoryError.entityNotFound
        }
        game.opponentScore = Int32(score)
        game.updatedAt = Date()
        try save()
    }
    
    func completeGame(_ gameId: UUID, duration: Int? = nil, notes: String? = nil) throws {
        guard let game = try fetchGame(byId: gameId) else {
            throw RepositoryError.entityNotFound
        }
        game.isComplete = true
        if let duration = duration {
            game.duration = Int32(duration)
        }
        if let notes = notes {
            game.notes = notes
        }
        game.updatedAt = Date()
        try save()
    }
    
    func deleteGame(_ gameId: UUID) throws {
        guard let game = try fetchGame(byId: gameId) else {
            throw RepositoryError.entityNotFound
        }
        try delete(game)
    }
}

// StatEventRepository.swift
class StatEventRepository: BaseRepository<StatEvent> {
    func recordStat(playerId: UUID,
                   gameId: UUID,
                   statType: StatType,
                   period: Int? = nil,
                   gameTime: String? = nil,
                   courtX: Float? = nil,
                   courtY: Float? = nil) throws -> StatEvent {
        let event = StatEvent(context: context)
        event.id = UUID()
        event.playerId = playerId
        event.gameId = gameId
        event.timestamp = Date()
        event.statType = statType.rawValue
        event.value = Int32(statType.pointValue)
        event.period = Int32(period ?? 0)
        event.gameTime = gameTime
        event.courtX = courtX ?? 0
        event.courtY = courtY ?? 0
        event.isDeleted = false
        try save()
        return event
    }
    
    func fetchStats(forGame gameId: UUID) throws -> [StatEvent] {
        let predicate = NSPredicate(format: "gameId == %@ AND isDeleted == false", 
                                   gameId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchStats(forPlayer playerId: UUID, inGame gameId: UUID) throws -> [StatEvent] {
        let predicate = NSPredicate(
            format: "playerId == %@ AND gameId == %@ AND isDeleted == false",
            playerId as CVarArg, 
            gameId as CVarArg
        )
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchAllStats(forPlayer playerId: UUID) throws -> [StatEvent] {
        let predicate = NSPredicate(format: "playerId == %@ AND isDeleted == false", 
                                   playerId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchRecentStats(forGame gameId: UUID, limit: Int = 10) throws -> [StatEvent] {
        let predicate = NSPredicate(format: "gameId == %@ AND isDeleted == false", 
                                   gameId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        return try fetch(predicate: predicate, 
                        sortDescriptors: [sortDescriptor], 
                        fetchLimit: limit)
    }
    
    func fetchStatEvent(byId id: UUID) throws -> StatEvent? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try fetchFirst(predicate: predicate)
    }
    
    func softDelete(_ eventId: UUID) throws {
        guard let event = try fetchStatEvent(byId: eventId) else {
            throw RepositoryError.entityNotFound
        }
        event.isDeleted = true
        try save()
    }
    
    func undoDelete(_ eventId: UUID) throws {
        guard let event = try fetchStatEvent(byId: eventId) else {
            throw RepositoryError.entityNotFound
        }
        event.isDeleted = false
        try save()
    }
    
    func permanentlyDelete(_ eventId: UUID) throws {
        guard let event = try fetchStatEvent(byId: eventId) else {
            throw RepositoryError.entityNotFound
        }
        try delete(event)
    }
}

// SeasonRepository.swift
class SeasonRepository: BaseRepository<Season> {
    func createSeason(teamId: UUID,
                     name: String,
                     startDate: Date,
                     endDate: Date? = nil) throws -> Season {
        let season = Season(context: context)
        season.id = UUID()
        season.teamId = teamId
        season.name = name
        season.startDate = startDate
        season.endDate = endDate
        season.isActive = true
        try save()
        return season
    }
    
    func fetchSeason(byId id: UUID) throws -> Season? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try fetchFirst(predicate: predicate)
    }
    
    func fetchSeasons(forTeam teamId: UUID) throws -> [Season] {
        let predicate = NSPredicate(format: "teamId == %@", teamId as CVarArg)
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: false)
        return try fetch(predicate: predicate, sortDescriptors: [sortDescriptor])
    }
    
    func fetchActiveSeason(forTeam teamId: UUID) throws -> Season? {
        let predicate = NSPredicate(format: "teamId == %@ AND isActive == true", 
                                   teamId as CVarArg)
        return try fetchFirst(predicate: predicate)
    }
    
    func deactivateSeason(_ seasonId: UUID) throws {
        guard let season = try fetchSeason(byId: seasonId) else {
            throw RepositoryError.entityNotFound
        }
        season.isActive = false
        if season.endDate == nil {
            season.endDate = Date()
        }
        try save()
    }
}
```

<a name="data-transfer-objects"></a>
## 3.4 Data Transfer Objects (DTOs)

DTOs provide clean separation between Core Data entities and business logic.

```swift
// TeamDTO.swift
struct TeamDTO: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let season: String
    let createdAt: Date
    let colorHex: String?
    
    init(from team: Team) {
        self.id = team.id
        self.name = team.name
        self.season = team.season
        self.createdAt = team.createdAt
        self.colorHex = team.colorHex
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         season: String, 
         createdAt: Date = Date(),
         colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.season = season
        self.createdAt = createdAt
        self.colorHex = colorHex
    }
}

// PlayerDTO.swift
struct PlayerDTO: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let teamId: UUID
    let name: String
    let jerseyNumber: String?
    let isFocusPlayer: Bool
    let position: PlayerPosition?
    let photoData: Data?
    
    init(from player: Player) {
        self.id = player.id
        self.teamId = player.teamId
        self.name = player.name
        self.jerseyNumber = player.jerseyNumber
        self.isFocusPlayer = player.isFocusPlayer
        self.position = player.position.flatMap { PlayerPosition(rawValue: $0) }
        self.photoData = player.photoData
    }
    
    var displayName: String {
        if let number = jerseyNumber, !number.isEmpty {
            return "#\(number) \(name)"
        }
        return name
    }
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.compactMap { $0.first }.map(String.init).joined()
    }
}

// GameDTO.swift
struct GameDTO: Identifiable, Codable, Equatable {
    let id: UUID
    let teamId: UUID
    let opponentName: String
    let opponentScore: Int
    let gameDate: Date
    let location: String?
    let isComplete: Bool
    let teamScore: Int
    let duration: Int
    let notes: String?
    let homeAway: String?
    
    init(from game: Game) {
        self.id = game.id
        self.teamId = game.teamId
        self.opponentName = game.opponentName
        self.opponentScore = Int(game.opponentScore)
        self.gameDate = game.gameDate
        self.location = game.location
        self.isComplete = game.isComplete
        self.teamScore = Int(game.teamScore)
        self.duration = Int(game.duration)
        self.notes = game.notes
        self.homeAway = game.homeAway
    }
    
    var result: String {
        if !isComplete { return "In Progress" }
        if teamScore > opponentScore { return "W" }
        if teamScore < opponentScore { return "L" }
        return "T"
    }
    
    var margin: Int {
        return teamScore - opponentScore
    }
    
    var finalScore: String {
        return "\(teamScore) - \(opponentScore)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: gameDate)
    }
    
    var isWin: Bool {
        return isComplete && teamScore > opponentScore
    }
    
    var isLoss: Bool {
        return isComplete && teamScore < opponentScore
    }
}

// StatEventDTO.swift
struct StatEventDTO: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID
    let gameId: UUID
    let timestamp: Date
    let statType: StatType
    let value: Int
    let period: Int?
    let gameTime: String?
    let courtX: Float?
    let courtY: Float?
    
    init(from event: StatEvent) {
        self.id = event.id
        self.playerId = event.playerId
        self.gameId = event.gameId
        self.timestamp = event.timestamp
        self.statType = StatType(rawValue: event.statType) ?? .teamPoint
        self.value = Int(event.value)
        self.period = event.period > 0 ? Int(event.period) : nil
        self.gameTime = event.gameTime
        self.courtX = event.courtX
        self.courtY = event.courtY
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// PlayerStatsDTO.swift
struct PlayerStatsDTO: Identifiable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    let jerseyNumber: String?
    
    // Scoring
    var points: Int = 0
    var fgMade: Int = 0
    var fgAttempted: Int = 0
    var fgPercentage: Double = 0.0
    var threePtMade: Int = 0
    var threePtAttempted: Int = 0
    var threePtPercentage: Double = 0.0
    var ftMade: Int = 0
    var ftAttempted: Int = 0
    var ftPercentage: Double = 0.0
    
    // Other stats
    var rebounds: Int = 0
    var assists: Int = 0
    var steals: Int = 0
    var blocks: Int = 0
    var turnovers: Int = 0
    var fouls: Int = 0
    
    init(player: PlayerDTO, events: [StatEventDTO]) {
        self.id = player.id
        self.playerId = player.id
        self.playerName = player.name
        self.jerseyNumber = player.jerseyNumber
        
        // Calculate stats from events
        calculateStats(from: events)
    }
    
    private mutating func calculateStats(from events: [StatEventDTO]) {
        var pts = 0
        var fgm = 0, fga = 0
        var tpm = 0, tpa = 0
        var ftm = 0, fta = 0
        var reb = 0, ast = 0, stl = 0, blk = 0, tov = 0, pf = 0
        
        for event in events {
            switch event.statType {
            case .freeThrowMade:
                ftm += 1
                fta += 1
                pts += 1
            case .freeThrowMiss:
                fta += 1
            case .twoPointMade:
                fgm += 1
                fga += 1
                pts += 2
            case .twoPointMiss:
                fga += 1
            case .threePointMade:
                tpm += 1
                tpa += 1
                fgm += 1
                fga += 1
                pts += 3
            case .threePointMiss:
                tpa += 1
                fga += 1
            case .rebound, .offensiveRebound, .defensiveRebound:
                reb += 1
            case .assist:
                ast += 1
            case .steal:
                stl += 1
            case .block:
                blk += 1
            case .turnover:
                tov += 1
            case .foul:
                pf += 1
            case .teamPoint:
                pts += 2
            }
        }
        
        self.points = pts
        self.fgMade = fgm
        self.fgAttempted = fga
        self.fgPercentage = fga > 0 ? Double(fgm) / Double(fga) * 100.0 : 0.0
        self.threePtMade = tpm
        self.threePtAttempted = tpa
        self.threePtPercentage = tpa > 0 ? Double(tpm) / Double(tpa) * 100.0 : 0.0
        self.ftMade = ftm
        self.ftAttempted = fta
        self.ftPercentage = fta > 0 ? Double(ftm) / Double(fta) * 100.0 : 0.0
        self.rebounds = reb
        self.assists = ast
        self.steals = stl
        self.blocks = blk
        self.turnovers = tov
        self.fouls = pf
    }
    
    var fieldGoalDisplay: String {
        return "\(fgMade)/\(fgAttempted) (\(Int(fgPercentage))%)"
    }
    
    var threePointDisplay: String {
        return "\(threePtMade)/\(threePtAttempted) (\(Int(threePtPercentage))%)"
    }
    
    var freeThrowDisplay: String {
        return "\(ftMade)/\(ftAttempted) (\(Int(ftPercentage))%)"
    }
}

// SeasonStatsDTO.swift
struct SeasonStatsDTO {
    let seasonName: String
    let gamesPlayed: Int
    let wins: Int
    let losses: Int
    let ties: Int
    
    // Averages
    let pointsPerGame: Double
    let reboundsPerGame: Double
    let assistsPerGame: Double
    let stealsPerGame: Double
    let blocksPerGame: Double
    
    // Shooting percentages
    let fieldGoalPercentage: Double
    let threePointPercentage: Double
    let freeThrowPercentage: Double
    
    // Totals
    let totalPoints: Int
    let totalRebounds: Int
    let totalAssists: Int
    let totalSteals: Int
    let totalBlocks: Int
    
    init(seasonName: String, games: [GameDTO], playerStats: [PlayerStatsDTO]) {
        self.seasonName = seasonName
        self.gamesPlayed = games.count
        self.wins = games.filter { $0.isWin }.count
        self.losses = games.filter { $0.isLoss }.count
        self.ties = games.filter { !$0.isWin && !$0.isLoss && $0.isComplete }.count
        
        // Calculate totals
        self.totalPoints = playerStats.reduce(0) { $0 + $1.points }
        self.totalRebounds = playerStats.reduce(0) { $0 + $1.rebounds }
        self.totalAssists = playerStats.reduce(0) { $0 + $1.assists }
        self.totalSteals = playerStats.reduce(0) { $0 + $1.steals }
        self.totalBlocks = playerStats.reduce(0) { $0 + $1.blocks }
        
        // Calculate averages
        let gamesCount = Double(max(gamesPlayed, 1))
        self.pointsPerGame = Double(totalPoints) / gamesCount
        self.reboundsPerGame = Double(totalRebounds) / gamesCount
        self.assistsPerGame = Double(totalAssists) / gamesCount
        self.stealsPerGame = Double(totalSteals) / gamesCount
        self.blocksPerGame = Double(totalBlocks) / gamesCount
        
        // Calculate shooting percentages
        let totalFGM = playerStats.reduce(0) { $0 + $1.fgMade }
        let totalFGA = playerStats.reduce(0) { $0 + $1.fgAttempted }
        self.fieldGoalPercentage = totalFGA > 0 ? Double(totalFGM) / Double(totalFGA) * 100.0 : 0.0
        
        let total3PM = playerStats.reduce(0) { $0 + $1.threePtMade }
        let total3PA = playerStats.reduce(0) { $0 + $1.threePtAttempted }
        self.threePointPercentage = total3PA > 0 ? Double(total3PM) / Double(total3PA) * 100.0 : 0.0
        
        let totalFTM = playerStats.reduce(0) { $0 + $1.ftMade }
        let totalFTA = playerStats.reduce(0) { $0 + $1.ftAttempted }
        self.freeThrowPercentage = totalFTA > 0 ? Double(totalFTM) / Double(totalFTA) * 100.0 : 0.0
    }
    
    var winPercentage: Double {
        let totalDecidedGames = wins + losses
        guard totalDecidedGames > 0 else { return 0.0 }
        return Double(wins) / Double(totalDecidedGames) * 100.0
    }
    
    var record: String {
        return "\(wins)-\(losses)" + (ties > 0 ? "-\(ties)" : "")
    }
}
```

<a name="data-mappers"></a>
## 3.5 Data Mappers

```swift
// EntityMapper.swift
protocol EntityMapper {
    associatedtype Entity
    associatedtype DTO
    
    static func toDTO(from entity: Entity) -> DTO
    static func toEntity(from dto: DTO, context: NSManagedObjectContext) -> Entity
}

// TeamMapper.swift
struct TeamMapper: EntityMapper {
    static func toDTO(from entity: Team) -> TeamDTO {
        return TeamDTO(from: entity)
    }
    
    static func toEntity(from dto: TeamDTO, context: NSManagedObjectContext) -> Team {
        let team = Team(context: context)
        team.id = dto.id
        team.name = dto.name
        team.season = dto.season
        team.createdAt = dto.createdAt
        team.colorHex = dto.colorHex
        return team
    }
}

// PlayerMapper.swift
struct PlayerMapper: EntityMapper {
    static func toDTO(from entity: Player) -> PlayerDTO {
        return PlayerDTO(from: entity)
    }
    
    static func toEntity(from dto: PlayerDTO, context: NSManagedObjectContext) -> Player {
        let player = Player(context: context)
        player.id = dto.id
        player.teamId = dto.teamId
        player.name = dto.name
        player.jerseyNumber = dto.jerseyNumber
        player.isFocusPlayer = dto.isFocusPlayer
        player.position = dto.position?.rawValue
        player.photoData = dto.photoData
        player.createdAt = Date()
        return player
    }
}

// Bulk mapping utilities
extension Array where Element == Team {
    func toDTOs() -> [TeamDTO] {
        return self.map { TeamDTO(from: $0) }
    }
}

extension Array where Element == Player {
    func toDTOs() -> [PlayerDTO] {
        return self.map { PlayerDTO(from: $0) }
    }
}

extension Array where Element == Game {
    func toDTOs() -> [GameDTO] {
        return self.map { GameDTO(from: $0) }
    }
}

extension Array where Element == StatEvent {
    func toDTOs() -> [StatEventDTO] {
        return self.map { StatEventDTO(from: $0) }
    }
}
```

<a name="query-optimization"></a>
## 3.6 Query Optimization

### 3.6.1 Fetch Request Optimization

```swift
// OptimizedQueries.swift
extension NSFetchRequest {
    func optimizeForMemory() -> Self {
        // Return faults instead of full objects
        returnsObjectsAsFaults = true
        
        // Batch fetching
        fetchBatchSize = 20
        
        return self
    }
    
    func optimizeForSpeed() -> Self {
        // Pre-fetch relationships
        relationshipKeyPathsForPrefetching = []
        
        // Don't return faults
        returnsObjectsAsFaults = false
        
        return self
    }
}

// Optimized repository methods
extension GameRepository {
    func fetchGamesWithStats(forTeam teamId: UUID) throws -> [Game] {
        let request = Game.fetchRequest()
        request.predicate = NSPredicate(format: "teamId == %@", teamId as CVarArg)
        request.relationshipKeyPathsForPrefetching = ["statEvents", "gamePlayers"]
        request.sortDescriptors = [NSSortDescriptor(key: "gameDate", ascending: false)]
        
        return try context.fetch(request)
    }
}

extension StatEventRepository {
    func fetchStatsEfficiently(forGame gameId: UUID) throws -> [StatEvent] {
        let request = StatEvent.fetchRequest()
        request.predicate = NSPredicate(
            format: "gameId == %@ AND isDeleted == false",
            gameId as CVarArg
        )
        request.relationshipKeyPathsForPrefetching = ["player"]
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        return try context.fetch(request)
    }
}
```

### 3.6.2 Compound Predicates for Complex Queries

```swift
// ComplexQueries.swift
extension GameRepository {
    func fetchGames(forTeam teamId: UUID, 
                   dateRange: ClosedRange<Date>? = nil,
                   completed: Bool? = nil,
                   opponent: String? = nil) throws -> [Game] {
        var predicates: [NSPredicate] = [
            NSPredicate(format: "teamId == %@", teamId as CVarArg)
        ]
        
        if let range = dateRange {
            predicates.append(NSPredicate(
                format: "gameDate >= %@ AND gameDate <= %@",
                range.lowerBound as NSDate,
                range.upperBound as NSDate
            ))
        }
        
        if let isCompleted = completed {
            predicates.append(NSPredicate(
                format: "isComplete == %@",
                NSNumber(value: isCompleted)
            ))
        }
        
        if let opp = opponent {
            predicates.append(NSPredicate(
                format: "opponentName CONTAINS[cd] %@",
                opp
            ))
        }
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let sortDescriptor = NSSortDescriptor(key: "gameDate", ascending: false)
        
        return try fetch(predicate: compoundPredicate, sortDescriptors: [sortDescriptor])
    }
}

extension StatEventRepository {
    func fetchStats(forPlayer playerId: UUID,
                   statTypes: [StatType]? = nil,
                   dateRange: ClosedRange<Date>? = nil) throws -> [StatEvent] {
        var predicates: [NSPredicate] = [
            NSPredicate(format: "playerId == %@ AND isDeleted == false", playerId as CVarArg)
        ]
        
        if let types = statTypes {
            let typeStrings = types.map { $0.rawValue }
            predicates.append(NSPredicate(format: "statType IN %@", typeStrings))
        }
        
        if let range = dateRange {
            predicates.append(NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                range.lowerBound as NSDate,
                range.upperBound as NSDate
            ))
        }
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        
        return try fetch(predicate: compoundPredicate, sortDescriptors: [sortDescriptor])
    }
}
```

### 3.6.3 Aggregation Queries

```swift
// AggregationQueries.swift
extension StatEventRepository {
    func countStats(forPlayer playerId: UUID, 
                   statType: StatType,
                   inGame gameId: UUID? = nil) throws -> Int {
        var predicateFormat = "playerId == %@ AND statType == %@ AND isDeleted == false"
        var arguments: [Any] = [playerId as CVarArg, statType.rawValue]
        
        if let gameId = gameId {
            predicateFormat += " AND gameId == %@"
            arguments.append(gameId as CVarArg)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        return try count(predicate: predicate)
    }
    
    func totalPoints(forPlayer playerId: UUID, inGame gameId: UUID? = nil) throws -> Int {
        let pointTypes: [StatType] = [.freeThrowMade, .twoPointMade, .threePointMade, .teamPoint]
        let typeStrings = pointTypes.map { $0.rawValue }
        
        var predicateFormat = "playerId == %@ AND statType IN %@ AND isDeleted == false"
        var arguments: [Any] = [playerId as CVarArg, typeStrings]
        
        if let gameId = gameId {
            predicateFormat += " AND gameId == %@"
            arguments.append(gameId as CVarArg)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        let events = try fetch(predicate: predicate)
        
        return events.reduce(0) { $0 + Int($1.value) }
    }
}

extension GameRepository {
    func winLossRecord(forTeam teamId: UUID) throws -> (wins: Int, losses: Int, ties: Int) {
        let games = try fetchCompletedGames(forTeam: teamId)
        
        var wins = 0
        var losses = 0
        var ties = 0
        
        for game in games {
            switch game.result {
            case .win: wins += 1
            case .loss: losses += 1
            case .tie: ties += 1
            default: break
            }
        }
        
        return (wins, losses, ties)
    }
    
    func averagePointsPerGame(forTeam teamId: UUID) throws -> Double {
        let games = try fetchCompletedGames(forTeam: teamId)
        guard !games.isEmpty else { return 0.0 }
        
        let totalPoints = games.reduce(0) { $0 + Int($1.teamScore) }
        return Double(totalPoints) / Double(games.count)
    }
}
```

### 3.6.4 Batch Updates

```swift
// BatchOperations.swift
extension CoreDataStack {
    func batchUpdate(entityName: String,
                    predicate: NSPredicate?,
                    propertiesToUpdate: [String: Any]) throws {
        let batchUpdate = NSBatchUpdateRequest(entityName: entityName)
        batchUpdate.predicate = predicate
        batchUpdate.propertiesToUpdate = propertiesToUpdate
        batchUpdate.resultType = .updatedObjectIDsResultType
        
        let result = try mainContext.execute(batchUpdate) as? NSBatchUpdateResult
        
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            let changes = [NSUpdatedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [mainContext]
            )
        }
    }
}

// Example usage in repository
extension StatEventRepository {
    func markAllAsDeleted(forGame gameId: UUID) throws {
        try CoreDataStack.shared.batchUpdate(
            entityName: "StatEvent",
            predicate: NSPredicate(format: "gameId == %@", gameId as CVarArg),
            propertiesToUpdate: ["isDeleted": true]
        )
    }
}
```

### 3.6.5 Memory Management

```swift
// MemoryManagement.swift
extension NSManagedObjectContext {
    func refreshAllObjects() {
        registeredObjects.forEach { object in
            refresh(object, mergeChanges: false)
        }
    }
    
    func resetContext() {
        reset()
    }
}

// Usage in repositories for large data operations
extension GameRepository {
    func performLargeDataOperation(_ operation: @escaping (NSManagedObjectContext) throws -> Void) throws {
        let backgroundContext = CoreDataStack.shared.newBackgroundContext()
        
        try backgroundContext.performAndWait {
            try operation(backgroundContext)
            
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }
            
            // Clear memory
            backgroundContext.refreshAllObjects()
        }
    }
}
```

### 3.6.6 Indexing Strategy

For optimal query performance, the following attributes should be indexed in the Core Data model:

**Team Entity:**
- `id` (indexed)
- `season` (indexed)

**Player Entity:**
- `id` (indexed)
- `teamId` (indexed)
- `isFocusPlayer` (indexed)

**Game Entity:**
- `id` (indexed)
- `teamId` (indexed)
- `gameDate` (indexed)
- `isComplete` (indexed)

**StatEvent Entity:**
- `id` (indexed)
- `playerId` (indexed)
- `gameId` (indexed)
- `timestamp` (indexed)
- `isDeleted` (indexed)
- Compound index on: `(gameId, playerId, isDeleted)`

**Season Entity:**
- `id` (indexed)
- `teamId` (indexed)
- `isActive` (indexed)

### 3.6.7 Query Performance Guidelines

1. **Use Predicates Efficiently:**
   - Put most restrictive predicates first
   - Use `IN` for multiple value checks instead of multiple `OR` conditions
   - Avoid negation predicates when possible

2. **Limit Result Sets:**
   - Always use `fetchLimit` when you only need a subset
   - Use `fetchBatchSize` for large result sets

3. **Prefetch Relationships:**
   - Use `relationshipKeyPathsForPrefetching` to avoid multiple round trips
   - Only prefetch relationships you'll actually use

4. **Use Faulting Appropriately:**
   - Set `returnsObjectsAsFaults = true` for lists
   - Set `returnsObjectsAsFaults = false` when you need immediate data access

5. **Background Context for Heavy Operations:**
   - Use background contexts for imports and batch operations
   - Save frequently to avoid keeping too many objects in memory

6. **Cache Counts:**
   - Cache frequently accessed counts instead of recalculating
   - Update cached values when underlying data changes

---

# Basketball Stats Tracker - Architectural Design Document

## Document Version: 1.0
## Target Platform: iOS 16+
## Language: Swift 5.9+
## Framework: SwiftUI + Combine
## Document Part: Section 4 - Application Structure

---

# TABLE OF CONTENTS

4. [Application Structure](#application-structure)
   - 4.1 [App Entry Point](#app-entry-point)
   - 4.2 [Navigation Architecture](#navigation-architecture)
   - 4.3 [Coordinator Pattern](#coordinator-pattern)
   - 4.4 [View Layer](#view-layer)
   - 4.5 [ViewModel Layer](#viewmodel-layer)
   - 4.6 [Use Cases (Business Logic)](#use-cases)
   - 4.7 [Services](#services)

---

<a name="application-structure"></a>
# 4. APPLICATION STRUCTURE

<a name="app-entry-point"></a>
## 4.1 App Entry Point

### 4.1.1 Main App File

```swift
// BasketballStatsTrackerApp.swift
import SwiftUI

@main
struct BasketballStatsTrackerApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        configureAppearance()
        registerNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            appCoordinator.rootView
                .environmentObject(appCoordinator)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(from: oldPhase, to: newPhase)
                }
        }
    }
    
    // MARK: - Configuration
    
    private func configureAppearance() {
        configureNavigationBar()
        configureTabBar()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "NavigationBackground")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "PrimaryText") ?? UIColor.label,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "PrimaryText") ?? UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "TabBarBackground")
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleMemoryWarning()
        }
    }
    
    // MARK: - Lifecycle Handling
    
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            appCoordinator.handleAppBecameActive()
        case .inactive:
            // App became inactive (e.g., phone call, notification)
            break
        case .background:
            appCoordinator.handleAppEnteredBackground()
            CoreDataStack.shared.saveContext()
        @unknown default:
            break
        }
    }
    
    private func handleMemoryWarning() {
        // Clear any caches
        ImageCache.shared.clearCache()
        
        // Notify coordinator
        appCoordinator.handleMemoryWarning()
    }
}

// MARK: - Image Cache (Simple implementation)

class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 1024 * 1024 * 50 // 50 MB
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
```

### 4.1.2 App Delegate (if needed)

```swift
// AppDelegate.swift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Additional app setup if needed
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save data before termination
        CoreDataStack.shared.saveContext()
    }
}
```

<a name="navigation-architecture"></a>
## 4.2 Navigation Architecture

### 4.2.1 App Flow Enum

```swift
// AppFlow.swift
enum AppFlow {
    case onboarding
    case main
    case liveGame
}

enum MainTab: Int {
    case home = 0
    case games = 1
    case team = 2
    case stats = 3
    case settings = 4
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .games: return "Games"
        case .team: return "Team"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .games: return "list.bullet"
        case .team: return "person.3.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gear"
        }
    }
}
```

<a name="coordinator-pattern"></a>
## 4.3 Coordinator Pattern

### 4.3.1 App Coordinator

```swift
// AppCoordinator.swift
import SwiftUI
import Combine

@MainActor
class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentFlow: AppFlow = .onboarding
    @Published var currentTeam: TeamDTO?
    @Published var activeGame: GameDTO?
    @Published var showingAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // Repositories
    private let teamRepository = TeamRepository()
    private let gameRepository = GameRepository()
    private let playerRepository = PlayerRepository()
    
    // MARK: - Initialization
    
    init() {
        checkInitialState()
    }
    
    // MARK: - Root View
    
    var rootView: some View {
        Group {
            switch currentFlow {
            case .onboarding:
                OnboardingCoordinator()
                    .environmentObject(self)
                    .transition(.opacity)
                
            case .main:
                MainTabCoordinator()
                    .environmentObject(self)
                    .transition(.opacity)
                
            case .liveGame:
                if let game = activeGame, let team = currentTeam {
                    LiveGameCoordinator(game: game, team: team)
                        .environmentObject(self)
                        .transition(.slide)
                } else {
                    // Fallback to main if data is missing
                    MainTabCoordinator()
                        .environmentObject(self)
                        .onAppear {
                            currentFlow = .main
                        }
                }
            }
        }
        .animation(.easeInOut, value: currentFlow)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - State Management
    
    private func checkInitialState() {
        do {
            let teams = try teamRepository.fetchAllTeams()
            
            if teams.isEmpty {
                currentFlow = .onboarding
            } else {
                currentFlow = .main
                currentTeam = TeamDTO(from: teams[0])
                checkForActiveGame()
            }
        } catch {
            currentFlow = .onboarding
            showError("Failed to load teams: \(error.localizedDescription)")
        }
    }
    
    private func checkForActiveGame() {
        do {
            let inProgressGames = try gameRepository.fetchInProgressGames()
            
            if let game = inProgressGames.first {
                activeGame = GameDTO(from: game)
                // Don't automatically switch to live game on app launch
                // User should manually resume if desired
            }
        } catch {
            showError("Failed to check for active game: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Navigation Methods
    
    func completeOnboarding(team: TeamDTO) {
        currentTeam = team
        currentFlow = .main
    }
    
    func startGame(_ game: GameDTO) {
        activeGame = game
        currentFlow = .liveGame
    }
    
    func resumeGame() {
        guard activeGame != nil else { return }
        currentFlow = .liveGame
    }
    
    func endGame() {
        activeGame = nil
        currentFlow = .main
    }
    
    func switchTeam(_ team: TeamDTO) {
        currentTeam = team
        // Check if there's an active game for this team
        checkForActiveGame()
    }
    
    // MARK: - Lifecycle Handling
    
    func handleAppBecameActive() {
        // Refresh active game status
        checkForActiveGame()
    }
    
    func handleAppEnteredBackground() {
        // Save current state
        CoreDataStack.shared.saveContext()
    }
    
    func handleMemoryWarning() {
        // Clear non-essential caches
        ImageCache.shared.clearCache()
    }
    
    // MARK: - Error Handling
    
    func showError(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}
```

### 4.3.2 Onboarding Coordinator

```swift
// OnboardingCoordinator.swift
import SwiftUI

struct OnboardingCoordinator: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            WelcomeView(onContinue: {
                viewModel.navigationPath.append(OnboardingStep.teamSetup)
            })
            .navigationDestination(for: OnboardingStep.self) { step in
                destinationView(for: step)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            WelcomeView(onContinue: {
                viewModel.navigationPath.append(.teamSetup)
            })
            
        case .teamSetup:
            TeamSetupView(
                teamName: $viewModel.teamName,
                season: $viewModel.season,
                onContinue: {
                    viewModel.navigationPath.append(.playerSetup)
                }
            )
            
        case .playerSetup:
            PlayerSetupView(
                players: $viewModel.players,
                focusPlayerIndex: $viewModel.focusPlayerIndex,
                onComplete: {
                    completeOnboarding()
                }
            )
        }
    }
    
    private func completeOnboarding() {
        Task {
            do {
                let team = try await viewModel.createTeam()
                appCoordinator.completeOnboarding(team: team)
            } catch {
                appCoordinator.showError("Failed to create team: \(error.localizedDescription)")
            }
        }
    }
}

enum OnboardingStep: Hashable {
    case welcome
    case teamSetup
    case playerSetup
}

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var teamName = ""
    @Published var season = ""
    @Published var players: [PlayerInput] = []
    @Published var focusPlayerIndex: Int?
    
    private let teamRepository = TeamRepository()
    private let playerRepository = PlayerRepository()
    
    func createTeam() async throws -> TeamDTO {
        let team = try teamRepository.createTeam(name: teamName, season: season)
        
        for (index, playerInput) in players.enumerated() {
            let isFocus = index == focusPlayerIndex
            _ = try playerRepository.createPlayer(
                name: playerInput.name,
                teamId: team.id,
                jerseyNumber: playerInput.number,
                isFocusPlayer: isFocus
            )
        }
        
        return TeamDTO(from: team)
    }
}

struct PlayerInput: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var number: String
}
```

### 4.3.3 Main Tab Coordinator

```swift
// MainTabCoordinator.swift
import SwiftUI

struct MainTabCoordinator: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var selectedTab: MainTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(MainTab.home.title, systemImage: MainTab.home.iconName)
                }
                .tag(MainTab.home)
            
            GamesListView()
                .tabItem {
                    Label(MainTab.games.title, systemImage: MainTab.games.iconName)
                }
                .tag(MainTab.games)
            
            TeamView()
                .tabItem {
                    Label(MainTab.team.title, systemImage: MainTab.team.iconName)
                }
                .tag(MainTab.team)
            
            StatsView()
                .tabItem {
                    Label(MainTab.stats.title, systemImage: MainTab.stats.iconName)
                }
                .tag(MainTab.stats)
            
            SettingsView()
                .tabItem {
                    Label(MainTab.settings.title, systemImage: MainTab.settings.iconName)
                }
                .tag(MainTab.settings)
        }
    }
}
```

### 4.3.4 Live Game Coordinator

```swift
// LiveGameCoordinator.swift
import SwiftUI

struct LiveGameCoordinator: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    let game: GameDTO
    let team: TeamDTO
    
    @StateObject private var viewModel: LiveGameViewModel
    
    init(game: GameDTO, team: TeamDTO) {
        self.game = game
        self.team = team
        _viewModel = StateObject(wrappedValue: LiveGameViewModel(game: game, team: team))
    }
    
    var body: some View {
        LiveGameView(viewModel: viewModel)
            .onDisappear {
                // Save when leaving live game
                CoreDataStack.shared.saveContext()
            }
    }
}
```

<a name="view-layer"></a>
## 4.4 View Layer

### 4.4.1 Onboarding Views

```swift
// WelcomeView.swift
import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            
            Image(systemName: "basketball.fill")
                .font(.system(size: 100))
                .foregroundColor(Color("PrimaryBlue"))
                .padding(.bottom, Spacing.lg)
            
            VStack(spacing: Spacing.md) {
                Text("Basketball Stats Tracker")
                    .font(.displayMedium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("Track your child's performance and team scoring in real-time")
                    .font(.bodyLarge)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxl)
            }
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: ButtonSize.largeButton)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.button)
                            .fill(Color("PrimaryBlue"))
                    )
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xxl)
        }
        .navigationBarHidden(true)
    }
}

// TeamSetupView.swift
struct TeamSetupView: View {
    @Binding var teamName: String
    @Binding var season: String
    let onContinue: () -> Void
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case teamName
        case season
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Team Setup")
                    .font(.displaySmall)
                    .foregroundColor(.primary)
                
                Text("Let's start by creating your team")
                    .font(.bodyLarge)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
                .frame(height: Spacing.xxl)
            
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Team Name")
                    .font(.titleMedium)
                    .foregroundColor(.primary)
                
                TextField("Enter team name", text: $teamName)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .focused($focusedField, equals: .teamName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .season
                    }
            }
            
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Season")
                    .font(.titleMedium)
                    .foregroundColor(.primary)
                
                TextField("e.g., Fall 2025", text: $season)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .focused($focusedField, equals: .season)
                    .submitLabel(.continue)
                    .onSubmit {
                        if canContinue {
                            onContinue()
                        }
                    }
            }
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: ButtonSize.largeButton)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.button)
                            .fill(canContinue ? Color("PrimaryBlue") : Color.gray)
                    )
            }
            .disabled(!canContinue)
        }
        .padding(Spacing.lg)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focusedField = .teamName
        }
    }
    
    private var canContinue: Bool {
        !teamName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !season.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// Custom TextField Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.bodyLarge)
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
            )
    }
}

// PlayerSetupView.swift
struct PlayerSetupView: View {
    @Binding var players: [PlayerInput]
    @Binding var focusPlayerIndex: Int?
    let onComplete: () -> Void
    
    @State private var showingAddPlayer = false
    @State private var newPlayerName = ""
    @State private var newPlayerNumber = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Add Players")
                    .font(.displaySmall)
                    .foregroundColor(.primary)
                
                Text("Add all team members. Tap the star to select your focus player.")
                    .font(.bodyLarge)
                    .foregroundColor(.secondary)
            }
            
            if players.isEmpty {
                Spacer()
                
                VStack(spacing: Spacing.md) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No players added yet")
                        .font(.titleMedium)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                            PlayerRowInput(
                                player: player,
                                isFocus: focusPlayerIndex == index,
                                onToggleFocus: {
                                    focusPlayerIndex = index
                                },
                                onDelete: {
                                    deletePlayer(at: index)
                                }
                            )
                        }
                    }
                }
            }
            
            Button(action: {
                showingAddPlayer = true
            }) {
                Label("Add Player", systemImage: "plus.circle.fill")
                    .font(.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryBlue"))
                    .frame(maxWidth: .infinity)
                    .frame(height: ButtonSize.standardButton)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.button)
                            .strokeBorder(Color("PrimaryBlue"), lineWidth: 2)
                    )
            }
            
            Button(action: onComplete) {
                Text("Complete Setup")
                    .font(.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: ButtonSize.largeButton)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.button)
                            .fill(canComplete ? Color("PrimaryBlue") : Color.gray)
                    )
            }
            .disabled(!canComplete)
        }
        .padding(Spacing.lg)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerSheet(
                name: $newPlayerName,
                number: $newPlayerNumber,
                onAdd: {
                    addPlayer()
                },
                onCancel: {
                    clearNewPlayer()
                    showingAddPlayer = false
                }
            )
        }
    }
    
    private var canComplete: Bool {
        !players.isEmpty && focusPlayerIndex != nil
    }
    
    private func addPlayer() {
        players.append(PlayerInput(name: newPlayerName, number: newPlayerNumber))
        clearNewPlayer()
        showingAddPlayer = false
    }
    
    private func deletePlayer(at index: Int) {
        players.remove(at: index)
        if focusPlayerIndex == index {
            focusPlayerIndex = nil
        } else if let focusIndex = focusPlayerIndex, focusIndex > index {
            focusPlayerIndex = focusIndex - 1
        }
    }
    
    private func clearNewPlayer() {
        newPlayerName = ""
        newPlayerNumber = ""
    }
}

// PlayerRowInput.swift
struct PlayerRowInput: View {
    let player: PlayerInput
    let isFocus: Bool
    let onToggleFocus: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Button(action: onToggleFocus) {
                Image(systemName: isFocus ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(isFocus ? .yellow : .gray)
                    .frame(width: 30)
            }
            .buttonStyle(.plain)
            
            if !player.number.isEmpty {
                Text("#\(player.number)")
                    .font(.labelLarge)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
            }
            
            Text(player.name)
                .font(.bodyLarge)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(Color("SecondaryBackground"))
        )
    }
}

// AddPlayerSheet.swift
struct AddPlayerSheet: View {
    @Binding var name: String
    @Binding var number: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name
        case number
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Information")) {
                    TextField("Player Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .number
                        }
                    
                    TextField("Jersey Number (Optional)", text: $number)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .number)
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
    }
}
```

### 4.4.2 Home View

```swift
// HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Active Game Card
                    if let activeGame = viewModel.activeGame {
                        ActiveGameCard(
                            game: activeGame,
                            onResume: {
                                appCoordinator.resumeGame()
                            }
                        )
                        .padding(.horizontal, Spacing.lg)
                    }
                    
                    // Quick Start New Game
                    QuickStartGameCard(
                        onStartGame: {
                            viewModel.showingNewGame = true
                        }
                    )
                    .padding(.horizontal, Spacing.lg)
                    
                    // Recent Games
                    if !viewModel.recentGames.isEmpty {
                        RecentGamesSection(games: viewModel.recentGames)
                    }
                    
                    // Focus Player Stats Summary
                    if let focusPlayer = viewModel.focusPlayer,
                       let stats = viewModel.focusPlayerRecentStats {
                        FocusPlayerStatsCard(
                            player: focusPlayer,
                            stats: stats
                        )
                        .padding(.horizontal, Spacing.lg)
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Home")
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $viewModel.showingNewGame) {
                NewGameView(team: appCoordinator.currentTeam) { game in
                    appCoordinator.startGame(game)
                }
            }
        }
        .task {
            await viewModel.loadData(teamId: appCoordinator.currentTeam?.id)
        }
    }
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var activeGame: GameDTO?
    @Published var recentGames: [GameDTO] = []
    @Published var focusPlayer: PlayerDTO?
    @Published var focusPlayerRecentStats: PlayerStatsDTO?
    @Published var showingNewGame = false
    
    private let gameRepository = GameRepository()
    private let playerRepository = PlayerRepository()
    private let statRepository = StatEventRepository()
    
    func loadData(teamId: UUID?) async {
        guard let teamId = teamId else { return }
        
        do {
            // Load active game
            let inProgressGames = try gameRepository.fetchInProgressGames()
            activeGame = inProgressGames.first.map { GameDTO(from: $0) }
            
            // Load recent games
            let games = try gameRepository.fetchRecentGames(forTeam: teamId, limit: 5)
            recentGames = games.map { GameDTO(from: $0) }
            
            // Load focus player
            if let player = try playerRepository.fetchFocusPlayer(forTeam: teamId) {
                focusPlayer = PlayerDTO(from: player)
                
                // Load recent stats for focus player
                let allStats = try statRepository.fetchAllStats(forPlayer: player.id)
                let statDTOs = allStats.map { StatEventDTO(from: $0) }
                focusPlayerRecentStats = PlayerStatsDTO(player: PlayerDTO(from: player), events: statDTOs)
            }
        } catch {
            print("Error loading home data: \(error)")
        }
    }
    
    func refresh() async {
        // Reload all data
        await loadData(teamId: focusPlayer?.teamId)
    }
}

// ActiveGameCard.swift
struct ActiveGameCard: View {
    let game: GameDTO
    let onResume: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("StatGreen"))
                
                Text("Game In Progress")
                    .font(.headlineSmall)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("vs \(game.opponentName)")
                    .font(.titleLarge)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Current Score:")
                        .font(.bodyMedium)
                        .foregroundColor(.secondary)
                    
                    Text(game.finalScore)
                        .font(.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("PrimaryBlue"))
                }
                
                Text(game.formattedDate)
                    .font(.bodySmall)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onResume) {
                Text("Resume Game")
                    .font(.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: ButtonSize.standardButton)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.button)
                            .fill(Color("StatGreen"))
                    )
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(Color("TertiaryBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// QuickStartGameCard.swift
struct QuickStartGameCard: View {
    let onStartGame: () -> Void
    
    var body: some View {
        Button(action: onStartGame) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(Color("PrimaryBlue"))
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Start New Game")
                        .font(.titleLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Begin tracking a new game")
                        .font(.bodyMedium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(Color("SecondaryBackground"))
            )
        }
        .buttonStyle(.plain)
    }
}

// RecentGamesSection.swift
struct RecentGamesSection: View {
    let games: [GameDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Games")
                    .font(.headlineSmall)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: GamesListView()) {
                    Text("See All")
                        .font(.bodyMedium)
                        .foregroundColor(Color("PrimaryBlue"))
                }
            }
            .padding(.horizontal, Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(games) { game in
                        GameCard(game: game)
                            .frame(width: 280)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

// GameCard.swift
struct GameCard: View {
    let game: GameDTO
    
    var body: some View {
        NavigationLink(destination: GameDetailView(gameId: game.id)) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(game.opponentName)
                            .font(.titleMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(game.formattedDate)
                            .font(.bodySmall)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ResultBadge(result: game.result)
                }
                
                Divider()
                
                HStack {
                    Text("Final Score")
                        .font(.bodySmall)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(game.finalScore)
                        .font(.titleMedium)
                        .fontWeight(.bold)
                        .foregroundColor(game.isWin ? Color("StatGreen") : 
                                       game.isLoss ? Color("StatRed") : .secondary)
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .fill(Color("TertiaryBackground"))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// ResultBadge.swift
struct ResultBadge: View {
    let result: String
    
    var body: some View {
        Text(result)
            .font(.labelMedium)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(backgroundColor)
            )
    }
    
    private var backgroundColor: Color {
        switch result {
        case "W": return Color("StatGreen")
        case "L": return Color("StatRed")
        default: return Color.gray
        }
    }
}

// FocusPlayerStatsCard.swift
struct FocusPlayerStatsCard: View {
    let player: PlayerDTO
    let stats: PlayerStatsDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                
                Text("\(player.name)'s Stats")
                    .font(.headlineSmall)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                StatItem(label: "PPG", value: String(format: "%.1f", Double(stats.points)))
                StatItem(label: "RPG", value: String(format: "%.1f", Double(stats.rebounds)))
                StatItem(label: "APG", value: String(format: "%.1f", Double(stats.assists)))
                StatItem(label: "FG%", value: String(format: "%.0f%%", stats.fgPercentage))
                StatItem(label: "3P%", value: String(format: "%.0f%%", stats.threePtPercentage))
                StatItem(label: "FT%", value: String(format: "%.0f%%", stats.ftPercentage))
            }
            
            NavigationLink(destination: StatsView()) {
                Text("View Detailed Stats")
                    .font(.labelLarge)
                    .foregroundColor(Color("PrimaryBlue"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .strokeBorder(Color("PrimaryBlue"), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(Color("TertiaryBackground"))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// StatItem.swift
struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.titleLarge)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryBlue"))
            
            Text(label)
                .font(.bodySmall)
                .foregroundColor(.secondary)
        }
    }
}
```

### 4.4.3 Games List View

```swift
// GamesListView.swift
import SwiftUI

struct GamesListView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject private var viewModel = GamesListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear.onAppear {
                        Task {
                            await viewModel.loadGames(teamId: appCoordinator.currentTeam?.id)
                        }
                    }
                    
                case .loading:
                    ProgressView("Loading games...")
                    
                case .loaded(let games):
                    if games.isEmpty {
                        EmptyGamesView(onStartGame: {
                            viewModel.showingNewGame = true
                        })
                    } else {
                        gamesList(games: games)
                    }
                    
                case .error(let error):
                    ErrorView(
                        message: error.localizedDescription,
                        onRetry: {
                            Task {
                                await viewModel.loadGames(teamId: appCoordinator.currentTeam?.id)
                            }
                        }
                    )
                }
            }
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.showingNewGame = true
                    }) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Picker("Filter", selection: $viewModel.filterOption) {
                            Text("All Games").tag(GameFilter.all)
                            Text("Completed").tag(GameFilter.completed)
                            Text("In Progress").tag(GameFilter.inProgress)
                        }
                        
                        Picker("Sort", selection: $viewModel.sortOption) {
                            Text("Date (Newest)").tag(GameSort.dateDescending)
                            Text("Date (Oldest)").tag(GameSort.dateAscending)
                            Text("Opponent").tag(GameSort.opponent)
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh(teamId: appCoordinator.currentTeam?.id)
            }
            .sheet(isPresented: $viewModel.showingNewGame) {
                NewGameView(team: appCoordinator.currentTeam) { game in
                    appCoordinator.startGame(game)
                }
            }
        }
    }
    
    @ViewBuilder
    private func gamesList(games: [GameDTO]) -> some View {
        List {
            ForEach(games) { game in
                NavigationLink(destination: GameDetailView(gameId: game.id)) {
                    GameRowView(game: game)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.deleteGame(game)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

// ViewState enum
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

// GameFilter and Sort options
enum GameFilter {
    case all
    case completed
    case inProgress
}

enum GameSort {
    case dateDescending
    case dateAscending
    case opponent
}

@MainActor
class GamesListViewModel: ObservableObject {
    @Published var state: ViewState<[GameDTO]> = .idle
    @Published var showingNewGame = false
    @Published var filterOption: GameFilter = .all
    @Published var sortOption: GameSort = .dateDescending
    
    private let gameRepository = GameRepository()
    private var allGames: [GameDTO] = []
    
    func loadGames(teamId: UUID?) async {
        guard let teamId = teamId else { return }
        
        state = .loading
        
        do {
            let games = try gameRepository.fetchGames(forTeam: teamId)
            allGames = games.map { GameDTO(from: $0) }
            applyFiltersAndSort()
        } catch {
            state = .error(error)
        }
    }
    
    func refresh(teamId: UUID?) async {
        await loadGames(teamId: teamId)
    }
    
    func deleteGame(_ game: GameDTO) {
        Task {
            do {
                try gameRepository.deleteGame(game.id)
                allGames.removeAll { $0.id == game.id }
                applyFiltersAndSort()
            } catch {
                state = .error(error)
            }
        }
    }
    
    private func applyFiltersAndSort() {
        var filtered = allGames
        
        // Apply filter
        switch filterOption {
        case .all:
            break
        case .completed:
            filtered = filtered.filter { $0.isComplete }
        case .inProgress:
            filtered = filtered.filter { !$0.isComplete }
        }
        
        // Apply sort
        switch sortOption {
        case .dateDescending:
            filtered.sort { $0.gameDate > $1.gameDate }
        case .dateAscending:
            filtered.sort { $0.gameDate < $1.gameDate }
        case .opponent:
            filtered.sort { $0.opponentName < $1.opponentName }
        }
        
        state = .loaded(filtered)
    }
}

// GameRowView.swift
struct GameRowView: View {
    let game: GameDTO
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(game.opponentName)
                        .font(.titleMedium)
                        .fontWeight(.semibold)
                    
                    if !game.isComplete {
                        Text("In Progress")
                            .font(.labelSmall)
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("StatOrange"))
                            )
                    }
                }
                
                Text(game.formattedDate)
                    .font(.bodySmall)
                    .foregroundColor(.secondary)
                
                if let location = game.location {
                    Text(location)
                        .font(.bodySmall)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                if game.isComplete {
                    ResultBadge(result: game.result)
                }
                
                Text(game.finalScore)
                    .font(.titleMedium)
                    .fontWeight(.bold)
                    .foregroundColor(game.isWin ? Color("StatGreen") : 
                                   game.isLoss ? Color("StatRed") : .secondary)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// EmptyGamesView.swift
struct EmptyGamesView: View {
    let onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "basketball")
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: Spacing.sm) {
                Text("No Games Yet")
                    .font(.headlineMedium)
                    .fontWeight(.semibold)
                
                Text("Start your first game to begin tracking stats")
                    .font(.bodyMedium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onStartGame) {
                Text("Start New Game")
                    .font(.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.button)
                            .fill(Color("PrimaryBlue"))
                    )
            }
        }
        .padding(Spacing.xxl)
    }
}

// ErrorView.swift
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(Color("StatRed"))
            
            VStack(spacing: Spacing.sm) {
                Text("Error")
                    .font(.headlineMedium)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryBlue"))
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.button)
                            .strokeBorder(Color("PrimaryBlue"), lineWidth: 2)
                    )
            }
        }
        .padding(Spacing.xxl)
    }
}

// NewGameView.swift
struct NewGameView: View {
    let team: TeamDTO?
    let onGameCreated: (GameDTO) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NewGameViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Details")) {
                    TextField("Opponent Name", text: $viewModel.opponentName)
                    
                    DatePicker("Game Date", selection: $viewModel.gameDate)
                    
                    TextField("Location (Optional)", text: $viewModel.location)
                    
                    Picker("Home/Away", selection: $viewModel.homeAway) {
                        Text("Home").tag("home")
                        Text("Away").tag("away")
                        Text("Neutral").tag("neutral")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        createGame()
                    }
                    .disabled(!viewModel.canCreate)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func createGame() {
        guard let team = team else { return }
        
        Task {
            do {
                let game = try await viewModel.createGame(teamId: team.id)
                onGameCreated(game)
                dismiss()
            } catch {
                // Handle error
                print("Error creating game: \(error)")
            }
        }
    }
}

@MainActor
class NewGameViewModel: ObservableObject {
    @Published var opponentName = ""
    @Published var gameDate = Date()
    @Published var location = ""
    @Published var homeAway = "home"
    
    private let gameRepository = GameRepository()
    
    var canCreate: Bool {
        !opponentName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func createGame(teamId: UUID) async throws -> GameDTO {
        let game = try gameRepository.createGame(
            teamId: teamId,
            opponentName: opponentName,
            gameDate: gameDate,
            location: location.isEmpty ? nil : location,
            homeAway: homeAway
        )
        
        return GameDTO(from: game)
    }
}
```

### 4.4.4 Live Game View (Core Screen)

```swift
// LiveGameView.swift
import SwiftUI

struct LiveGameView: View {
    @ObservedObject var viewModel: LiveGameViewModel
    @State private var showingEndGameConfirmation = false
    @State private var lastTappedButton: StatType?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Status Bar - 10%
                statusBarSection
                    .frame(height: geometry.size.height * 0.10)
                
                Divider()
                
                // Main Content - 85%
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        playerStatusToggle
                        
                        Divider()
                        
                        if viewModel.isFocusPlayerActive {
                            focusPlayerStatsSection
                        }
                        
                        Divider()
                        
                        teamScoringSection
                    }
                    .padding(Spacing.md)
                }
                .frame(height: geometry.size.height * 0.85)
                
                Divider()
                
                // Undo Section - 5%
                undoSection
                    .frame(height: geometry.size.height * 0.05)
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog(
            "End Game",
            isPresented: $showingEndGameConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Game", role: .destructive) {
                viewModel.endGame()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to end this game? This cannot be undone.")
        }
    }
    
    // MARK: - Status Bar
    
    private var statusBarSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.game.opponentName)
                    .font(.labelMedium)
                    .foregroundColor(.secondary)
                Text("\(viewModel.opponentScore)")
                    .font(.scoreDisplay)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(":")
                .font(.scoreDisplay)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.team.name)
                    .font(.labelMedium)
                    .foregroundColor(.secondary)
                Text("\(viewModel.teamScore)")
                    .font(.scoreDisplay)
                    .foregroundColor(Color("PrimaryBlue"))
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                QuickScoreButton(points: 2, color: Color("StatOrange")) {
                    viewModel.recordOpponentScore(2)
                    hapticFeedback(.medium)
                }
                
                QuickScoreButton(points: 3, color: Color("StatOrange")) {
                    viewModel.recordOpponentScore(3)
                    hapticFeedback(.medium)
                }
            }
            
            Button(action: {
                showingEndGameConfirmation = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.leading, Spacing.md)
        }
        .padding(.horizontal, Spacing.lg)
        .background(Color("SecondaryBackground"))
    }
    
    // MARK: - Player Status Toggle
    
    private var playerStatusToggle: some View {
        Button(action: {
            viewModel.toggleFocusPlayerStatus()
            hapticFeedback(.heavy)
        }) {
            HStack {
                Image(systemName: viewModel.isFocusPlayerActive ? "figure.basketball" : "figure.stand")
                    .font(.title2)
                
                Text("\(viewModel.focusPlayer.name) \(viewModel.isFocusPlayerActive ? "IS PLAYING" : "ON BENCH")")
                    .font(.titleLarge)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .foregroundColor(.white)
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.button)
                    .fill(viewModel.isFocusPlayerActive ? Color("StatGreen") : Color.secondary)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Focus Player Stats Section
    
    private var focusPlayerStatsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Track: \(viewModel.focusPlayer.name)")
                .font(.headlineSmall)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm)
            ], spacing: Spacing.sm) {
                StatButton(type: .twoPointMade, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.twoPointMade)
                }
                
                StatButton(type: .twoPointMiss, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.twoPointMiss)
                }
                
                StatButton(type: .threePointMade, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.threePointMade)
                }
                
                StatButton(type: .threePointMiss, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.threePointMiss)
                }
                
                StatButton(type: .freeThrowMade, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.freeThrowMade)
                }
                
                StatButton(type: .freeThrowMiss, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.freeThrowMiss)
                }
                
                StatButton(type: .rebound, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.rebound)
                }
                
                StatButton(type: .steal, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.steal)
                }
                
                StatButton(type: .assist, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.assist)
                }
                
                StatButton(type: .block, lastTapped: $lastTappedButton) {
                    viewModel.recordFocusPlayerStat(.block)
                }
            }
            .frame(maxWidth: .infinity)
            
            focusPlayerStatsSummary
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(Color("TertiaryBackground"))
        )
    }
    
    private var focusPlayerStatsSummary: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.md) {
                StatSummaryItem(
                    label: "FT",
                    value: "\(viewModel.focusPlayerStats.ftMade)/\(viewModel.focusPlayerStats.ftAttempted)",
                    percentage: viewModel.focusPlayerStats.ftPercentage
                )
            }
            
            Divider()
                .padding(.vertical, Spacing.xs)
            
            HStack(spacing: Spacing.md) {
                StatSummaryItem(label: "REB", value: "\(viewModel.focusPlayerStats.rebounds)")
                StatSummaryItem(label: "AST", value: "\(viewModel.focusPlayerStats.assists)")
                StatSummaryItem(label: "STL", value: "\(viewModel.focusPlayerStats.steals)")
                StatSummaryItem(label: "BLK", value: "\(viewModel.focusPlayerStats.blocks)")
            }
        }
        .font(.bodySmall)
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(Color("SecondaryBackground"))
        )
    }
    
    // MARK: - Team Scoring Section
    
    private var teamScoringSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Team Scoring")
                .font(.headlineSmall)
                .foregroundColor(.primary)
            
            if viewModel.isFocusPlayerActive {
                ForEach(viewModel.teamPlayers.filter { $0.id != viewModel.focusPlayer.id }) { player in
                    SimplifiedPlayerRow(
                        player: player,
                        points: viewModel.getPlayerPoints(player.id)
                    ) { points in
                        viewModel.recordTeamPlayerScore(player.id, points: points)
                        hapticFeedback(.medium)
                    }
                }
            } else {
                ForEach(viewModel.teamPlayers) { player in
                    FullPlayerRow(
                        player: player,
                        points: viewModel.getPlayerPoints(player.id)
                    ) { points in
                        viewModel.recordTeamPlayerScore(player.id, points: points)
                        hapticFeedback(.medium)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .fill(Color("TertiaryBackground"))
        )
    }
    
    // MARK: - Undo Section
    
    private var undoSection: some View {
        Button(action: {
            viewModel.undoLastAction()
            hapticFeedback(.heavy)
        }) {
            HStack {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title3)
                Text("Undo Last Action")
                    .font(.labelLarge)
            }
            .foregroundColor(viewModel.canUndo ? Color("PrimaryBlue") : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(Color("SecondaryBackground"))
        }
        .disabled(!viewModel.canUndo)
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Functions
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Supporting Views

// StatButton.swift
struct StatButton: View {
    let type: StatType
    @Binding var lastTapped: StatType?
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            lastTapped = type
            animatePress()
            hapticFeedback()
        }) {
            VStack(spacing: 4) {
                Image(systemName: type.iconName)
                    .font(.title2)
                
                Text(type.displayName)
                    .font(.labelSmall)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: ButtonSize.statButton)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.button)
                    .fill(Color(type.color))
                    .opacity(isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.button)
                    .stroke(lastTapped == type ? Color.white : Color.clear, lineWidth: 3)
                    .animation(.easeInOut(duration: 0.3), value: lastTapped)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func animatePress() {
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// StatSummaryItem.swift
struct StatSummaryItem: View {
    let label: String
    let value: String
    var percentage: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.labelSmall)
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.labelMedium)
                    .foregroundColor(.primary)
                
                if let pct = percentage {
                    Text("(\(Int(pct))%)")
                        .font(.labelSmall)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// SimplifiedPlayerRow.swift
struct SimplifiedPlayerRow: View {
    let player: PlayerDTO
    let points: Int
    let onScoreRecorded: (Int) -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: Spacing.sm) {
                if let number = player.jerseyNumber {
                    Text("#\(number)")
                        .font(.labelLarge)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .leading)
                }
                
                Text(player.name)
                    .font(.bodyLarge)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: {
                onScoreRecorded(2)
            }) {
                Text("+2")
                    .font(.labelLarge)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(Color("StatPurple"))
                    )
            }
            .buttonStyle(.plain)
            
            Text("\(points)")
                .font(.titleMedium)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, Spacing.sm)
    }
}

// FullPlayerRow.swift
struct FullPlayerRow: View {
    let player: PlayerDTO
    let points: Int
    let onScoreRecorded: (Int) -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: Spacing.sm) {
                if let number = player.jerseyNumber {
                    Text("#\(number)")
                        .font(.labelLarge)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .leading)
                }
                
                Text(player.name)
                    .font(.bodyLarge)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            HStack(spacing: Spacing.sm) {
                QuickScoreButton(points: 1, color: Color("StatBlue"), compact: true) {
                    onScoreRecorded(1)
                }
                
                QuickScoreButton(points: 2, color: Color("StatPurple"), compact: true) {
                    onScoreRecorded(2)
                }
                
                QuickScoreButton(points: 3, color: Color("StatGreen"), compact: true) {
                    onScoreRecorded(3)
                }
            }
            
            Text("\(points)")
                .font(.titleMedium)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, Spacing.sm)
    }
}

// QuickScoreButton.swift
struct QuickScoreButton: View {
    let points: Int
    let color: Color
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("+\(points)")
                .font(compact ? .labelMedium : .labelLarge)
                .foregroundColor(.white)
                .frame(width: compact ? 36 : 44, height: compact ? 32 : 40)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(color)
                )
        }
        .buttonStyle(.plain)
    }
}
```

<a name="viewmodel-layer"></a>
## 4.5 ViewModel Layer

### 4.5.1 Live Game ViewModel

```swift
// LiveGameViewModel.swift
import SwiftUI
import Combine

@MainActor
class LiveGameViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var game: GameDTO
    @Published var team: TeamDTO
    @Published var focusPlayer: PlayerDTO
    @Published var teamPlayers: [PlayerDTO]
    @Published var isFocusPlayerActive: Bool = true
    @Published var opponentScore: Int = 0
    @Published var teamScore: Int = 0
    @Published var focusPlayerStats: PlayerStatsDTO
    @Published var canUndo: Bool = false
    
    // MARK: - Private Properties
    
    private var statEvents: [StatEventDTO] = []
    private var undoStack: [UndoAction] = []
    private let maxUndoStackSize = 10
    
    // Repositories
    private let statRepository = StatEventRepository()
    private let gameRepository = GameRepository()
    
    // Auto-save
    private var autoSaveTimer: Timer?
    private let autoSaveInterval: TimeInterval = 30
    
    // MARK: - Initialization
    
    init(game: GameDTO, team: TeamDTO) {
        self.game = game
        self.team = team
        self.opponentScore = game.opponentScore
        
        // Load team players and focus player
        let playerRepo = PlayerRepository()
        do {
            let players = try playerRepo.fetchPlayers(forTeam: team.id)
            self.teamPlayers = players.map { PlayerDTO(from: $0) }
            
            if let focus = players.first(where: { $0.isFocusPlayer }) {
                self.focusPlayer = PlayerDTO(from: focus)
            } else {
                // Fallback to first player
                self.focusPlayer = teamPlayers.first!
            }
            
            self.focusPlayerStats = PlayerStatsDTO(player: focusPlayer, events: [])
            
        } catch {
            fatalError("Failed to load players: \(error)")
        }
        
        loadExistingStats()
        startAutoSave()
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Data Loading
    
    private func loadExistingStats() {
        do {
            let events = try statRepository.fetchStats(forGame: game.id)
            self.statEvents = events.map { StatEventDTO(from: $0) }
            calculateAllStats()
        } catch {
            print("Error loading stats: \(error)")
        }
    }
    
    private func calculateAllStats() {
        teamScore = statEvents
            .filter { $0.statType.isPointType }
            .reduce(0) { $0 + $1.value }
        
        let focusEvents = statEvents.filter { $0.playerId == focusPlayer.id }
        focusPlayerStats = PlayerStatsDTO(player: focusPlayer, events: focusEvents)
        
        canUndo = !undoStack.isEmpty
    }
    
    // MARK: - Stat Recording
    
    func recordFocusPlayerStat(_ statType: StatType) {
        do {
            let event = try statRepository.recordStat(
                playerId: focusPlayer.id,
                gameId: game.id,
                statType: statType
            )
            
            let eventDTO = StatEventDTO(from: event)
            statEvents.append(eventDTO)
            
            addToUndoStack(.statRecorded(event.id))
            calculateAllStats()
        } catch {
            print("Error recording stat: \(error)")
        }
    }
    
    func recordTeamPlayerScore(_ playerId: UUID, points: Int) {
        let statType: StatType
        switch points {
        case 1:
            statType = .freeThrowMade
        case 3:
            statType = .threePointMade
        default:
            statType = .teamPoint
        }
        
        do {
            let event = try statRepository.recordStat(
                playerId: playerId,
                gameId: game.id,
                statType: statType
            )
            
            let eventDTO = StatEventDTO(from: event)
            statEvents.append(eventDTO)
            
            addToUndoStack(.statRecorded(event.id))
            calculateAllStats()
        } catch {
            print("Error recording team score: \(error)")
        }
    }
    
    func recordOpponentScore(_ points: Int) {
        opponentScore += points
        addToUndoStack(.opponentScoreRecorded(points))
        updateGameScore()
    }
    
    // MARK: - Player Status
    
    func toggleFocusPlayerStatus() {
        isFocusPlayerActive.toggle()
    }
    
    // MARK: - Undo Functionality
    
    private func addToUndoStack(_ action: UndoAction) {
        undoStack.append(action)
        
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
        
        canUndo = true
    }
    
    func undoLastAction() {
        guard let lastAction = undoStack.popLast() else { return }
        
        do {
            switch lastAction {
            case .statRecorded(let eventId):
                try statRepository.softDelete(eventId)
                statEvents.removeAll { $0.id == eventId }
                
            case .opponentScoreRecorded(let points):
                opponentScore -= points
            }
            
            calculateAllStats()
            updateGameScore()
        } catch {
            print("Error undoing action: \(error)")
        }
    }
    
    // MARK: - Game Management
    
    private func updateGameScore() {
        do {
            try gameRepository.updateOpponentScore(game.id, score: opponentScore)
        } catch {
            print("Error updating opponent score: \(error)")
        }
    }
    
    func endGame() {
        do {
            try gameRepository.completeGame(game.id)
            autoSaveTimer?.invalidate()
        } catch {
            print("Error ending game: \(error)")
        }
    }
    
    // MARK: - Auto-save
    
    private func startAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(
            withTimeInterval: autoSaveInterval,
            repeats: true
        ) { [weak self] _ in
            self?.saveGameState()
        }
    }
    
    private func saveGameState() {
        CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Helper Methods
    
    func getPlayerPoints(_ playerId: UUID) -> Int {
        return statEvents
            .filter { $0.playerId == playerId && $0.statType.isPointType }
            .reduce(0) { $0 + $1.value }
    }
}

// MARK: - Undo Action

enum UndoAction {
    case statRecorded(UUID)
    case opponentScoreRecorded(Int)
}
```

<a name="use-cases"></a>
## 4.6 Use Cases (Business Logic)

### 4.6.1 Record Stat Use Case

```swift
// RecordStatUseCase.swift
import Foundation

protocol RecordStatUseCaseProtocol {
    func execute(playerId: UUID, 
                 gameId: UUID, 
                 statType: StatType) async throws -> StatEventDTO
}

class RecordStatUseCase: RecordStatUseCaseProtocol {
    private let statRepository: StatEventRepository
    private let validationService: ValidationService
    
    init(statRepository: StatEventRepository = StatEventRepository(),
         validationService: ValidationService = ValidationService()) {
        self.statRepository = statRepository
        self.validationService = validationService
    }
    
    func execute(playerId: UUID, 
                 gameId: UUID, 
                 statType: StatType) async throws -> StatEventDTO {
        // Validate inputs
        try validationService.validateStatRecording(
            playerId: playerId,
            gameId: gameId,
            statType: statType
        )
        
        // Record stat
        let event = try statRepository.recordStat(
            playerId: playerId,
            gameId: gameId,
            statType: statType
        )
        
        return StatEventDTO(from: event)
    }
}
```

### 4.6.2 Create Game Use Case

```swift
// CreateGameUseCase.swift
import Foundation

protocol CreateGameUseCaseProtocol {
    func execute(teamId: UUID,
                 opponentName: String,
                 gameDate: Date,
                 location: String?) async throws -> GameDTO
}

class CreateGameUseCase: CreateGameUseCaseProtocol {
    private let gameRepository: GameRepository
    private let validationService: ValidationService
    
    init(gameRepository: GameRepository = GameRepository(),
         validationService: ValidationService = ValidationService()) {
        self.gameRepository = gameRepository
        self.validationService = validationService
    }
    
    func execute(teamId: UUID,
                 opponentName: String,
                 gameDate: Date,
                 location: String?) async throws -> GameDTO {
        // Validate inputs
        try validationService.validateGameCreation(
            teamId: teamId,
            opponentName: opponentName,
            gameDate: gameDate
        )
        
        // Create game
        let game = try gameRepository.createGame(
            teamId: teamId,
            opponentName: opponentName,
            gameDate: gameDate,
            location: location
        )
        
        return GameDTO(from: game)
    }
}
```

### 4.6.3 Calculate Stats Use Case

```swift
// CalculateStatsUseCase.swift
import Foundation

protocol CalculateStatsUseCaseProtocol {
    func execute(playerId: UUID, gameId: UUID?) async throws -> PlayerStatsDTO
    func executeForSeason(playerId: UUID, seasonId: UUID) async throws -> SeasonStatsDTO
}

class CalculateStatsUseCase: CalculateStatsUseCaseProtocol {
    private let statRepository: StatEventRepository
    private let playerRepository: PlayerRepository
    private let gameRepository: GameRepository
    
    init(statRepository: StatEventRepository = StatEventRepository(),
         playerRepository: PlayerRepository = PlayerRepository(),
         gameRepository: GameRepository = GameRepository()) {
        self.statRepository = statRepository
        self.playerRepository = playerRepository
        self.gameRepository = gameRepository
    }
    
    func execute(playerId: UUID, gameId: UUID?) async throws -> PlayerStatsDTO {
        guard let player = try playerRepository.fetchPlayer(byId: playerId) else {
            throw UseCaseError.invalidInput("Player not found")
        }
        
        let playerDTO = PlayerDTO(from: player)
        
        let events: [StatEvent]
        if let gameId = gameId {
            events = try statRepository.fetchStats(forPlayer: playerId, inGame: gameId)
        } else {
            events = try statRepository.fetchAllStats(forPlayer: playerId)
        }
        
        let eventDTOs = events.map { StatEventDTO(from: $0) }
        return PlayerStatsDTO(player: playerDTO, events: eventDTOs)
    }
    
    func executeForSeason(playerId: UUID, seasonId: UUID) async throws -> SeasonStatsDTO {
        // Implementation for season stats calculation
        fatalError("Not implemented yet")
    }
}

// UseCaseError.swift
enum UseCaseError: LocalizedError {
    case invalidInput(String)
    case businessRuleViolation(String)
    case operationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let msg):
            return "Invalid input: \(msg)"
        case .businessRuleViolation(let msg):
            return msg
        case .operationFailed(let error):
            return error.localizedDescription
        }
    }
}
```

<a name="services"></a>
## 4.7 Services

### 4.7.1 Validation Service

```swift
// ValidationService.swift
import Foundation

class ValidationService {
    func validateStatRecording(playerId: UUID, 
                              gameId: UUID, 
                              statType: StatType) throws {
        // Validate that stat type is appropriate
        if statType == .teamPoint {
            // Team points should only be used for non-focus players
            // This validation would require checking if player is focus player
        }
    }
    
    func validateGameCreation(teamId: UUID,
                            opponentName: String,
                            gameDate: Date) throws {
        guard !opponentName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyOpponentName
        }
        
        // Could add validation for game date not too far in past/future
    }
    
    func validateTeamCreation(name: String, season: String) throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTeamName
        }
        
        guard !season.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptySeason
        }
    }
    
    func validatePlayerCreation(name: String, teamId: UUID) throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyPlayerName
        }
    }
}

enum ValidationError: LocalizedError {
    case emptyOpponentName
    case emptyTeamName
    case emptySeason
    case emptyPlayerName
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .emptyOpponentName:
            return "Opponent name cannot be empty"
        case .emptyTeamName:
            return "Team name cannot be empty"
        case .emptySeason:
            return "Season cannot be empty"
        case .emptyPlayerName:
            return "Player name cannot be empty"
        case .invalidDate:
            return "Invalid date"
        }
    }
}
```

### 4.7.2 Stats Calculation Service

```swift
// StatsCalculationService.swift
import Foundation

class StatsCalculationService {
    func calculateShootingPercentage(made: Int, attempted: Int) -> Double {
        guard attempted > 0 else { return 0.0 }
        return Double(made) / Double(attempted) * 100.0
    }
    
    func calculateFieldGoalStats(events: [StatEventDTO]) -> (made: Int, attempted: Int, percentage: Double) {
        let makes = events.filter { 
            $0.statType == .twoPointMade || $0.statType == .threePointMade 
        }.count
        
        let misses = events.filter {
            $0.statType == .twoPointMiss || $0.statType == .threePointMiss
        }.count
        
        let attempted = makes + misses
        let percentage = calculateShootingPercentage(made: makes, attempted: attempted)
        
        return (makes, attempted, percentage)
    }
    
    func calculatePointsPerGame(games: [GameDTO], playerStats: [PlayerStatsDTO]) -> Double {
        guard !games.isEmpty else { return 0.0 }
        let totalPoints = playerStats.reduce(0) { $0 + $1.points }
        return Double(totalPoints) / Double(games.count)
    }
    
    func calculateAverages(stats: [PlayerStatsDTO]) -> (ppg: Double, rpg: Double, apg: Double) {
        guard !stats.isEmpty else { return (0, 0, 0) }
        
        let count = Double(stats.count)
        let totalPoints = stats.reduce(0) { $0 + $1.points }
        let totalRebounds = stats.reduce(0) { $0 + $1.rebounds }
        let totalAssists = stats.reduce(0) { $0 + $1.assists }
        
        return (
            Double(totalPoints) / count,
            Double(totalRebounds) / count,
            Double(totalAssists) / count
        )
    }
}
```

### 4.7.3 Haptic Feedback Service

```swift
// HapticManager.swift
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// Usage in views
extension View {
    func hapticImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        HapticManager.shared.impact(style)
    }
    
    func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        HapticManager.shared.notification(type)
    }
    
    func hapticSelection() {
        HapticManager.shared.selection()
    }
}
```

---

**End of Section 4 - Application Structure**

This section provides complete coverage of:
- App entry point and lifecycle management
- Navigation architecture with coordinator pattern
- Complete view layer implementation for onboarding, home, games list, and live game
- ViewModel layer with full state management
- Use cases for business logic separation
- Services for validation, calculations, and haptics

The architecture ensures clean separation of concerns, testability, and maintainability while optimizing for the 3-second stat recording requirement.ummaryItem(
                    label: "PTS",
                    value: "\(viewModel.focusPlayerStats.points)"
                )
                
                StatSummaryItem(
                    label: "FG",
                    value: "\(viewModel.focusPlayerStats.fgMade)/\(viewModel.focusPlayerStats.fgAttempted)",
                    percentage: viewModel.focusPlayerStats.fgPercentage
                )
                
                StatSummaryItem(
                    label: "3PT",
                    value: "\(viewModel.focusPlayerStats.threePtMade)/\(viewModel.focusPlayerStats.threePtAttempted)",
                    percentage: viewModel.focusPlayerStats.threePtPercentage
                )
                
                StatS

# Basketball Stats Tracker - Architectural Design Document

## Document Version: 1.0
## Target Platform: iOS 16+
## Language: Swift 5.9+
## Framework: SwiftUI + Combine
## Document Part: Section 5 - Business Logic Layer & Export System

---

# TABLE OF CONTENTS

5. [Business Logic Layer](#business-logic-layer)
   - 5.1 [Use Cases](#use-cases)
   - 5.2 [Services](#services)
   - 5.3 [Validators](#validators)
   - 5.4 [Calculators](#calculators)
6. [Export & Sharing System](#export-sharing-system)
   - 6.1 [Export Architecture](#export-architecture)
   - 6.2 [CSV Export](#csv-export)
   - 6.3 [PDF Export](#pdf-export)
   - 6.4 [Share Sheet Integration](#share-sheet-integration)

---

<a name="business-logic-layer"></a>
# 5. BUSINESS LOGIC LAYER

The business logic layer encapsulates all domain-specific operations, ensuring they are framework-independent and fully testable.

<a name="use-cases"></a>
## 5.1 Use Cases

Use cases represent specific business operations. Each use case should have a single responsibility and be independently testable.

### 5.1.1 Base Use Case Protocol

```swift
// UseCase.swift
import Foundation

protocol UseCase {
    associatedtype Input
    associatedtype Output
    
    func execute(_ input: Input) async throws -> Output
}

// For use cases without input
protocol NoInputUseCase {
    associatedtype Output
    
    func execute() async throws -> Output
}

// For use cases without output (side effects only)
protocol NoOutputUseCase {
    associatedtype Input
    
    func execute(_ input: Input) async throws
}
```

### 5.1.2 Game Management Use Cases

```swift
// CreateGameUseCase.swift
import Foundation

struct CreateGameInput {
    let teamId: UUID
    let opponentName: String
    let gameDate: Date
    let location: String?
    let homeAway: String?
}

class CreateGameUseCase: UseCase {
    typealias Input = CreateGameInput
    typealias Output = GameDTO
    
    private let gameRepository: GameRepository
    private let teamRepository: TeamRepository
    private let validationService: ValidationService
    
    init(gameRepository: GameRepository = GameRepository(),
         teamRepository: TeamRepository = TeamRepository(),
         validationService: ValidationService = ValidationService()) {
        self.gameRepository = gameRepository
        self.teamRepository = teamRepository
        self.validationService = validationService
    }
    
    func execute(_ input: Input) async throws -> GameDTO {
        // Validate team exists
        guard let _ = try teamRepository.fetchTeam(byId: input.teamId) else {
            throw UseCaseError.invalidInput("Team not found")
        }
        
        // Validate inputs
        try validationService.validateGameCreation(
            teamId: input.teamId,
            opponentName: input.opponentName,
            gameDate: input.gameDate
        )
        
        // Create game
        let game = try gameRepository.createGame(
            teamId: input.teamId,
            opponentName: input.opponentName,
            gameDate: input.gameDate,
            location: input.location,
            homeAway: input.homeAway
        )
        
        return GameDTO(from: game)
    }
}

// EndGameUseCase.swift
struct EndGameInput {
    let gameId: UUID
    let duration: Int?
    let notes: String?
}

class EndGameUseCase: NoOutputUseCase {
    typealias Input = EndGameInput
    
    private let gameRepository: GameRepository
    private let statRepository: StatEventRepository
    
    init(gameRepository: GameRepository = GameRepository(),
         statRepository: StatEventRepository = StatEventRepository()) {
        self.gameRepository = gameRepository
        self.statRepository = statRepository
    }
    
    func execute(_ input: Input) async throws {
        // Verify game exists and is not already complete
        guard let game = try gameRepository.fetchGame(byId: input.gameId) else {
            throw UseCaseError.invalidInput("Game not found")
        }
        
        guard !game.isComplete else {
            throw UseCaseError.businessRuleViolation("Game is already complete")
        }
        
        // Complete the game
        try gameRepository.completeGame(
            input.gameId,
            duration: input.duration,
            notes: input.notes
        )
    }
}

// DeleteGameUseCase.swift
class DeleteGameUseCase: NoOutputUseCase {
    typealias Input = UUID
    
    private let gameRepository: GameRepository
    private let statRepository: StatEventRepository
    
    init(gameRepository: GameRepository = GameRepository(),
         statRepository: StatEventRepository = StatEventRepository()) {
        self.gameRepository = gameRepository
        self.statRepository = statRepository
    }
    
    func execute(_ input: UUID) async throws {
        // Verify game exists
        guard let _ = try gameRepository.fetchGame(byId: input) else {
            throw UseCaseError.invalidInput("Game not found")
        }
        
        // Delete game (cascade will delete stats)
        try gameRepository.deleteGame(input)
    }
}
```

### 5.1.3 Stat Recording Use Cases

```swift
// RecordStatUseCase.swift
import Foundation

struct RecordStatInput {
    let playerId: UUID
    let gameId: UUID
    let statType: StatType
    let period: Int?
    let gameTime: String?
    let courtX: Float?
    let courtY: Float?
}

class RecordStatUseCase: UseCase {
    typealias Input = RecordStatInput
    typealias Output = StatEventDTO
    
    private let statRepository: StatEventRepository
    private let playerRepository: PlayerRepository
    private let gameRepository: GameRepository
    private let validationService: ValidationService
    
    init(statRepository: StatEventRepository = StatEventRepository(),
         playerRepository: PlayerRepository = PlayerRepository(),
         gameRepository: GameRepository = GameRepository(),
         validationService: ValidationService = ValidationService()) {
        self.statRepository = statRepository
        self.playerRepository = playerRepository
        self.gameRepository = gameRepository
        self.validationService = validationService
    }
    
    func execute(_ input: Input) async throws -> StatEventDTO {
        // Validate player exists
        guard let _ = try playerRepository.fetchPlayer(byId: input.playerId) else {
            throw UseCaseError.invalidInput("Player not found")
        }
        
        // Validate game exists and is in progress
        guard let game = try gameRepository.fetchGame(byId: input.gameId) else {
            throw UseCaseError.invalidInput("Game not found")
        }
        
        guard !game.isComplete else {
            throw UseCaseError.businessRuleViolation("Cannot add stats to completed game")
        }
        
        // Record stat
        let event = try statRepository.recordStat(
            playerId: input.playerId,
            gameId: input.gameId,
            statType: input.statType,
            period: input.period,
            gameTime: input.gameTime,
            courtX: input.courtX,
            courtY: input.courtY
        )
        
        return StatEventDTO(from: event)
    }
}

// UndoStatUseCase.swift
class UndoStatUseCase: NoOutputUseCase {
    typealias Input = UUID
    
    private let statRepository: StatEventRepository
    
    init(statRepository: StatEventRepository = StatEventRepository()) {
        self.statRepository = statRepository
    }
    
    func execute(_ input: UUID) async throws {
        // Soft delete the stat
        try statRepository.softDelete(input)
    }
}

// DeleteStatPermanentlyUseCase.swift
class DeleteStatPermanentlyUseCase: NoOutputUseCase {
    typealias Input = UUID
    
    private let statRepository: StatEventRepository
    
    init(statRepository: StatEventRepository = StatEventRepository()) {
        self.statRepository = statRepository
    }
    
    func execute(_ input: UUID) async throws {
        try statRepository.permanentlyDelete(input)
    }
}
```

### 5.1.4 Player Management Use Cases

```swift
// CreatePlayerUseCase.swift
import Foundation

struct CreatePlayerInput {
    let name: String
    let teamId: UUID
    let jerseyNumber: String?
    let isFocusPlayer: Bool
    let position: PlayerPosition?
}

class CreatePlayerUseCase: UseCase {
    typealias Input = CreatePlayerInput
    typealias Output = PlayerDTO
    
    private let playerRepository: PlayerRepository
    private let teamRepository: TeamRepository
    private let validationService: ValidationService
    
    init(playerRepository: PlayerRepository = PlayerRepository(),
         teamRepository: TeamRepository = TeamRepository(),
         validationService: ValidationService = ValidationService()) {
        self.playerRepository = playerRepository
        self.teamRepository = teamRepository
        self.validationService = validationService
    }
    
    func execute(_ input: Input) async throws -> PlayerDTO {
        // Validate team exists
        guard let _ = try teamRepository.fetchTeam(byId: input.teamId) else {
            throw UseCaseError.invalidInput("Team not found")
        }
        
        // Validate player name
        try validationService.validatePlayerCreation(
            name: input.name,
            teamId: input.teamId
        )
        
        // If setting as focus player, remove focus from others
        if input.isFocusPlayer {
            let existingPlayers = try playerRepository.fetchPlayers(forTeam: input.teamId)
            for player in existingPlayers where player.isFocusPlayer {
                player.isFocusPlayer = false
            }
            try playerRepository.save()
        }
        
        // Create player
        let player = try playerRepository.createPlayer(
            name: input.name,
            teamId: input.teamId,
            jerseyNumber: input.jerseyNumber,
            isFocusPlayer: input.isFocusPlayer,
            position: input.position
        )
        
        return PlayerDTO(from: player)
    }
}

// UpdatePlayerUseCase.swift
struct UpdatePlayerInput {
    let playerId: UUID
    let name: String?
    let jerseyNumber: String?
    let position: PlayerPosition?
    let photoData: Data?
}

class UpdatePlayerUseCase: NoOutputUseCase {
    typealias Input = UpdatePlayerInput
    
    private let playerRepository: PlayerRepository
    private let validationService: ValidationService
    
    init(playerRepository: PlayerRepository = PlayerRepository(),
         validationService: ValidationService = ValidationService()) {
        self.playerRepository = playerRepository
        self.validationService = validationService
    }
    
    func execute(_ input: Input) async throws {
        guard let player = try playerRepository.fetchPlayer(byId: input.playerId) else {
            throw UseCaseError.invalidInput("Player not found")
        }
        
        try playerRepository.updatePlayer(
            player,
            name: input.name,
            jerseyNumber: input.jerseyNumber,
            position: input.position,
            photoData: input.photoData
        )
    }
}

// SetFocusPlayerUseCase.swift
struct SetFocusPlayerInput {
    let playerId: UUID
    let teamId: UUID
}

class SetFocusPlayerUseCase: NoOutputUseCase {
    typealias Input = SetFocusPlayerInput
    
    private let playerRepository: PlayerRepository
    
    init(playerRepository: PlayerRepository = PlayerRepository()) {
        self.playerRepository = playerRepository
    }
    
    func execute(_ input: Input) async throws {
        try playerRepository.setFocusPlayer(input.playerId, forTeam: input.teamId)
    }
}
```

### 5.1.5 Statistics Calculation Use Cases

```swift
// CalculatePlayerStatsUseCase.swift
import Foundation

struct CalculatePlayerStatsInput {
    let playerId: UUID
    let gameId: UUID?
    let dateRange: ClosedRange<Date>?
}

class CalculatePlayerStatsUseCase: UseCase {
    typealias Input = CalculatePlayerStatsInput
    typealias Output = PlayerStatsDTO
    
    private let statRepository: StatEventRepository
    private let playerRepository: PlayerRepository
    
    init(statRepository: StatEventRepository = StatEventRepository(),
         playerRepository: PlayerRepository = PlayerRepository()) {
        self.statRepository = statRepository
        self.playerRepository = playerRepository
    }
    
    func execute(_ input: Input) async throws -> PlayerStatsDTO {
        guard let player = try playerRepository.fetchPlayer(byId: input.playerId) else {
            throw UseCaseError.invalidInput("Player not found")
        }
        
        let playerDTO = PlayerDTO(from: player)
        
        let events: [StatEvent]
        if let gameId = input.gameId {
            events = try statRepository.fetchStats(forPlayer: input.playerId, inGame: gameId)
        } else if let dateRange = input.dateRange {
            events = try statRepository.fetchStats(
                forPlayer: input.playerId,
                dateRange: dateRange
            )
        } else {
            events = try statRepository.fetchAllStats(forPlayer: input.playerId)
        }
        
        let eventDTOs = events.map { StatEventDTO(from: $0) }
        return PlayerStatsDTO(player: playerDTO, events: eventDTOs)
    }
}

// CalculateSeasonStatsUseCase.swift
struct CalculateSeasonStatsInput {
    let teamId: UUID
    let seasonName: String
}

class CalculateSeasonStatsUseCase: UseCase {
    typealias Input = CalculateSeasonStatsInput
    typealias Output = SeasonStatsDTO
    
    private let gameRepository: GameRepository
    private let playerRepository: PlayerRepository
    private let statRepository: StatEventRepository
    
    init(gameRepository: GameRepository = GameRepository(),
         playerRepository: PlayerRepository = PlayerRepository(),
         statRepository: StatEventRepository = StatEventRepository()) {
        self.gameRepository = gameRepository
        self.playerRepository = playerRepository
        self.statRepository = statRepository
    }
    
    func execute(_ input: Input) async throws -> SeasonStatsDTO {
        // Get all completed games for the season
        let allGames = try gameRepository.fetchGames(forTeam: input.teamId)
        let games = allGames.filter { $0.isComplete }.map { GameDTO(from: $0) }
        
        // Get focus player
        guard let focusPlayer = try playerRepository.fetchFocusPlayer(forTeam: input.teamId) else {
            throw UseCaseError.invalidInput("No focus player found")
        }
        
        // Calculate stats for each game
        var playerStats: [PlayerStatsDTO] = []
        for game in games {
            let events = try statRepository.fetchStats(forPlayer: focusPlayer.id, inGame: game.id)
            let eventDTOs = events.map { StatEventDTO(from: $0) }
            let stats = PlayerStatsDTO(player: PlayerDTO(from: focusPlayer), events: eventDTOs)
            playerStats.append(stats)
        }
        
        return SeasonStatsDTO(
            seasonName: input.seasonName,
            games: games,
            playerStats: playerStats
        )
    }
}

// CalculateTeamStatsUseCase.swift
struct CalculateTeamStatsInput {
    let teamId: UUID
    let gameId: UUID?
}

struct TeamStatsDTO {
    let totalPoints: Int
    let gamesPlayed: Int
    let wins: Int
    let losses: Int
    let ties: Int
    let averagePointsScored: Double
    let averagePointsAllowed: Double
    let playerStats: [PlayerStatsDTO]
}

class CalculateTeamStatsUseCase: UseCase {
    typealias Input = CalculateTeamStatsInput
    typealias Output = TeamStatsDTO
    
    private let gameRepository: GameRepository
    private let playerRepository: PlayerRepository
    private let statRepository: StatEventRepository
    
    init(gameRepository: GameRepository = GameRepository(),
         playerRepository: PlayerRepository = PlayerRepository(),
         statRepository: StatEventRepository = StatEventRepository()) {
        self.gameRepository = gameRepository
        self.playerRepository = playerRepository
        self.statRepository = statRepository
    }
    
    func execute(_ input: Input) async throws -> TeamStatsDTO {
        let games: [Game]
        if let gameId = input.gameId {
            guard let game = try gameRepository.fetchGame(byId: gameId) else {
                throw UseCaseError.invalidInput("Game not found")
            }
            games = [game]
        } else {
            games = try gameRepository.fetchCompletedGames(forTeam: input.teamId)
        }
        
        let players = try playerRepository.fetchPlayers(forTeam: input.teamId)
        
        var playerStats: [PlayerStatsDTO] = []
        for player in players {
            let allEvents = games.flatMap { game in
                (try? statRepository.fetchStats(forPlayer: player.id, inGame: game.id)) ?? []
            }
            let eventDTOs = allEvents.map { StatEventDTO(from: $0) }
            let stats = PlayerStatsDTO(player: PlayerDTO(from: player), events: eventDTOs)
            playerStats.append(stats)
        }
        
        let totalPoints = games.reduce(0) { $0 + Int($1.teamScore) }
        let totalOpponentPoints = games.reduce(0) { $0 + Int($1.opponentScore) }
        
        let wins = games.filter { $0.result == .win }.count
        let losses = games.filter { $0.result == .loss }.count
        let ties = games.filter { $0.result == .tie }.count
        
        let avgScored = games.isEmpty ? 0.0 : Double(totalPoints) / Double(games.count)
        let avgAllowed = games.isEmpty ? 0.0 : Double(totalOpponentPoints) / Double(games.count)
        
        return TeamStatsDTO(
            totalPoints: totalPoints,
            gamesPlayed: games.count,
            wins: wins,
            losses: losses,
            ties: ties,
            averagePointsScored: avgScored,
            averagePointsAllowed: avgAllowed,
            playerStats: playerStats
        )
    }
}
```

<a name="services"></a>
## 5.2 Services

Services encapsulate reusable business logic that doesn't fit into a single use case.

### 5.2.1 Stats Calculation Service

```swift
// StatsCalculationService.swift
import Foundation

class StatsCalculationService {
    
    // MARK: - Shooting Percentages
    
    func calculateShootingPercentage(made: Int, attempted: Int) -> Double {
        guard attempted > 0 else { return 0.0 }
        return Double(made) / Double(attempted) * 100.0
    }
    
    func calculateFieldGoalStats(events: [StatEventDTO]) -> (made: Int, attempted: Int, percentage: Double) {
        let makes = events.filter {
            $0.statType == .twoPointMade || $0.statType == .threePointMade
        }.count
        
        let misses = events.filter {
            $0.statType == .twoPointMiss || $0.statType == .threePointMiss
        }.count
        
        let attempted = makes + misses
        let percentage = calculateShootingPercentage(made: makes, attempted: attempted)
        
        return (makes, attempted, percentage)
    }
    
    func calculateThreePointStats(events: [StatEventDTO]) -> (made: Int, attempted: Int, percentage: Double) {
        let makes = events.filter { $0.statType == .threePointMade }.count
        let misses = events.filter { $0.statType == .threePointMiss }.count
        let attempted = makes + misses
        let percentage = calculateShootingPercentage(made: makes, attempted: attempted)
        
        return (makes, attempted, percentage)
    }
    
    func calculateFreeThrowStats(events: [StatEventDTO]) -> (made: Int, attempted: Int, percentage: Double) {
        let makes = events.filter { $0.statType == .freeThrowMade }.count
        let misses = events.filter { $0.statType == .freeThrowMiss }.count
        let attempted = makes + misses
        let percentage = calculateShootingPercentage(made: makes, attempted: attempted)
        
        return (makes, attempted, percentage)
    }
    
    // MARK: - Averages
    
    func calculatePointsPerGame(stats: [PlayerStatsDTO]) -> Double {
        guard !stats.isEmpty else { return 0.0 }
        let totalPoints = stats.reduce(0) { $0 + $1.points }
        return Double(totalPoints) / Double(stats.count)
    }
    
    func calculateReboundsPerGame(stats: [PlayerStatsDTO]) -> Double {
        guard !stats.isEmpty else { return 0.0 }
        let totalRebounds = stats.reduce(0) { $0 + $1.rebounds }
        return Double(totalRebounds) / Double(stats.count)
    }
    
    func calculateAssistsPerGame(stats: [PlayerStatsDTO]) -> Double {
        guard !stats.isEmpty else { return 0.0 }
        let totalAssists = stats.reduce(0) { $0 + $1.assists }
        return Double(totalAssists) / Double(stats.count)
    }
    
    func calculateAverages(stats: [PlayerStatsDTO]) -> (ppg: Double, rpg: Double, apg: Double, spg: Double, bpg: Double) {
        guard !stats.isEmpty else { return (0, 0, 0, 0, 0) }
        
        let count = Double(stats.count)
        let totalPoints = stats.reduce(0) { $0 + $1.points }
        let totalRebounds = stats.reduce(0) { $0 + $1.rebounds }
        let totalAssists = stats.reduce(0) { $0 + $1.assists }
        let totalSteals = stats.reduce(0) { $0 + $1.steals }
        let totalBlocks = stats.reduce(0) { $0 + $1.blocks }
        
        return (
            Double(totalPoints) / count,
            Double(totalRebounds) / count,
            Double(totalAssists) / count,
            Double(totalSteals) / count,
            Double(totalBlocks) / count
        )
    }
    
    // MARK: - Advanced Stats
    
    func calculateEffectiveFieldGoalPercentage(events: [StatEventDTO]) -> Double {
        let twoMade = events.filter { $0.statType == .twoPointMade }.count
        let threeMade = events.filter { $0.statType == .threePointMade }.count
        let totalAttempted = events.filter { $0.statType.isShot }.count
        
        guard totalAttempted > 0 else { return 0.0 }
        
        let effectiveMakes = Double(twoMade) + (Double(threeMade) * 1.5)
        return (effectiveMades / Double(totalAttempted)) * 100.0
    }
    
    func calculateTrueShootingPercentage(events: [StatEventDTO]) -> Double {
        let points = events.filter { $0.statType.isPointType }.reduce(0) { $0 + $1.value }
        
        let fga = events.filter {
            $0.statType == .twoPointMade || $0.statType == .twoPointMiss ||
            $0.statType == .threePointMade || $0.statType == .threePointMiss
        }.count
        
        let fta = events.filter {
            $0.statType == .freeThrowMade || $0.statType == .freeThrowMiss
        }.count
        
        let denominator = 2 * (Double(fga) + 0.44 * Double(fta))
        guard denominator > 0 else { return 0.0 }
        
        return (Double(points) / denominator) * 100.0
    }
    
    // MARK: - Trends
    
    func calculateTrend(stats: [PlayerStatsDTO], metric: StatsMetric) -> TrendDirection {
        guard stats.count >= 3 else { return .stable }
        
        let recentGames = stats.suffix(3)
        let earlierGames = stats.prefix(max(stats.count - 3, 3))
        
        let recentAvg = calculateMetricAverage(stats: Array(recentGames), metric: metric)
        let earlierAvg = calculateMetricAverage(stats: Array(earlierGames), metric: metric)
        
        let difference = recentAvg - earlierAvg
        let threshold = 0.1 // 10% change
        
        if difference > threshold * earlierAvg {
            return .improving
        } else if difference < -threshold * earlierAvg {
            return .declining
        } else {
            return .stable
        }
    }
    
    private func calculateMetricAverage(stats: [PlayerStatsDTO], metric: StatsMetric) -> Double {
        guard !stats.isEmpty else { return 0.0 }
        
        let total = stats.reduce(0.0) { result, stat in
            result + metric.value(from: stat)
        }
        
        return total / Double(stats.count)
    }
}

enum StatsMetric {
    case points
    case rebounds
    case assists
    case steals
    case blocks
    case fieldGoalPercentage
    case threePointPercentage
    
    func value(from stats: PlayerStatsDTO) -> Double {
        switch self {
        case .points: return Double(stats.points)
        case .rebounds: return Double(stats.rebounds)
        case .assists: return Double(stats.assists)
        case .steals: return Double(stats.steals)
        case .blocks: return Double(stats.blocks)
        case .fieldGoalPercentage: return stats.fgPercentage
        case .threePointPercentage: return stats.threePtPercentage
        }
    }
}

enum TrendDirection {
    case improving
    case declining
    case stable
    
    var displayName: String {
        switch self {
        case .improving: return "↗ Improving"
        case .declining: return "↘ Declining"
        case .stable: return "→ Stable"
        }
    }
    
    var color: String {
        switch self {
        case .improving: return "StatGreen"
        case .declining: return "StatRed"
        case .stable: return "StatBlue"
        }
    }
}
```

### 5.2.2 Game Timer Service

```swift
// GameTimerService.swift
import Foundation
import Combine

class GameTimerService: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }
    
    func pause() {
        guard isRunning else { return }
        
        isRunning = false
        pausedTime = elapsedTime
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        start()
    }
    
    func stop() -> TimeInterval {
        pause()
        let finalTime = elapsedTime
        reset()
        return finalTime
    }
    
    func reset() {
        isRunning = false
        elapsedTime = 0
        pausedTime = 0
        startTime = nil
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = pausedTime + Date().timeIntervalSince(startTime)
    }
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
```

### 5.2.3 Data Synchronization Service

```swift
// DataSyncService.swift
import Foundation
import CloudKit

class DataSyncService {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.yourdomain.basketballstats")
        self.privateDatabase = container.privateCloudDatabase
    }
    
    func syncEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
    }
    
    func enableSync() {
        UserDefaults.standard.set(true, forKey: "cloudSyncEnabled")
    }
    
    func disableSync() {
        UserDefaults.standard.set(false, forKey: "cloudSyncEnabled")
    }
    
    // Check iCloud availability
    func checkiCloudStatus() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            container.accountStatus { status, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: status == .available)
            }
        }
    }
    
    // Note: Actual sync is handled by NSPersistentCloudKitContainer
    // This service provides UI controls and status checking
}
```

# Basketball Stats Tracker - Architectural Design Document

## Document Version: 1.0
## Target Platform: iOS 16+
## Language: Swift 5.9+
## Framework: SwiftUI + Combine
## Document Part: Section 5.3-6 - Validators, Calculators & Export System

---

# TABLE OF CONTENTS

5.3 [Validators](#validators)
5.4 [Calculators](#calculators)
6. [Export & Sharing System](#export-sharing-system)
   - 6.1 [Export Architecture](#export-architecture)
   - 6.2 [CSV Export](#csv-export)
   - 6.3 [PDF Export](#pdf-export)
   - 6.4 [Share Sheet Integration](#share-sheet-integration)

---

<a name="validators"></a>
## 5.3 Validators (Continued)

### 5.3.1 Complete Validation Service

```swift
// ValidationService.swift
import Foundation

class ValidationService {
    
    // MARK: - Game Validation
    
    func validateGameCreation(teamId: UUID,
                            opponentName: String,
                            gameDate: Date) throws {
        guard !opponentName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyOpponentName
        }
        
        // Validate date is not too far in the future (1 year)
        let oneYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        guard gameDate <= oneYearFromNow else {
            throw ValidationError.invalidDate
        }
    }
    
    // MARK: - Player Validation
    
    func validatePlayerCreation(name: String, teamId: UUID) throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyPlayerName
        }
        
        guard name.count <= 50 else {
            throw ValidationError.nameTooLong
        }
    }
    
    func validateJerseyNumber(_ number: String?) throws {
        guard let number = number, !number.isEmpty else {
            return // Jersey number is optional
        }
        
        guard number.count <= 3 else {
            throw ValidationError.invalidJerseyNumber
        }
        
        // Allow only digits
        guard number.allSatisfy({ $0.isNumber }) else {
            throw ValidationError.invalidJerseyNumber
        }
    }
    
    // MARK: - Team Validation
    
    func validateTeamCreation(name: String, season: String) throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTeamName
        }
        
        guard !season.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptySeason
        }
        
        guard name.count <= 50 else {
            throw ValidationError.nameTooLong
        }
        
        guard season.count <= 30 else {
            throw ValidationError.seasonNameTooLong
        }
    }
    
    // MARK: - Stat Recording Validation
    
    func validateStatRecording(playerId: UUID, 
                              gameId: UUID, 
                              statType: StatType) throws {
        // Additional validation rules can be added here
        // For example, validate that certain stats make sense together
    }
    
    // MARK: - Data Integrity Validation
    
    func validateGameData(game: GameDTO) throws {
        guard game.opponentScore >= 0 else {
            throw ValidationError.negativeScore
        }
        
        guard game.teamScore >= 0 else {
            throw ValidationError.negativeScore
        }
    }
    
    func validatePlayerStats(stats: PlayerStatsDTO) throws {
        // Validate shooting percentages are in valid range
        guard stats.fgPercentage >= 0 && stats.fgPercentage <= 100 else {
            throw ValidationError.invalidPercentage
        }
        
        guard stats.threePtPercentage >= 0 && stats.threePtPercentage <= 100 else {
            throw ValidationError.invalidPercentage
        }
        
        guard stats.ftPercentage >= 0 && stats.ftPercentage <= 100 else {
            throw ValidationError.invalidPercentage
        }
        
        // Validate makes don't exceed attempts
        guard stats.fgMade <= stats.fgAttempted else {
            throw ValidationError.invalidStats
        }
        
        guard stats.threePtMade <= stats.threePtAttempted else {
            throw ValidationError.invalidStats
        }
        
        guard stats.ftMade <= stats.ftAttempted else {
            throw ValidationError.invalidStats
        }
    }
    
    // MARK: - Business Rule Validation
    
    func validateMaxPlayersPerTeam(_ teamId: UUID, currentCount: Int) throws {
        let maxPlayers = 15 // Youth basketball typical roster limit
        guard currentCount < maxPlayers else {
            throw ValidationError.tooManyPlayers
        }
    }
}

enum ValidationError: LocalizedError {
    case emptyOpponentName
    case emptyTeamName
    case emptySeason
    case emptyPlayerName
    case invalidDate
    case nameTooLong
    case seasonNameTooLong
    case invalidJerseyNumber
    case negativeScore
    case invalidPercentage
    case invalidStats
    case tooManyPlayers
    
    var errorDescription: String? {
        switch self {
        case .emptyOpponentName:
            return "Opponent name cannot be empty"
        case .emptyTeamName:
            return "Team name cannot be empty"
        case .emptySeason:
            return "Season cannot be empty"
        case .emptyPlayerName:
            return "Player name cannot be empty"
        case .invalidDate:
            return "Game date cannot be more than one year in the future"
        case .nameTooLong:
            return "Name cannot exceed 50 characters"
        case .seasonNameTooLong:
            return "Season name cannot exceed 30 characters"
        case .invalidJerseyNumber:
            return "Jersey number must be 1-3 digits"
        case .negativeScore:
            return "Score cannot be negative"
        case .invalidPercentage:
            return "Percentage must be between 0 and 100"
        case .invalidStats:
            return "Makes cannot exceed attempts"
        case .tooManyPlayers:
            return "Maximum roster size (15 players) reached"
        }
    }
}
```

<a name="calculators"></a>
## 5.4 Calculators

### 5.4.1 Advanced Stats Calculator

```swift
// StatsCalculator.swift
import Foundation

class StatsCalculator {
    
    // MARK: - Player Efficiency Rating (PER)
    
    /// Simplified PER calculation for youth basketball
    func calculatePlayerEfficiencyRating(stats: PlayerStatsDTO) -> Double {
        let points = Double(stats.points)
        let rebounds = Double(stats.rebounds)
        let assists = Double(stats.assists)
        let steals = Double(stats.steals)
        let blocks = Double(stats.blocks)
        let turnovers = Double(stats.turnovers)
        let fga = Double(stats.fgAttempted)
        let fta = Double(stats.ftAttempted)
        let fgm = Double(stats.fgMade)
        let ftm = Double(stats.ftMade)
        
        // Simplified formula: (PTS + REB + AST + STL + BLK - TO - (FGA - FGM) - (FTA - FTM))
        let per = points + rebounds + assists + steals + blocks - turnovers - (fga - fgm) - (fta - ftm)
        
        return max(0, per)
    }
    
    // MARK: - Game Score
    
    /// Calculate game score (similar to NBA's game score metric)
    func calculateGameScore(stats: PlayerStatsDTO) -> Double {
        let pts = Double(stats.points)
        let fgm = Double(stats.fgMade)
        let fga = Double(stats.fgAttempted)
        let ftm = Double(stats.ftMade)
        let fta = Double(stats.ftAttempted)
        let reb = Double(stats.rebounds)
        let ast = Double(stats.assists)
        let stl = Double(stats.steals)
        let blk = Double(stats.blocks)
        let to = Double(stats.turnovers)
        let pf = Double(stats.fouls)
        
        let gameScore = pts + 0.4 * fgm - 0.7 * fga - 0.4 * (fta - ftm) + 0.7 * reb + 
                       0.7 * ast + stl + 0.7 * blk - 0.4 * pf - to
        
        return gameScore
    }
    
    // MARK: - Consistency Score
    
    /// Calculate how consistent a player's performance is
    func calculateConsistencyScore(games: [PlayerStatsDTO], metric: StatsMetric) -> Double {
        guard games.count > 1 else { return 100.0 }
        
        let values = games.map { metric.value(from: $0) }
        let average = values.reduce(0, +) / Double(values.count)
        
        guard average > 0 else { return 100.0 }
        
        // Calculate coefficient of variation (lower is more consistent)
        let variance = values.reduce(0) { $0 + pow($1 - average, 2) } / Double(values.count)
        let standardDeviation = sqrt(variance)
        let coefficientOfVariation = (standardDeviation / average) * 100.0
        
        // Convert to consistency score (0-100, higher is better)
        let consistencyScore = max(0, 100 - coefficientOfVariation)
        
        return consistencyScore
    }
    
    // MARK: - Hot Hand Detection
    
    /// Detect if player is on a hot streak
    func isOnHotStreak(recentGames: [PlayerStatsDTO], metric: StatsMetric, threshold: Double = 1.2) -> Bool {
        guard recentGames.count >= 3 else { return false }
        
        let last3 = recentGames.suffix(3)
        let previous = recentGames.dropLast(3)
        
        guard !previous.isEmpty else { return false }
        
        let recentAvg = last3.reduce(0.0) { $0 + metric.value(from: $1) } / Double(last3.count)
        let previousAvg = previous.reduce(0.0) { $0 + metric.value(from: $1) } / Double(previous.count)
        
        guard previousAvg > 0 else { return false }
        
        return recentAvg >= previousAvg * threshold
    }
    
    // MARK: - Milestone Detection
    
    struct Milestone {
        let description: String
        let achieved: Bool
        let progress: Double
        let icon: String
    }
    
    func checkMilestones(stats: PlayerStatsDTO) -> [Milestone] {
        var milestones: [Milestone] = []
        
        // Points milestones
        milestones.append(Milestone(
            description: "Score 10+ points",
            achieved: stats.points >= 10,
            progress: min(1.0, Double(stats.points) / 10.0),
            icon: "10.circle.fill"
        ))
        
        milestones.append(Milestone(
            description: "Score 20+ points",
            achieved: stats.points >= 20,
            progress: min(1.0, Double(stats.points) / 20.0),
            icon: "20.circle.fill"
        ))
        
        // Double-double (10+ in two categories)
        let doubleDigitCategories = [
            stats.points >= 10,
            stats.rebounds >= 10,
            stats.assists >= 10,
            stats.steals >= 10,
            stats.blocks >= 10
        ].filter { $0 }.count
        
        milestones.append(Milestone(
            description: "Double-Double",
            achieved: doubleDigitCategories >= 2,
            progress: Double(doubleDigitCategories) / 2.0,
            icon: "star.fill"
        ))
        
        // Triple-double
        milestones.append(Milestone(
            description: "Triple-Double",
            achieved: doubleDigitCategories >= 3,
            progress: Double(doubleDigitCategories) / 3.0,
            icon: "star.circle.fill"
        ))
        
        // Perfect shooting
        if stats.fgAttempted > 0 {
            milestones.append(Milestone(
                description: "Perfect FG%",
                achieved: stats.fgPercentage == 100.0,
                progress: stats.fgPercentage / 100.0,
                icon: "target"
            ))
        }
        
        return milestones
    }
    
    // MARK: - Career Highs
    
    func findCareerHighs(allGames: [PlayerStatsDTO]) -> CareerHighs {
        guard !allGames.isEmpty else {
            return CareerHighs()
        }
        
        let maxPoints = allGames.max { $0.points < $1.points }
        let maxRebounds = allGames.max { $0.rebounds < $1.rebounds }
        let maxAssists = allGames.max { $0.assists < $1.assists }
        let maxSteals = allGames.max { $0.steals < $1.steals }
        let maxBlocks = allGames.max { $0.blocks < $1.blocks }
        
        return CareerHighs(
            points: maxPoints?.points ?? 0,
            rebounds: maxRebounds?.rebounds ?? 0,
            assists: maxAssists?.assists ?? 0,
            steals: maxSteals?.steals ?? 0,
            blocks: maxBlocks?.blocks ?? 0
        )
    }
}

struct CareerHighs {
    let points: Int
    let rebounds: Int
    let assists: Int
    let steals: Int
    let blocks: Int
    
    init(points: Int = 0, rebounds: Int = 0, assists: Int = 0, steals: Int = 0, blocks: Int = 0) {
        self.points = points
        self.rebounds = rebounds
        self.assists = assists
        self.steals = steals
        self.blocks = blocks
    }
}
```

### 5.4.2 Percentile Calculator

```swift
// PercentileCalculator.swift
import Foundation

class PercentileCalculator {
    
    /// Calculate what percentile a value falls into
    func calculatePercentile(value: Double, in dataset: [Double]) -> Double {
        guard !dataset.isEmpty else { return 0.0 }
        
        let sorted = dataset.sorted()
        let count = sorted.filter { $0 < value }.count
        
        return (Double(count) / Double(sorted.count)) * 100.0
    }
    
    /// Compare player against league/team averages
    func compareToAverage(playerValue: Double, averageValue: Double) -> ComparisonResult {
        guard averageValue > 0 else { return .average }
        
        let difference = ((playerValue - averageValue) / averageValue) * 100.0
        
        if difference > 20 {
            return .wellAbove
        } else if difference > 5 {
            return .above
        } else if difference < -20 {
            return .wellBelow
        } else if difference < -5 {
            return .below
        } else {
            return .average
        }
    }
}

enum ComparisonResult {
    case wellAbove
    case above
    case average
    case below
    case wellBelow
    
    var displayName: String {
        switch self {
        case .wellAbove: return "Well Above Average"
        case .above: return "Above Average"
        case .average: return "Average"
        case .below: return "Below Average"
        case .wellBelow: return "Well Below Average"
        }
    }
    
    var emoji: String {
        switch self {
        case .wellAbove: return "🔥"
        case .above: return "⬆️"
        case .average: return "➡️"
        case .below: return "⬇️"
        case .wellBelow: return "❄️"
        }
    }
    
    var color: String {
        switch self {
        case .wellAbove: return "StatGreen"
        case .above: return "StatBlue"
        case .average: return "SecondaryText"
        case .below: return "StatOrange"
        case .wellBelow: return "StatRed"
        }
    }
}
```

---

<a name="export-sharing-system"></a>
# 6. EXPORT & SHARING SYSTEM

<a name="export-architecture"></a>
## 6.1 Export Architecture

### 6.1.1 Export Manager

```swift
// ExportManager.swift
import Foundation

enum ExportFormat {
    case csv
    case pdf
}

enum ExportScope {
    case singleGame(UUID)
    case season(String, UUID)
    case lifetime(UUID)
}

protocol ExportService {
    func export(scope: ExportScope, format: ExportFormat) async throws -> URL
}

class ExportManager: ExportService {
    private let csvExporter: CSVExporter
    private let pdfExporter: PDFExporter
    private let gameRepository: GameRepository
    private let playerRepository: PlayerRepository
    private let statRepository: StatEventRepository
    
    init(csvExporter: CSVExporter = CSVExporter(),
         pdfExporter: PDFExporter = PDFExporter(),
         gameRepository: GameRepository = GameRepository(),
         playerRepository: PlayerRepository = PlayerRepository(),
         statRepository: StatEventRepository = StatEventRepository()) {
        self.csvExporter = csvExporter
        self.pdfExporter = pdfExporter
        self.gameRepository = gameRepository
        self.playerRepository = playerRepository
        self.statRepository = statRepository
    }
    
    func export(scope: ExportScope, format: ExportFormat) async throws -> URL {
        let data = try await prepareData(for: scope)
        
        switch format {
        case .csv:
            return try csvExporter.export(data: data)
        case .pdf:
            return try pdfExporter.export(data: data)
        }
    }
    
    private func prepareData(for scope: ExportScope) async throws -> ExportData {
        switch scope {
        case .singleGame(let gameId):
            return try await prepareSingleGameData(gameId: gameId)
            
        case .season(let seasonName, let teamId):
            return try await prepareSeasonData(seasonName: seasonName, teamId: teamId)
            
        case .lifetime(let playerId):
            return try await prepareLifetimeData(playerId: playerId)
        }
    }
    
    private func prepareSingleGameData(gameId: UUID) async throws -> ExportData {
        guard let game = try gameRepository.fetchGame(byId: gameId) else {
            throw ExportError.gameNotFound
        }
        
        let gameDTO = GameDTO(from: game)
        let events = try statRepository.fetchStats(forGame: gameId)
        let eventDTOs = events.map { StatEventDTO(from: $0) }
        
        // Get all players who participated
        let playerIds = Set(events.map { $0.playerId })
        var playerStats: [PlayerStatsDTO] = []
        
        for playerId in playerIds {
            guard let player = try playerRepository.fetchPlayer(byId: playerId) else { continue }
            let playerDTO = PlayerDTO(from: player)
            let playerEvents = eventDTOs.filter { $0.playerId == playerId }
            let stats = PlayerStatsDTO(player: playerDTO, events: playerEvents)
            playerStats.append(stats)
        }
        
        return ExportData(
            title: "Game vs \(gameDTO.opponentName)",
            subtitle: gameDTO.formattedDate,
            games: [gameDTO],
            playerStats: playerStats,
            scope: .singleGame
        )
    }
    
    private func prepareSeasonData(seasonName: String, teamId: UUID) async throws -> ExportData {
        let games = try gameRepository.fetchGames(forTeam: teamId)
            .filter { $0.isComplete }
            .map { GameDTO(from: $0) }
        
        guard let focusPlayer = try playerRepository.fetchFocusPlayer(forTeam: teamId) else {
            throw ExportError.playerNotFound
        }
        
        var playerStats: [PlayerStatsDTO] = []
        for game in games {
            let events = try statRepository.fetchStats(forPlayer: focusPlayer.id, inGame: game.id)
            let eventDTOs = events.map { StatEventDTO(from: $0) }
            let stats = PlayerStatsDTO(player: PlayerDTO(from: focusPlayer), events: eventDTOs)
            playerStats.append(stats)
        }
        
        return ExportData(
            title: "Season: \(seasonName)",
            subtitle: "\(focusPlayer.name)",
            games: games,
            playerStats: playerStats,
            scope: .season
        )
    }
    
    private func prepareLifetimeData(playerId: UUID) async throws -> ExportData {
        guard let player = try playerRepository.fetchPlayer(byId: playerId) else {
            throw ExportError.playerNotFound
        }
        
        let playerDTO = PlayerDTO(from: player)
        let games = try gameRepository.fetchGames(forTeam: player.teamId)
            .filter { $0.isComplete }
            .map { GameDTO(from: $0) }
        
        var playerStats: [PlayerStatsDTO] = []
        for game in games {
            let events = try statRepository.fetchStats(forPlayer: playerId, inGame: game.id)
            let eventDTOs = events.map { StatEventDTO(from: $0) }
            let stats = PlayerStatsDTO(player: playerDTO, events: eventDTOs)
            playerStats.append(stats)
        }
        
        return ExportData(
            title: "Career Stats",
            subtitle: playerDTO.name,
            games: games,
            playerStats: playerStats,
            scope: .lifetime
        )
    }
}

struct ExportData {
    let title: String
    let subtitle: String
    let games: [GameDTO]
    let playerStats: [PlayerStatsDTO]
    let scope: ExportDataScope
}

enum ExportDataScope {
    case singleGame
    case season
    case lifetime
}

enum ExportError: LocalizedError {
    case gameNotFound
    case playerNotFound
    case teamNotFound
    case exportFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .gameNotFound:
            return "Game not found"
        case .playerNotFound:
            return "Player not found"
        case .teamNotFound:
            return "Team not found"
        case .exportFailed(let message):
            return "Export failed: \(message)"
        }
    }
}
```

# Basketball Stats Tracker - Architectural Design Document

## Document Version: 1.0
## Target Platform: iOS 16+
## Language: Swift 5.9+
## Framework: SwiftUI + Combine
## Document Part: Section 6.2-6.4 - Export System

---

# TABLE OF CONTENTS

6.2 [CSV Export](#csv-export)
6.3 [PDF Export](#pdf-export)
6.4 [Share Sheet Integration](#share-sheet-integration)

---

<a name="csv-export"></a>
## 6.2 CSV Export (Continued)

### 6.2.1 Complete CSV Exporter Implementation

```swift
// CSVExporter.swift (Continued)
import Foundation

class CSVExporter {
    
    func export(data: ExportData) throws -> URL {
        let csvString = try generateCSV(from: data)
        return try saveToFile(csvString, filename: generateFilename(for: data))
    }
    
    private func generateCSV(from data: ExportData) throws -> String {
        var csv = ""
        
        // Header
        csv += "\(data.title)\n"
        csv += "\(data.subtitle)\n"
        csv += "Generated: \(Date().formatted())\n"
        csv += "\n"
        
        switch data.scope {
        case .singleGame:
            csv += generateSingleGameCSV(data: data)
        case .season, .lifetime:
            csv += generateMultiGameCSV(data: data)
        }
        
        return csv
    }
    
    private func generateSingleGameCSV(data: ExportData) -> String {
        var csv = ""
        
        guard let game = data.games.first else { return csv }
        
        // Game info
        csv += "Game Information\n"
        csv += "Opponent,Date,Location,Final Score,Result\n"
        csv += "\(escapeCSV(game.opponentName)),\(game.formattedDate),\(escapeCSV(game.location ?? "N/A")),\(game.finalScore),\(game.result)\n"
        csv += "\n"
        
        // Player stats header
        csv += "Player Statistics\n"
        csv += "Player,Number,Points,FGM,FGA,FG%,3PM,3PA,3P%,FTM,FTA,FT%,REB,AST,STL,BLK,TO,PF\n"
        
        // Player stats rows (sorted by points)
        for stats in data.playerStats.sorted(by: { $0.points > $1.points }) {
            csv += formatPlayerStatsRow(stats)
        }
        
        return csv
    }
    
    private func generateMultiGameCSV(data: ExportData) -> String {
        var csv = ""
        
        // Summary stats
        csv += "Summary Statistics\n"
        csv += "Games Played,Total Points,PPG,RPG,APG,SPG,BPG,FG%,3P%,FT%\n"
        
        let gamesPlayed = data.playerStats.count
        let totalPoints = data.playerStats.reduce(0) { $0 + $1.points }
        let ppg = gamesPlayed > 0 ? Double(totalPoints) / Double(gamesPlayed) : 0.0
        let totalReb = data.playerStats.reduce(0) { $0 + $1.rebounds }
        let rpg = gamesPlayed > 0 ? Double(totalReb) / Double(gamesPlayed) : 0.0
        let totalAst = data.playerStats.reduce(0) { $0 + $1.assists }
        let apg = gamesPlayed > 0 ? Double(totalAst) / Double(gamesPlayed) : 0.0
        let totalStl = data.playerStats.reduce(0) { $0 + $1.steals }
        let spg = gamesPlayed > 0 ? Double(totalStl) / Double(gamesPlayed) : 0.0
        let totalBlk = data.playerStats.reduce(0) { $0 + $1.blocks }
        let bpg = gamesPlayed > 0 ? Double(totalBlk) / Double(gamesPlayed) : 0.0
        
        let totalFGM = data.playerStats.reduce(0) { $0 + $1.fgMade }
        let totalFGA = data.playerStats.reduce(0) { $0 + $1.fgAttempted }
        let fgPct = totalFGA > 0 ? Double(totalFGM) / Double(totalFGA) * 100.0 : 0.0
        
        let total3PM = data.playerStats.reduce(0) { $0 + $1.threePtMade }
        let total3PA = data.playerStats.reduce(0) { $0 + $1.threePtAttempted }
        let threePct = total3PA > 0 ? Double(total3PM) / Double(total3PA) * 100.0 : 0.0
        
        let totalFTM = data.playerStats.reduce(0) { $0 + $1.ftMade }
        let totalFTA = data.playerStats.reduce(0) { $0 + $1.ftAttempted }
        let ftPct = totalFTA > 0 ? Double(totalFTM) / Double(totalFTA) * 100.0 : 0.0
        
        csv += "\(gamesPlayed),\(totalPoints),\(f(ppg)),\(f(rpg)),\(f(apg)),\(f(spg)),\(f(bpg)),\(f(fgPct)),\(f(threePct)),\(f(ftPct))\n"
        csv += "\n"
        
        // Win-Loss Record
        let wins = data.games.filter { $0.isWin }.count
        let losses = data.games.filter { $0.isLoss }.count
        csv += "Team Record\n"
        csv += "Wins,Losses,Win %\n"
        let winPct = gamesPlayed > 0 ? Double(wins) / Double(gamesPlayed) * 100.0 : 0.0
        csv += "\(wins),\(losses),\(f(winPct))%\n"
        csv += "\n"
        
        // Game-by-game breakdown
        csv += "Game-by-Game Statistics\n"
        csv += "Date,Opponent,Result,Score,Points,FGM-FGA,FG%,3PM-3PA,3P%,FTM-FTA,FT%,REB,AST,STL,BLK\n"
        
        for (index, game) in data.games.enumerated() {
            guard index < data.playerStats.count else { continue }
            let stats = data.playerStats[index]
            
            csv += "\(game.formattedDate),\(escapeCSV(game.opponentName)),\(game.result),\(game.finalScore),\(stats.points),\(stats.fgMade)-\(stats.fgAttempted),\(f(stats.fgPercentage))%,\(stats.threePtMade)-\(stats.threePtAttempted),\(f(stats.threePtPercentage))%,\(stats.ftMade)-\(stats.ftAttempted),\(f(stats.ftPercentage))%,\(stats.rebounds),\(stats.assists),\(stats.steals),\(stats.blocks)\n"
        }
        
        return csv
    }
    
    private func formatPlayerStatsRow(_ stats: PlayerStatsDTO) -> String {
        let number = stats.jerseyNumber ?? "N/A"
        return "\(escapeCSV(stats.playerName)),\(number),\(stats.points),\(stats.fgMade),\(stats.fgAttempted),\(f(stats.fgPercentage)),\(stats.threePtMade),\(stats.threePtAttempted),\(f(stats.threePtPercentage)),\(stats.ftMade),\(stats.ftAttempted),\(f(stats.ftPercentage)),\(stats.rebounds),\(stats.assists),\(stats.steals),\(stats.blocks),\(stats.turnovers),\(stats.fouls)\n"
    }
    
    // MARK: - Helper Methods
    
    /// Escape CSV special characters
    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
    
    /// Format decimal number
    private func f(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }
    
    private func saveToFile(_ content: String, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
    
    private func generateFilename(for data: ExportData) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timestamp = dateFormatter.string(from: Date())
        
        let sanitized = data.title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "/", with: "-")
        
        return "\(sanitized)_\(timestamp).csv"
    }
}
```

<a name="pdf-export"></a>
## 6.3 PDF Export

### 6.3.1 PDF Exporter Implementation

```swift
// PDFExporter.swift
import UIKit
import PDFKit

class PDFExporter {
    
    private let pageWidth: CGFloat = 612    // 8.5 inches
    private let pageHeight: CGFloat = 792   // 11 inches
    private let margin: CGFloat = 50
    
    func export(data: ExportData) throws -> URL {
        let pdfData = generatePDF(from: data)
        return try saveToFile(pdfData, filename: generateFilename(for: data))
    }
    
    private func generatePDF(from data: ExportData) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            var yPosition: CGFloat = margin
            
            context.beginPage()
            
            // Title
            yPosition = drawTitle(data.title, at: yPosition, in: pageRect)
            yPosition = drawSubtitle(data.subtitle, at: yPosition, in: pageRect)
            yPosition += 10
            
            // Generated date
            yPosition = drawText(
                "Generated: \(Date().formatted())",
                at: yPosition,
                in: pageRect,
                font: .systemFont(ofSize: 10),
                color: .gray
            )
            yPosition += 20
            
            switch data.scope {
            case .singleGame:
                yPosition = drawSingleGamePDF(
                    data: data,
                    startingAt: yPosition,
                    in: pageRect,
                    context: context
                )
            case .season, .lifetime:
                yPosition = drawMultiGamePDF(
                    data: data,
                    startingAt: yPosition,
                    in: pageRect,
                    context: context
                )
            }
        }
    }
    
    // MARK: - Single Game PDF
    
    private func drawSingleGamePDF(
        data: ExportData,
        startingAt yPosition: CGFloat,
        in pageRect: CGRect,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var y = yPosition
        
        guard let game = data.games.first else { return y }
        
        // Game info box
        y = drawSectionHeader("Game Information", at: y, in: pageRect)
        y += 10
        
        y = drawText("Opponent: \(game.opponentName)", at: y, in: pageRect)
        y = drawText("Date: \(game.formattedDate)", at: y, in: pageRect)
        if let location = game.location {
            y = drawText("Location: \(location)", at: y, in: pageRect)
        }
        y = drawText("Final Score: \(game.finalScore) (\(game.result))", at: y, in: pageRect)
        y += 20
        
        // Player stats table
        y = drawSectionHeader("Player Statistics", at: y, in: pageRect)
        y += 10
        
        y = drawPlayerStatsTable(
            stats: data.playerStats.sorted { $0.points > $1.points },
            startingAt: y,
            in: pageRect,
            context: context
        )
        
        return y
    }
    
    // MARK: - Multi-Game PDF
    
    private func drawMultiGamePDF(
        data: ExportData,
        startingAt yPosition: CGFloat,
        in pageRect: CGRect,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var y = yPosition
        
        // Summary stats box
        y = drawSectionHeader("Summary Statistics", at: y, in: pageRect)
        y += 10
        
        let gamesPlayed = data.playerStats.count
        let totalPoints = data.playerStats.reduce(0) { $0 + $1.points }
        let ppg = gamesPlayed > 0 ? Double(totalPoints) / Double(gamesPlayed) : 0.0
        
        let totalFGM = data.playerStats.reduce(0) { $0 + $1.fgMade }
        let totalFGA = data.playerStats.reduce(0) { $0 + $1.fgAttempted }
        let fgPct = totalFGA > 0 ? Double(totalFGM) / Double(totalFGA) * 100.0 : 0.0
        
        y = drawKeyValuePair("Games Played:", "\(gamesPlayed)", at: y, in: pageRect)
        y = drawKeyValuePair("Total Points:", "\(totalPoints)", at: y, in: pageRect)
        y = drawKeyValuePair("Points Per Game:", String(format: "%.1f", ppg), at: y, in: pageRect)
        y = drawKeyValuePair("Field Goal %:", String(format: "%.1f%%", fgPct), at: y, in: pageRect)
        y += 20
        
        // Win-Loss record
        let wins = data.games.filter { $0.isWin }.count
        let losses = data.games.filter { $0.isLoss }.count
        
        y = drawSectionHeader("Team Record", at: y, in: pageRect)
        y += 10
        y = drawKeyValuePair("Record:", "\(wins)-\(losses)", at: y, in: pageRect)
        y += 20
        
        // Check if we need a new page
        if y > pageHeight - 200 {
            context.beginPage()
            y = margin
        }
        
        // Game-by-game table
        y = drawSectionHeader("Game-by-Game Performance", at: y, in: pageRect)
        y += 10
        
        y = drawGameByGameTable(
            games: data.games,
            stats: data.playerStats,
            startingAt: y,
            in: pageRect,
            context: context
        )
        
        return y
    }
    
    // MARK: - Table Drawing
    
    private func drawPlayerStatsTable(
        stats: [PlayerStatsDTO],
        startingAt yPosition: CGFloat,
        in pageRect: CGRect,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var y = yPosition
        
        let tableWidth = pageWidth - (2 * margin)
        let columnWidths: [CGFloat] = [100, 40, 40, 60, 60, 60, 40, 40, 40, 40]
        
        // Header
        y = drawTableHeader(
            columns: ["Player", "#", "PTS", "FG", "3PT", "FT", "REB", "AST", "STL", "BLK"],
            widths: columnWidths,
            at: y,
            in: pageRect
        )
        
        // Rows
        for stat in stats {
            if y > pageHeight - 100 {
                context.beginPage()
                y = margin
                y = drawTableHeader(
                    columns: ["Player", "#", "PTS", "FG", "3PT", "FT", "REB", "AST", "STL", "BLK"],
                    widths: columnWidths,
                    at: y,
                    in: pageRect
                )
            }
            
            let values = [
                stat.playerName,
                stat.jerseyNumber ?? "-",
                "\(stat.points)",
                "\(stat.fgMade)-\(stat.fgAttempted)",
                "\(stat.threePtMade)-\(stat.threePtAttempted)",
                "\(stat.ftMade)-\(stat.ftAttempted)",
                "\(stat.rebounds)",
                "\(stat.assists)",
                "\(stat.steals)",
                "\(stat.blocks)"
            ]
            
            y = drawTableRow(values: values, widths: columnWidths, at: y, in: pageRect)
        }
        
        return y + 10
    }
    
    private func drawGameByGameTable(
        games: [GameDTO],
        stats: [PlayerStatsDTO],
        startingAt yPosition: CGFloat,
        in pageRect: CGRect,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var y = yPosition
        
        let columnWidths: [CGFloat] = [80, 120, 40, 60, 40, 60, 40, 40, 40]
        
        // Header
        y = drawTableHeader(
            columns: ["Date", "Opponent", "W/L", "Score", "PTS", "FG", "REB", "AST", "STL"],
            widths: columnWidths,
            at: y,
            in: pageRect
        )
        
        // Rows
        for (index, game) in games.enumerated() {
            guard index < stats.count else { continue }
            let stat = stats[index]
            
            if y > pageHeight - 100 {
                context.beginPage()
                y = margin
                y = drawTableHeader(
                    columns: ["Date", "Opponent", "W/L", "Score", "PTS", "FG", "REB", "AST", "STL"],
                    widths: columnWidths,
                    at: y,
                    in: pageRect
                )
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let dateStr = dateFormatter.string(from: game.gameDate)
            
            let values = [
                dateStr,
                game.opponentName,
                game.result,
                game.finalScore,
                "\(stat.points)",
                "\(stat.fgMade)-\(stat.fgAttempted)",
                "\(stat.rebounds)",
                "\(stat.assists)",
                "\(stat.steals)"
            ]
            
            y = drawTableRow(values: values, widths: columnWidths, at: y, in: pageRect)
        }
        
        return y + 10
    }
    
    private func drawTableHeader(
        columns: [String],
        widths: [CGFloat],
        at yPosition: CGFloat,
        in pageRect: CGRect
    ) -> CGFloat {
        var x = margin
        let y = yPosition
        let rowHeight: CGFloat = 25
        
        // Draw header background
        let headerRect = CGRect(x: margin, y: y, width: widths.reduce(0, +), height: rowHeight)
        UIColor.systemGray5.setFill()
        UIBezierPath(rect: headerRect).fill()
        
        // Draw column text
        for (index, column) in columns.enumerated() {
            let rect = CGRect(x: x, y: y, width: widths[index], height: rowHeight)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 10),
                .paragraphStyle: paragraphStyle
            ]
            
            column.draw(in: rect, withAttributes: attributes)
            x += widths[index]
        }
        
        return y + rowHeight
    }
    
    private func drawTableRow(
        values: [String],
        widths: [CGFloat],
        at yPosition: CGFloat,
        in pageRect: CGRect
    ) -> CGFloat {
        var x = margin
        let y = yPosition
        let rowHeight: CGFloat = 20
        
        // Draw row border
        let rowRect = CGRect(x: margin, y: y, width: widths.reduce(0, +), height: rowHeight)
        UIColor.systemGray6.setStroke()
        UIBezierPath(rect: rowRect).stroke()
        
        // Draw cell text
        for (index, value) in values.enumerated() {
            let rect = CGRect(x: x + 5, y: y, width: widths[index] - 10, height: rowHeight)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = index == 0 ? .left : .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),
                .paragraphStyle: paragraphStyle
            ]
            
            value.draw(in: rect, withAttributes: attributes)
            x += widths[index]
        }
        
        return y + rowHeight
    }
    
    // MARK: - Text Drawing Helpers
    
    private func drawTitle(_ text: String, at yPosition: CGFloat, in pageRect: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(
            x: margin,
            y: yPosition,
            width: pageWidth - (2 * margin),
            height: textSize.height
        )
        
        text.draw(in: rect, withAttributes: attributes)
        
        return yPosition + textSize.height + 10
    }
    
    private func drawSubtitle(_ text: String, at yPosition: CGFloat, in pageRect: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.darkGray
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(
            x: margin,
            y: yPosition,
            width: pageWidth - (2 * margin),
            height: textSize.height
        )
        
        text.draw(in: rect, withAttributes: attributes)
        
        return yPosition + textSize.height + 5
    }
    
    private func drawText(
        _ text: String,
        at yPosition: CGFloat,
        in pageRect: CGRect,
        font: UIFont = .systemFont(ofSize: 12),
        color: UIColor = .black
    ) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(
            x: margin,
            y: yPosition,
            width: pageWidth - (2 * margin),
            height: textSize.height
        )
        
        text.draw(in: rect, withAttributes: attributes)
        
        return yPosition + textSize.height + 5
    }
    
    private func drawSectionHeader(_ text: String, at yPosition: CGFloat, in pageRect: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(
            x: margin,
            y: yPosition,
            width: pageWidth - (2 * margin),
            height: textSize.height
        )
        
        text.draw(in: rect, withAttributes: attributes)
        
        // Draw underline
        let lineY = yPosition + textSize.height + 2
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: margin, y: lineY))
        linePath.addLine(to: CGPoint(x: pageWidth - margin, y: lineY))
        UIColor.black.setStroke()
        linePath.lineWidth = 1
        linePath.stroke()
        
        return lineY + 5
    }
    
    private func drawKeyValuePair(
        _ key: String,
        _ value: String,
        at yPosition: CGFloat,
        in pageRect: CGRect
    ) -> CGFloat {
        let keyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        let keySize = key.size(withAttributes: keyAttributes)
        
        let keyRect = CGRect(x: margin, y: yPosition, width: 150, height: keySize.height)
        key.draw(in: keyRect, withAttributes: keyAttributes)
        
        let valueRect = CGRect(x: margin + 150, y: yPosition, width: 200, height: keySize.height)
        value.draw(in: valueRect, withAttributes: valueAttributes)
        
        return yPosition + keySize.height + 5
    }
    
    // MARK: - File Operations
    
    private func saveToFile(_ data: Data, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        
        try data.write(to: fileURL)
        
        return fileURL
    }
    
    private func generateFilename(for data: ExportData) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timestamp = dateFormatter.string(from: Date())
        
        let sanitized = data.title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "/", with: "-")
        
        return "\(sanitized)_\(timestamp).pdf"
    }
}
```

<a name="share-sheet-integration"></a>
## 6.4 Share Sheet Integration

### 6.4.1 Share Sheet Helper

```swift
// ShareHelper.swift
import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let applicationActivities: [UIActivity]?
    
    init(items: [Any], applicationActivities: [UIActivity]? = nil) {
        self.items = items
        self.applicationActivities = applicationActivities
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: applicationActivities
        )
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// Usage in SwiftUI
struct ExportView: View {
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    var body: some View {
        Button("Export & Share") {
            exportData()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func exportData() {
        Task {
            do {
                let url = try await ExportManager().export(
                    scope: .singleGame(gameId),
                    format: .csv
                )
                exportedFileURL = url
                showingShareSheet = true
            } catch {
                // Handle error
            }
        }
    }
}
```

### 6.4.2 Export View Model

```swift
// ExportViewModel.swift
import Foundation
import SwiftUI

@MainActor
class ExportViewModel: ObservableObject {
    @Published var isExporting = false
    @Published var exportError: Error?
    @Published var exportedFileURL: URL?
    @Published var showingShareSheet = false
    
    private let exportManager: ExportManager
    
    init(exportManager: ExportManager = ExportManager()) {
        self.exportManager = exportManager
    }
    
    func exportGame(_ gameId: UUID, format: ExportFormat) async {
        isExporting = true
        exportError = nil
        
        do {
            let url = try await exportManager.export(
                scope: .singleGame(gameId),
                format: format
            )
            exportedFileURL = url
            showingShareSheet = true
        } catch {
            exportError = error
        }
        
        isExporting = false
    }
    
    func exportSeason(_ seasonName: String, teamId: UUID, format: ExportFormat) async {
        isExporting = true
        exportError = nil
        
        do {
            let url = try await exportManager.export(
                scope: .season(seasonName, teamId),
                format: format
            )
            exportedFileURL = url
            showingShareSheet = true
        } catch {
            exportError = error
        }
        
        isExporting = false
    }
    
    func exportLifetime(_ playerId: UUID, format: ExportFormat) async {
        isExporting = true
        exportError = nil
        
        do {
            let url = try await exportManager.export(
                scope: .lifetime(playerId),
                format: format
            )
            exportedFileURL = url
            showingShareSheet = true
        } catch {
            exportError = error
        }
        
        isExporting = false
    }
}
```

### 6.4.3 Export UI Components

```swift
// ExportOptionsView.swift
import SwiftUI

struct ExportOptionsView: View {
    let gameId: UUID?
    let teamId: UUID?
    let playerId: UUID?
    
    @StateObject private var viewModel = ExportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedScope: ExportScopeOption = .game
    @State private var selectedFormat: ExportFormat = .csv
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Scope")) {
                    Picker("Scope", selection: $selectedScope) {
                        if gameId != nil {
                            Text("Single Game").tag(ExportScopeOption.game)
                        }
                        if teamId != nil {
                            Text("Season").tag(ExportScopeOption.season)
                        }
                        if playerId != nil {
                            Text("Lifetime").tag(ExportScopeOption.lifetime)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section(header: Text("Export Format")) {
                    Picker("Format", selection: $selectedFormat) {
                        Text("CSV (Spreadsheet)").tag(ExportFormat.csv)
                        Text("PDF (Document)").tag(ExportFormat.pdf)
                    }
                    .pickerStyle(.inline)
                }
                
                Section {
                    Button(action: {
                        performExport()
                    }) {
                        HStack {
                            if viewModel.isExporting {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text(viewModel.isExporting ? "Exporting..." : "Export & Share")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isExporting)
                }
            }
            .navigationTitle("Export Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Export Error", isPresented: .constant(viewModel.exportError != nil)) {
                Button("OK") {
                    viewModel.exportError = nil
                }
            } message: {
                if let error = viewModel.exportError {
                    Text(error.localizedDescription)
                }
            }
            .sheet(isPresented: $viewModel.showingShareSheet) {
                if let url = viewModel.exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func performExport() {
        Task {
            switch selectedScope {
            case .game:
                if let gameId = gameId {
                    await viewModel.exportGame(gameId, format: selectedFormat)
                }
            case .season:
                if let teamId = teamId {
                    await viewModel.exportSeason("Current Season", teamId: teamId, format: selectedFormat)
                }
            case .lifetime:
                if let playerId = playerId {
                    await viewModel.exportLifetime(playerId, format: selectedFormat)
                }
            }
            
            if viewModel.exportError == nil {
                dismiss()
            }
        }
    }
}

enum ExportScopeOption {
    case game
    case season
    case lifetime
}
```

### 6.4.4 Quick Export Button Component

```swift
// QuickExportButton.swift
import SwiftUI

struct QuickExportButton: View {
    let gameId: UUID
    @State private var showingExportOptions = false
    
    var body: some View {
        Button(action: {
            showingExportOptions = true
        }) {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(gameId: gameId, teamId: nil, playerId: nil)
        }
    }
}

// Usage in GameDetailView
struct GameDetailView: View {
    let gameId: UUID
    
    var body: some View {
        ScrollView {
            // Game content...
        }
        .navigationTitle("Game Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                QuickExportButton(gameId: gameId)
            }
        }
    }
}
```

### 6.4.5 Bulk Export Support

```swift
// BulkExportManager.swift
import Foundation

class BulkExportManager {
    private let exportManager: ExportManager
    
    init(exportManager: ExportManager = ExportManager()) {
        self.exportManager = exportManager
    }
    
    /// Export multiple games to a single ZIP file
    func exportMultipleGames(_ gameIds: [UUID], format: ExportFormat) async throws -> URL {
        var fileURLs: [URL] = []
        
        // Export each game
        for gameId in gameIds {
            let url = try await exportManager.export(
                scope: .singleGame(gameId),
                format: format
            )
            fileURLs.append(url)
        }
        
        // Create ZIP archive
        let zipURL = try createZipArchive(from: fileURLs, name: "MultipleGames")
        
        // Clean up individual files
        for url in fileURLs {
            try? FileManager.default.removeItem(at: url)
        }
        
        return zipURL
    }
    
    private func createZipArchive(from urls: [URL], name: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let zipURL = tempDir.appendingPathComponent("\(name).zip")
        
        // Remove existing zip if present
        try? FileManager.default.removeItem(at: zipURL)
        
        // Create coordinator for file operations
        var error: NSError?
        let coordinator = NSFileCoordinator()
        
        coordinator.coordinate(readingItemAt: tempDir, options: .forUploading, error: &error) { url in
            do {
                // Using simple zip implementation
                // In production, use a proper ZIP library like ZIPFoundation
                try FileManager.default.zipItem(at: tempDir, to: zipURL)
            } catch {
                print("ZIP error: \(error)")
            }
        }
        
        if let error = error {
            throw error
        }
        
        return zipURL
    }
}

// Extension for basic ZIP support (simplified)
extension FileManager {
    func zipItem(at sourceURL: URL, to destinationURL: URL) throws {
        // This is a placeholder - in production use ZIPFoundation or similar
        // For now, just copy the file
        try copyItem(at: sourceURL, to: destinationURL)
    }
}
```

### 6.4.6 Email Integration

```swift
// EmailComposer.swift
import MessageUI
import SwiftUI

struct EmailComposer: UIViewControllerRepresentable {
    let fileURL: URL
    let fileName: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        
        // Attach file
        if let data = try? Data(contentsOf: fileURL) {
            let mimeType = fileURL.pathExtension == "pdf" ? "application/pdf" : "text/csv"
            composer.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
        }
        
        composer.setSubject("Basketball Stats - \(fileName)")
        composer.setMessageBody("Please find attached basketball statistics.", isHTML: false)
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: EmailComposer
        
        init(_ parent: EmailComposer) {
            self.parent = parent
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            parent.dismiss()
        }
    }
}

// Usage
struct ExportWithEmailView: View {
    @State private var showingEmailComposer = false
    @State private var exportedFileURL: URL?
    
    var body: some View {
        Button("Email Stats") {
            exportAndEmail()
        }
        .sheet(isPresented: $showingEmailComposer) {
            if let url = exportedFileURL {
                if MFMailComposeViewController.canSendMail() {
                    EmailComposer(fileURL: url, fileName: url.lastPathComponent)
                } else {
                    Text("Mail services are not available")
                }
            }
        }
    }
    
    private func exportAndEmail() {
        Task {
            do {
                let url = try await ExportManager().export(
                    scope: .singleGame(gameId),
                    format: .csv
                )
                exportedFileURL = url
                showingEmailComposer = true
            } catch {
                // Handle error
            }
        }
    }
}
```

### 6.4.7 Cloud Storage Integration

```swift
// CloudStorageManager.swift
import Foundation
import CloudKit

class CloudStorageManager {
    private let container: CKContainer
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.yourdomain.basketballstats")
    }
    
    /// Save exported file to iCloud Drive
    func saveToiCloudDrive(fileURL: URL) async throws -> URL {
        let fileManager = FileManager.default
        
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            throw CloudStorageError.iCloudNotAvailable
        }
        
        let documentsURL = iCloudURL.appendingPathComponent("Documents")
        
        // Create directory if needed
        try fileManager.createDirectory(at: documentsURL, withIntermediateDirectories: true)
        
        let destinationURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
        
        // Copy file to iCloud
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.copyItem(at: fileURL, to: destinationURL)
        
        return destinationURL
    }
    
    /// Check if iCloud is available
    func checkiCloudAvailability() async -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
}

enum CloudStorageError: LocalizedError {
    case iCloudNotAvailable
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .iCloudNotAvailable:
            return "iCloud Drive is not available. Please check your iCloud settings."
        case .uploadFailed:
            return "Failed to upload file to iCloud Drive"
        }
    }
}
```

### 6.4.8 Export Progress Tracking

```swift
// ExportProgressView.swift
import SwiftUI

struct ExportProgressView: View {
    @ObservedObject var progressTracker: ExportProgressTracker
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView(value: progressTracker.progress, total: 1.0)
                .progressViewStyle(.linear)
            
            Text(progressTracker.currentStep)
                .font(.bodyMedium)
                .foregroundColor(.secondary)
            
            if progressTracker.progress >= 1.0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("StatGreen"))
                    Text("Export Complete")
                        .font(.titleMedium)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(Spacing.xl)
    }
}

class ExportProgressTracker: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var currentStep: String = ""
    
    func updateProgress(_ value: Double, step: String) {
        DispatchQueue.main.async {
            self.progress = value
            self.currentStep = step
        }
    }
    
    func reset() {
        progress = 0.0
        currentStep = ""
    }
}
```

### 6.4.9 Export History

```swift
// ExportHistory.swift
import Foundation

struct ExportRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let scope: String
    let format: String
    let fileName: String
    let fileURL: URL?
    
    init(id: UUID = UUID(), 
         date: Date = Date(), 
         scope: String, 
         format: String, 
         fileName: String, 
         fileURL: URL? = nil) {
        self.id = id
        self.date = date
        self.scope = scope
        self.format = format
        self.fileName = fileName
        self.fileURL = fileURL
    }
}

class ExportHistoryManager {
    private let userDefaults = UserDefaults.standard
    private let historyKey = "exportHistory"
    private let maxHistoryCount = 20
    
    func addRecord(_ record: ExportRecord) {
        var history = getHistory()
        history.insert(record, at: 0)
        
        // Keep only recent records
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        saveHistory(history)
    }
    
    func getHistory() -> [ExportRecord] {
        guard let data = userDefaults.data(forKey: historyKey),
              let records = try? JSONDecoder().decode([ExportRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    func clearHistory() {
        userDefaults.removeObject(forKey: historyKey)
    }
    
    func deleteRecord(_ id: UUID) {
        var history = getHistory()
        history.removeAll { $0.id == id }
        saveHistory(history)
    }
    
    private func saveHistory(_ history: [ExportRecord]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
}

// ExportHistoryView.swift
struct ExportHistoryView: View {
    @StateObject private var historyManager = ExportHistoryManager()
    @State private var history: [ExportRecord] = []
    
    var body: some View {
        List {
            ForEach(history) { record in
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(record.fileName)
                        .font(.bodyLarge)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text(record.scope)
                            .font(.bodySmall)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(record.format.uppercased())
                            .font(.bodySmall)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.bodySmall)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, Spacing.xs)
                .swipeActions {
                    Button(role: .destructive) {
                        historyManager.deleteRecord(record.id)
                        history = historyManager.getHistory()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Export History")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Clear All") {
                    historyManager.clearHistory()
                    history = []
                }
                .disabled(history.isEmpty)
            }
        }
        .onAppear {
            history = historyManager.getHistory()
        }
    }
}
```

---

**End of Section 6 - Export & Sharing System**

This section provides comprehensive coverage of:
- Export architecture with support for multiple scopes and formats
- Complete CSV exporter with proper escaping and formatting
- Full PDF exporter with table layouts and multi-page support
- iOS Share Sheet integration
- Email composition support
- iCloud Drive integration
- Bulk export capabilities
- Progress tracking
- Export history management

The export system is designed to be flexible, extensible, and user-friendly, supporting all common sharing methods on iOS while maintaining data integrity and proper formatting.

# Basketball Stats Tracker - Architectural Design Document

## Document Version: 1.0
## Target Platform: iOS 16+
## Language: Swift 5.9+
## Framework: SwiftUI + Combine
## Document Part: Final Sections 7-9

---

# TABLE OF CONTENTS

7. [Testing Strategy](#testing-strategy)
8. [Security, Privacy & Performance](#security-privacy-performance)
9. [Deployment & Dependencies](#deployment-dependencies)
10. [Assumptions & Gaps Analysis](#assumptions-gaps)

---

<a name="testing-strategy"></a>
# 7. TESTING STRATEGY

## 7.1 Testing Pyramid

```
                    ┌──────────────┐
                    │   E2E Tests  │  (5-10%)
                    │   UI Tests   │
                    └──────────────┘
                ┌──────────────────────┐
                │  Integration Tests   │  (20-30%)
                │  Repository Tests    │
                └──────────────────────┘
            ┌──────────────────────────────┐
            │      Unit Tests              │  (60-70%)
            │  Business Logic, Use Cases   │
            └──────────────────────────────┘
```

## 7.2 Unit Testing

### 7.2.1 Testing Use Cases

**Pseudo Code:**
```swift
// RecordStatUseCaseTests.swift
class RecordStatUseCaseTests {
    var sut: RecordStatUseCase
    var mockStatRepository: MockStatRepository
    var mockPlayerRepository: MockPlayerRepository
    var mockGameRepository: MockGameRepository
    
    setup() {
        // Initialize mocks
        mockStatRepository = MockStatRepository()
        mockPlayerRepository = MockPlayerRepository()
        mockGameRepository = MockGameRepository()
        
        // Initialize system under test
        sut = RecordStatUseCase(
            statRepository: mockStatRepository,
            playerRepository: mockPlayerRepository,
            gameRepository: mockGameRepository
        )
    }
    
    test_recordStat_withValidInput_succeeds() {
        // Given
        mockPlayerRepository.playerExists = true
        mockGameRepository.gameExists = true
        mockGameRepository.gameIsComplete = false
        
        // When
        result = sut.execute(validInput)
        
        // Then
        assert(mockStatRepository.recordStatWasCalled)
        assert(result.success)
    }
    
    test_recordStat_withCompletedGame_fails() {
        // Given
        mockGameRepository.gameIsComplete = true
        
        // When & Then
        expectError(UseCaseError.businessRuleViolation)
    }
}
```

### 7.2.2 Testing Repositories

**Pseudo Code:**
```swift
// StatEventRepositoryTests.swift
class StatEventRepositoryTests {
    var sut: StatEventRepository
    var inMemoryContext: NSManagedObjectContext
    
    setup() {
        // Create in-memory Core Data stack for testing
        inMemoryContext = createInMemoryContext()
        sut = StatEventRepository(context: inMemoryContext)
    }
    
    test_recordStat_createsStat() {
        // When
        stat = sut.recordStat(playerId, gameId, .twoPointMade)
        
        // Then
        assert(stat != null)
        assert(stat.statType == "TWO_MADE")
        assert(stat.value == 2)
    }
    
    test_fetchStats_returnsOnlyNonDeleted() {
        // Given
        createStat(isDeleted: false)
        createStat(isDeleted: true)
        
        // When
        stats = sut.fetchStats(forGame: gameId)
        
        // Then
        assert(stats.count == 1)
    }
}
```

### 7.2.3 Testing ViewModels

**Pseudo Code:**
```swift
// LiveGameViewModelTests.swift
class LiveGameViewModelTests {
    var sut: LiveGameViewModel
    var mockStatRepository: MockStatRepository
    
    test_recordFocusPlayerStat_updatesStats() {
        // Given
        sut = createViewModel()
        initialPoints = sut.focusPlayerStats.points
        
        // When
        sut.recordFocusPlayerStat(.twoPointMade)
        
        // Then
        assert(sut.focusPlayerStats.points == initialPoints + 2)
        assert(sut.teamScore == previousScore + 2)
    }
    
    test_undoLastAction_revertsLastStat() {
        // Given
        sut.recordFocusPlayerStat(.twoPointMade)
        scoreAfterStat = sut.teamScore
        
        // When
        sut.undoLastAction()
        
        // Then
        assert(sut.teamScore == scoreAfterStat - 2)
        assert(mockStatRepository.softDeleteWasCalled)
    }
}
```

### 7.2.4 Testing Calculators

**Pseudo Code:**
```swift
// StatsCalculatorTests.swift
class StatsCalculatorTests {
    var sut: StatsCalculator
    
    test_calculateShootingPercentage_withNoAttempts_returnsZero() {
        result = sut.calculateShootingPercentage(made: 0, attempted: 0)
        assert(result == 0.0)
    }
    
    test_calculateShootingPercentage_withAttempts_returnsCorrectPercentage() {
        result = sut.calculateShootingPercentage(made: 3, attempted: 10)
        assert(result == 30.0)
    }
    
    test_calculateGameScore_withPositiveStats_returnsPositiveScore() {
        stats = createPlayerStatsWithPositiveValues()
        result = sut.calculateGameScore(stats)
        assert(result > 0)
    }
}
```

## 7.3 Integration Testing

### 7.3.1 Repository Integration Tests

**Test Scenarios:**
- Create team → Create players → Verify relationships
- Create game → Record stats → Fetch stats → Verify data integrity
- Soft delete stat → Verify it doesn't appear in active queries
- Update game to complete → Verify can't add more stats

### 7.3.2 Use Case Integration Tests

**Test Scenarios:**
- Complete game flow: CreateGame → RecordStats → EndGame → CalculateStats
- Export flow: FetchGame → CalculateStats → ExportToPDF
- Undo flow: RecordStat → UndoStat → VerifyStatRemoved

## 7.4 UI Testing

### 7.4.1 Critical Path Tests

**Onboarding Flow:**
```swift
// OnboardingUITests.swift
test_onboarding_completeFlow() {
    // Launch app
    app.launch()
    
    // Welcome screen
    app.buttons["Get Started"].tap()
    
    // Team setup
    app.textFields["Team Name"].tap().typeText("Warriors")
    app.textFields["Season"].tap().typeText("Fall 2025")
    app.buttons["Continue"].tap()
    
    // Player setup
    app.buttons["Add Player"].tap()
    app.textFields["Player Name"].typeText("John Doe")
    app.buttons["Add"].tap()
    
    // Set focus player
    app.buttons["star"].firstMatch.tap()
    
    // Complete
    app.buttons["Complete Setup"].tap()
    
    // Verify home screen appears
    assert(app.navigationBars["Home"].exists)
}
```

**Live Game Flow:**
```swift
test_liveGame_recordStats() {
    // Navigate to live game
    startNewGame()
    
    // Record 2-point shot
    app.buttons["2PT Made"].tap()
    
    // Verify score updated
    assert(app.staticTexts.containing("2").exists)
    
    // Record missed shot
    app.buttons["3PT Miss"].tap()
    
    // Verify shot percentage updated
    // Stats should show 1-2 shooting
}
```

## 7.5 Performance Testing

### 7.5.1 Load Testing

**Test Scenarios:**
- Load game with 200+ stat events
- Calculate season stats across 30 games
- Render games list with 100+ games
- Export lifetime stats with 500+ events

**Performance Targets:**
- Game list load: < 500ms
- Stat calculation: < 100ms
- PDF export: < 5 seconds
- Stat recording: < 50ms (crucial for 3-second requirement)

### 7.5.2 Memory Testing

**Scenarios:**
- Monitor memory during long game (2+ hours)
- Check for memory leaks in navigation
- Verify Core Data context cleanup
- Test image cache limits

**Targets:**
- Peak memory: < 150MB during active game
- Memory growth: < 1MB per hour of gameplay
- No memory leaks in 1-hour test session

## 7.6 Testing Tools & Frameworks

### 7.6.1 Unit Testing
- **XCTest**: Built-in framework
- **Quick/Nimble**: BDD-style testing (optional)
- **Mock frameworks**: Custom mock implementations

### 7.6.2 UI Testing
- **XCUITest**: Built-in UI testing
- **Screenshots**: Automated screenshot generation

### 7.6.3 Performance Testing
- **Instruments**: Time Profiler, Allocations
- **XCTest Performance Metrics**: Measure execution time

### 7.6.4 Code Coverage
- **Target**: 80%+ coverage for business logic
- **XCTest Coverage**: Built-in coverage reporting
- **Exclusions**: Generated code, UI views

## 7.7 Continuous Integration

**Pipeline Structure:**
```yaml
# Pseudo CI/CD Configuration
stages:
  - build
  - test
  - analyze
  
build:
  - xcodebuild clean build
  
unit_tests:
  - xcodebuild test -scheme BasketballStatsTracker -destination 'platform=iOS Simulator,name=iPhone 15'
  
ui_tests:
  - xcodebuild test -scheme BasketballStatsTrackerUITests
  
code_coverage:
  - Generate coverage report
  - Enforce 80% minimum
  
static_analysis:
  - SwiftLint
  - Check for warnings
```

---

<a name="security-privacy-performance"></a>
# 8. SECURITY, PRIVACY & PERFORMANCE

## 8.1 Security

### 8.1.1 Data Security

**Local Data Protection:**
- Core Data encrypted at rest (iOS default)
- No sensitive data stored in UserDefaults
- Keychain for any future authentication tokens
- File protection level: .complete

**Code Security:**
```swift
// Pseudo code for secure data handling
class SecureDataManager {
    func saveSecureData(key: String, value: Data) {
        // Use Keychain for sensitive data
        keychain.set(value, forKey: key, withAccess: .whenUnlocked)
    }
    
    func configureFileProtection(url: URL) {
        // Set file protection level
        setResourceValue(.completeFileProtection, forKey: .fileProtectionKey, at: url)
    }
}
```

### 8.1.2 Network Security (Future)

**If API integration is added:**
- Certificate pinning
- TLS 1.3 minimum
- Request signing
- Token-based authentication

### 8.1.3 Input Validation

**All user inputs validated:**
- Team/player names: max length, no special characters
- Jersey numbers: numeric only, max 3 digits
- Dates: reasonable range validation
- Scores: non-negative integers

## 8.2 Privacy

### 8.2.1 Data Privacy Policy

**Principles:**
- No data collection by developer
- No third-party analytics
- No advertising SDKs
- All data stays on device (unless user enables iCloud)

### 8.2.2 COPPA Compliance

**Requirements for children's data:**
- No user accounts required
- No personal information collected
- No sharing capabilities without parental control
- Safe for ages 4+

### 8.2.3 Privacy Manifest

**App Privacy Configuration:**
```xml
<!-- PrivacyInfo.xcprivacy -->
<plist>
  <dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
      <!-- No data collected -->
    </array>
    <key>NSPrivacyTrackingDomains</key>
    <array>
      <!-- No tracking domains -->
    </array>
  </dict>
</plist>
```

### 8.2.4 User Control

**Privacy Controls:**
- iCloud sync: User controlled, off by default
- Photo access: Only when user adds player photos
- Export data: User initiated only
- Data deletion: Complete team/player deletion available

## 8.3 Performance Requirements

### 8.3.1 Response Time Requirements

| Operation | Target | Maximum | Critical |
|-----------|--------|---------|----------|
| Stat recording | < 50ms | 100ms | Yes |
| Screen navigation | < 300ms | 500ms | No |
| Game list load | < 500ms | 1s | No |
| Stat calculation | < 100ms | 300ms | No |
| PDF export | < 3s | 10s | No |
| CSV export | < 1s | 3s | No |

### 8.3.2 Memory Requirements

**Constraints:**
- App launch: < 50MB
- Active game: < 150MB peak
- Background: < 30MB
- Memory warnings: Handle gracefully

**Memory Management Strategy:**
```swift
// Pseudo code for memory management
class MemoryManager {
    func handleMemoryWarning() {
        // Clear image cache
        ImageCache.shared.clearCache()
        
        // Release non-essential view models
        releaseInactiveViewModels()
        
        // Compact Core Data context
        context.refreshAllObjects()
    }
    
    func monitorMemoryUsage() {
        // Periodic memory checks
        if memoryUsage > threshold {
            performMemoryCleanup()
        }
    }
}
```

### 8.3.3 Battery Optimization

**Strategies:**
- No background processing
- Efficient Core Data queries
- Minimal animations during stat entry
- GPS/Location services: Not used
- Auto-save timer: Low frequency (30s)

### 8.3.4 Storage Optimization

**Data Management:**
```swift
// Pseudo code for storage management
class StorageManager {
    func estimateStorageUsage() -> StorageEstimate {
        // Database size
        databaseSize = calculateDatabaseSize()
        
        // Photo storage
        photoSize = calculateTotalPhotoSize()
        
        // Export cache
        exportCacheSize = calculateExportCacheSize()
        
        return StorageEstimate(
            total: databaseSize + photoSize + exportCacheSize,
            breakdown: [...]
        )
    }
    
    func cleanupOldExports() {
        // Delete exports older than 7 days
        deleteExportsOlderThan(days: 7)
    }
}
```

**Expected Storage:**
- Fresh install: ~15MB
- After 1 season (20 games): ~5MB data
- After 3 years: ~20-30MB data
- Photos (optional): 2-5MB per team

### 8.3.5 Launch Time Optimization

**Target: < 2 seconds cold launch**

**Optimization Strategies:**
```swift
// Pseudo launch optimization
func application(didFinishLaunching) {
    // Critical path only
    initializeCoreDataStack()
    checkOnboardingStatus()
    
    // Defer non-critical tasks
    DispatchQueue.main.async {
        setupNotifications()
        checkiCloudStatus()
        cleanupOldExports()
    }
}
```

### 8.3.6 Core Data Performance

**Query Optimization:**
- Indexed attributes on frequently queried fields
- Batch fetching for large result sets
- Faulting enabled for lists
- Background contexts for heavy operations

**Batch Operations:**
```swift
// Pseudo code for batch operations
func deleteOldGames(beforeDate: Date) {
    // Use batch delete for efficiency
    batchDeleteRequest = NSBatchDeleteRequest(
        fetchRequest: gamesBeforeDate(beforeDate)
    )
    
    executeInBackground(batchDeleteRequest)
}
```

---

<a name="deployment-dependencies"></a>
# 9. DEPLOYMENT & DEPENDENCIES

## 9.1 Development Environment

### 9.1.1 Required Tools

- **Xcode**: 15.0 or later
- **macOS**: Sonoma 14.0 or later
- **iOS Simulator**: iOS 16.0+
- **Git**: Version control

### 9.1.2 Development Dependencies

**None (Zero-dependency architecture)**

All functionality implemented using Apple's native frameworks:
- SwiftUI (UI)
- Combine (Reactive programming)
- Core Data (Persistence)
- PDFKit (PDF generation)
- MessageUI (Email)
- CloudKit (Optional sync)

## 9.2 Build Configuration

### 9.2.1 Build Schemes

**Debug:**
- Full symbols
- No optimization
- Debug logging enabled
- Development team signing

**Release:**
- Full optimization
- Strip debug symbols
- Logging disabled
- App Store distribution signing

### 9.2.2 Configuration Files

**Info.plist:**
```xml
<key>CFBundleDisplayName</key>
<string>Stats Tracker</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>LSRequiresIPhoneOS</key>
<true/>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arm64</string>
</array>

<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

## 9.3 App Store Deployment

### 9.3.1 App Information

- **Category**: Sports
- **Age Rating**: 4+
- **Price**: Free (with optional future in-app purchases)
- **Supported Languages**: English (initial), localizable architecture

### 9.3.2 Required Assets

**App Icons:**
- 1024x1024 (App Store)
- 180x180 (iPhone)
- 167x167 (iPad)
- 120x120, 87x87, 80x80, 76x76, 60x60, 58x58, 40x40, 29x29

**Screenshots:**
- iPhone 6.7" (required)
- iPhone 6.5" (required)
- iPhone 5.5" (optional)
- iPad Pro 12.9" (optional)

### 9.3.3 App Description

**Short Description (170 chars):**
"Track your child's basketball stats in real-time. Record points, rebounds, assists and more during games. Export detailed reports to share with coaches."

**Keywords:**
basketball, stats, tracker, youth sports, scoring, team, player statistics, game tracker, sports analytics

### 9.3.4 Privacy & Permissions

**Required Permissions:**
- Photos (optional): For player profile pictures
- Files: For export functionality

**Privacy Labels:**
- Data Not Collected
- Data Not Shared
- No Tracking

## 9.4 Version Strategy

### 9.4.1 Semantic Versioning

**Format: MAJOR.MINOR.PATCH**

- MAJOR: Breaking changes, major features
- MINOR: New features, backwards compatible
- PATCH: Bug fixes

**Examples:**
- 1.0.0: Initial release
- 1.1.0: Add Apple Watch support
- 1.1.1: Fix stat calculation bug
- 2.0.0: Add multi-team support

### 9.4.2 Release Checklist

**Pre-release:**
- [ ] All tests passing
- [ ] Code review completed
- [ ] Performance testing done
- [ ] Memory leaks checked
- [ ] Privacy manifest updated
- [ ] Screenshots updated
- [ ] Release notes written
- [ ] Version number incremented

**Post-release:**
- [ ] Monitor crash reports
- [ ] Track user feedback
- [ ] Monitor performance metrics
- [ ] Plan next iteration

## 9.5 Continuous Deployment

**Automated Pipeline:**
```yaml
# Pseudo CD configuration
on_push_to_main:
  - run_tests
  - increment_build_number
  - archive_app
  - upload_to_testflight
  
on_tag_creation:
  - run_full_test_suite
  - archive_release_build
  - submit_to_app_store_review
```

## 9.6 Monitoring & Analytics

### 9.6.1 Crash Reporting

**Built-in Tools:**
- Xcode Organizer crash logs
- MetricKit for performance metrics
- No third-party crash reporting (privacy)

### 9.6.2 Performance Monitoring

**Metrics to Track:**
- App launch time
- Screen transition times
- Stat recording latency
- Export completion times
- Memory usage patterns

**Implementation:**
```swift
// Pseudo performance monitoring
class PerformanceMonitor {
    func trackStatRecording() {
        let start = Date()
        
        // Record stat
        recordStat()
        
        let duration = Date().timeIntervalSince(start)
        
        // Log if exceeds threshold
        if duration > 0.1 {
            logSlowStatRecording(duration)
        }
    }
}
```

---

<a name="assumptions-gaps"></a>
# 10. ASSUMPTIONS & GAPS ANALYSIS

## 10.1 Assumptions Made

### 10.1.1 User Assumptions

1. **Single Team Focus**: User manages one team at a time
   - **Impact**: Simpler data model, easier navigation
   - **Risk**: May need multi-team support later

2. **One Focus Player Per Team**: Only tracking detailed stats for one child
   - **Impact**: Optimized UI for single-player tracking
   - **Risk**: Users may want to track multiple children

3. **Youth Basketball Rules**: Assumes standard youth basketball (quarters, standard stats)
   - **Impact**: UI optimized for common scenarios
   - **Risk**: May not fit all leagues/age groups

4. **Single Parent Usage**: One parent tracking during game
   - **Impact**: No real-time collaboration needed
   - **Risk**: Parents may want to share tracking duties

### 10.1.2 Technical Assumptions

1. **iOS 16+ Adoption**: Targeting iOS 16 and above
   - **Justification**: Modern SwiftUI features, ~85% user base
   - **Risk**: Excludes older devices

2. **Network Not Required**: Fully offline-capable app
   - **Impact**: Simpler architecture, better reliability
   - **Risk**: No cloud collaboration features

3. **Standard Basketball Stats**: Focus on traditional metrics
   - **Impact**: Well-understood, easy to implement
   - **Risk**: Advanced metrics requested later

4. **English Only (Initial)**: Starting with English localization
   - **Impact**: Faster initial development
   - **Risk**: Limits international market

### 10.1.3 Business Assumptions

1. **Free App Model**: No monetization initially
   - **Impact**: No payment integration complexity
   - **Risk**: Sustainability questions

2. **App Store Distribution**: Sole distribution channel
   - **Impact**: Simplified deployment
   - **Risk**: Subject to App Store policies

3. **No Backend Required**: Client-only application
   - **Impact**: Lower operational costs
   - **Risk**: Limited features (no social, cloud processing)

## 10.2 Identified Gaps

### 10.2.1 Feature Gaps

**Phase 1 Exclusions:**

1. **Advanced Analytics**
   - Shot charts with court locations
   - Defensive tracking
   - Plus/minus calculations
   - Advanced metrics (PER, Usage Rate, etc.)

2. **Multi-Team Management**
   - Switching between teams
   - Comparing across teams
   - Team history preservation

3. **Collaboration Features**
   - Real-time stat sharing
   - Multiple device sync
   - Coach/parent communication

4. **Video Integration**
   - Record game video
   - Tag stats to video timestamps
   - Video playback with stats overlay

5. **League Integration**
   - Import team rosters
   - Submit stats to league
   - League standings tracking

### 10.2.2 Technical Gaps

1. **Offline Conflict Resolution**
   - Current: Single device, no conflicts
   - Gap: Multi-device sync not implemented

2. **Data Migration**
   - Current: Core Data model versioning planned
   - Gap: Migration strategy not fully tested

3. **Accessibility**
   - Current: Basic VoiceOver support
   - Gap: Full accessibility audit needed
   - Gap: Voice control optimization

4. **Internationalization**
   - Current: English only
   - Gap: Localization infrastructure needs expansion
   - Gap: Date/number format variations

5. **Performance at Scale**
   - Current: Tested up to 100 games
   - Gap: Long-term performance (5+ years data) unknown

### 10.2.3 Documentation Gaps

1. **User Documentation**
   - In-app tutorial needed
   - Help documentation minimal
   - FAQ not created

2. **Developer Documentation**
   - API documentation incomplete
   - Architecture decisions not all documented
   - Contribution guidelines missing

3. **Operations Documentation**
   - Support procedures undefined
   - Escalation process not established
   - Common issues not documented

## 10.3 Risk Assessment

### 10.3.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Core Data migration issues | Medium | High | Comprehensive testing, versioning strategy |
| Performance degradation with large datasets | Medium | Medium | Optimize queries, implement archiving |
| iOS version compatibility issues | Low | Medium | Maintain iOS 16+ minimum, test on multiple versions |
| Export file compatibility | Low | Medium | Standard formats (CSV, PDF), extensive testing |

### 10.3.2 Product Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Users need multi-team support | High | Medium | Architecture supports future addition |
| Demand for real-time collaboration | Medium | High | Consider in Phase 2 |
| Advanced analytics requested | Medium | Medium | Modular design allows addition |
| Different sport requests | Low | Low | Out of scope, focus on basketball |

### 10.3.3 Business Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| App Store rejection | Low | High | Follow guidelines strictly, privacy focus |
| Limited user adoption | Medium | Medium | Focus on core value, word-of-mouth |
| Sustainability without revenue | High | Low | Consider freemium model later |
| Competitor apps | Medium | Medium | Differentiate on simplicity and speed |

## 10.4 Future Considerations

### 10.4.1 Short-term Improvements (3-6 months)

1. Apple Watch companion app
2. Widget support for current game
3. Siri Shortcuts integration
4. Enhanced PDF reports with charts
5. Season comparison views

### 10.4.2 Medium-term Enhancements (6-12 months)

1. Multi-team support
2. Shot chart visualization
3. Video integration
4. Advanced analytics
5. Social sharing features

### 10.4.3 Long-term Vision (12+ months)

1. Coach collaboration platform
2. League integration
3. AI-powered insights
4. Cross-platform (Android)
5. Web dashboard

## 10.5 Success Metrics

### 10.5.1 Technical Metrics

- **Crash-free rate**: > 99.5%
- **App launch time**: < 2 seconds
- **Stat recording latency**: < 100ms
- **Memory usage**: < 150MB peak
- **Test coverage**: > 80%

### 10.5.2 User Metrics

- **Onboarding completion**: > 80%
- **Games per user**: Average 10+ games
- **Weekly active users**: > 60% of installed base
- **Export usage**: > 30% of users
- **App Store rating**: > 4.5 stars

### 10.5.3 Business Metrics

- **Downloads**: 10,000 in first year
- **User retention**: > 60% after 1 month
- **Support tickets**: < 5% of active users
- **Positive reviews**: > 80% of reviews

---

## CONCLUSION

This architectural design document provides a comprehensive blueprint for building a basketball statistics tracking iOS application. The architecture prioritizes:

1. **Speed**: Optimized for 3-second stat recording requirement
2. **Simplicity**: Focus on core functionality, no unnecessary complexity
3. **Reliability**: Offline-first, robust error handling
4. **Privacy**: No data collection, user-controlled sync
5. **Maintainability**: Clean architecture, well-tested code

### Key Architectural Decisions

- **MVVM + Repository Pattern**: Clean separation of concerns
- **Zero Dependencies**: All native frameworks
- **Offline-First**: No network required for core functionality
- **Dual-Mode Interface**: Adapts to player status
- **Comprehensive Export**: CSV and PDF with multiple scopes

### Development Priorities

1. **Phase 1**: Core stat tracking and export (MVP)
2. **Phase 2**: Apple Watch, advanced analytics
3. **Phase 3**: Collaboration features, multi-team

### Next Steps

1. Set up project structure and Core Data model
2. Implement onboarding flow
3. Build live game interface (critical path)
4. Develop export system
5. Comprehensive testing
6. App Store submission

This architecture is designed to evolve with user needs while maintaining the core principles of speed, simplicity, and reliability.

# Architecture Gaps Analysis & Required Updates

## Document Review: User Requirements vs Architecture Design

### Executive Summary

After reviewing the user requirements document against the comprehensive architecture design, several gaps and clarifications have been identified. Most of the core requirements are well-addressed, but some specific user needs require architecture updates or clarifications.

-----

## 1. GAPS IDENTIFIED

### 1.1 Critical Gaps (Must Address)

#### Gap 1: Player Substitution Tracking

**Requirement:** “I have to switch active players as the real players change”
**Current Architecture:** Player status toggle exists (on court / on bench)
**Gap:** No explicit mechanism to track when players enter/exit the game or track minutes played accurately

**Required Update:**

```swift
// Add to StatEvent entity
@NSManaged public var substituteEventType: String?  // "PLAYER_IN", "PLAYER_OUT"

// Add to LiveGameViewModel
func recordSubstitution(playerId: UUID, eventType: SubstitutionType) {
    // Track player entrance/exit
    // Calculate minutes played
}

// Add substitution history tracking
struct SubstitutionEvent {
    let playerId: UUID
    let timestamp: Date
    let type: SubstitutionType // .playerIn, .playerOut
    let gameTime: String
}
```

#### Gap 2: Menu Switching vs Context Switching

**Requirement:** “by the time I have the play recorded I’m already trying to record the next play”
**Current Architecture:** Player status toggle changes UI mode
**Gap:** User interprets “switching active players” as changing between players, not just toggling on/off status

**Clarification Needed:**

- Current design: Focus player toggle (on bench vs playing)
- User may want: Quick switch between multiple players being tracked
- **Decision:** Keep current design BUT add quick player selector if needed

**Potential Enhancement:**

```swift
// Optional: Quick player switcher (Phase 2)
struct QuickPlayerSwitcher: View {
    // Swipe gesture to change which player is being tracked in detail
    // Only show when multiple players need detailed tracking
}
```

#### Gap 3: Opponent Scoring Workflow

**Requirement:** Implied need to track opponent score
**Current Architecture:** Small +2/+3 buttons in top status bar
**Gap:** May be too small or awkward to reach during fast gameplay

**Update Required:**

- Reconsider opponent scoring button placement
- May need larger buttons or different interaction model
- Consider haptic feedback differentiation (opponent vs team scoring)

### 1.2 Important Gaps (Should Address)

#### Gap 4: “Standard Basketball Statistics” Definition

**Requirement:** “The data need to include all standard basketball statistics with the data I specified”
**Current Architecture:** Tracks specified stats (FT, 2PT, 3PT, REB, AST, STL, BLK)
**Gap:** Unclear if “all standard statistics” includes:

- Turnovers (mentioned in architecture but not initial requirements)
- Fouls (mentioned in architecture but not initial requirements)
- Minutes played (needed for proper statistics)
- Field goal attempts vs makes breakdown

**Update Required:**

```swift
// Clarify in StatType enum - ALREADY INCLUDED but confirm with user
case turnover = "TURNOVER"  // ✓ Included
case foul = "FOUL"          // ✓ Included

// Add minutes played tracking
@NSManaged public var minutesPlayed: Int32  // in GamePlayer entity ✓
```

**Status:** Architecture already includes these - just needs user confirmation

#### Gap 5: Export Requirements Specificity

**Requirement:** “I’d like to be able to export either a single game, season, or lifetime”
**Current Architecture:** Export functionality included
**Gap:** User document doesn’t specify if they need specific format requirements or what fields must be in export

**Update Required:**

- Add user review of CSV/PDF export formats
- Confirm which statistics are most important in exports
- Verify export meets coaching/league requirements

#### Gap 6: Multiple Teams/Seasons Over Lifetime

**Requirement:** “I’d like to be able to keep the data on my phone for review as well”
**Current Architecture:** Single team focus initially, multi-team in Phase 2
**Gap:** If child changes teams, how is data maintained?

**Clarification Needed:**

```swift
// Current: One team with one season
// User need: Multiple seasons, potentially multiple teams over time

// Proposed Solution:
// Phase 1: Single active team, can create new team for new season
// Archive old team data rather than delete
// Phase 2: Proper multi-team management
```

### 1.3 Minor Gaps (Nice to Have)

#### Gap 7: Bleacher Environment Considerations

**Requirement:** “Usually sitting in the stands, the bleachers can vary greatly from very small to 25 rows of benches”
**Current Architecture:** No specific environmental considerations
**Enhancement:** Consider:

- Brightness/contrast optimization for outdoor games
- Larger tap targets for awkward angles
- Glare-resistant color scheme

#### Gap 8: Data Backup/Loss Prevention

**Requirement:** Implied by “keep the data on my phone”
**Current Architecture:** Auto-save every 30 seconds, optional iCloud
**Gap:** No explicit mention of data backup reminders or recovery options

**Enhancement:**

```swift
// Add backup reminder system
class BackupReminderManager {
    func checkBackupStatus() {
        if !iCloudEnabled && gamesCount > 10 {
            showBackupReminder()
        }
    }
}
```

-----

## 2. ARCHITECTURE CONFIRMATIONS

### 2.1 Requirements Well-Addressed

✅ **Stat Collection:** All specified stats (FT, 2PT, 3PT, REB, AST, STL, BLK) fully implemented

✅ **Team Scoring:** Points for all players tracked, focus player gets detailed stats

✅ **Missed Attempts:** Architecture includes both made and missed for all shot types

✅ **Speed Requirement:** 3-second recording interval addressed with single-tap buttons

✅ **Two-Handed Operation:** Button sizes and layout support two-handed use

✅ **Context Switching:** Dual-mode interface (player on court vs bench) addresses this

✅ **Export Functionality:** CSV and PDF export for game/season/lifetime implemented

✅ **Data Persistence:** Core Data with optional iCloud sync

✅ **Physical Environment:** Supports sitting and standing positions

-----

## 3. REQUIRED ARCHITECTURE UPDATES

### 3.1 High Priority Updates

#### Update 1: Enhance Player Tracking

**Add to Section 3 (Data Architecture):**

```swift
// GamePlayer entity enhancement
@NSManaged public var timeIn: Date?
@NSManaged public var timeOut: Date?
@NSManaged public var totalMinutesPlayed: Int32

// Add substitution tracking
enum SubstitutionType: String {
    case playerIn = "PLAYER_IN"
    case playerOut = "PLAYER_OUT"
}

// New tracking in LiveGameViewModel
class LiveGameViewModel {
    private var playerTimeTracker: [UUID: Date] = [:]
    
    func trackPlayerEntry(_ playerId: UUID) {
        playerTimeTracker[playerId] = Date()
    }
    
    func trackPlayerExit(_ playerId: UUID) {
        if let entryTime = playerTimeTracker[playerId] {
            let minutesPlayed = Date().timeIntervalSince(entryTime) / 60
            updatePlayerMinutes(playerId, minutes: Int(minutesPlayed))
        }
    }
}
```

#### Update 2: Improve Opponent Scoring UX

**Add to Section 4.4 (Live Game View):**

```swift
// Enhanced opponent scoring section
private var opponentScoringSection: some View {
    VStack(spacing: Spacing.sm) {
        Text("Opponent: \(opponentScore)")
            .font(.titleLarge)
        
        HStack(spacing: Spacing.md) {
            // Larger, more accessible buttons
            Button(action: { recordOpponentScore(2) }) {
                Text("+2")
                    .frame(width: 60, height: 50)
                    .background(Color("StatOrange"))
                    .cornerRadius(8)
            }
            
            Button(action: { recordOpponentScore(3) }) {
                Text("+3")
                    .frame(width: 60, height: 50)
                    .background(Color("StatOrange"))
                    .cornerRadius(8)
            }
            
            // Add undo for opponent score
            Button(action: { undoOpponentScore() }) {
                Image(systemName: "arrow.uturn.backward")
                    .frame(width: 50, height: 50)
            }
        }
    }
}
```

#### Update 3: Clarify Statistics Scope

**Add to Section 5 (Business Logic):**

```swift
// Comprehensive stat types - confirm with user
enum StandardBasketballStats {
    // Scoring (CONFIRMED)
    case points, fieldGoals, threePointers, freeThrows
    
    // Other stats (CONFIRMED)
    case rebounds, assists, steals, blocks
    
    // Additional stats (TO BE CONFIRMED)
    case turnovers  // Should this be tracked for focus player?
    case fouls      // Should this be tracked for focus player?
    
    // Time tracking (NEW REQUIREMENT)
    case minutesPlayed  // Essential for per-minute stats
}
```

### 3.2 Medium Priority Updates

#### Update 4: Multi-Season Support

**Add to Section 10 (Assumptions & Gaps):**

```
ASSUMPTION UPDATE:
- Original: Single team/season focus
- Revised: Support season transitions within same team
- Implementation: 
  - Allow marking season as "Complete"
  - Create new season for same team
  - Maintain historical data for all seasons
  - Season comparison views
```

#### Update 5: Environmental Adaptations

**Add to Section 8 (Performance):**

```swift
// Display adaptation for varying conditions
class DisplayManager {
    func optimizeForEnvironment(_ environment: GameEnvironment) {
        switch environment {
        case .indoorGym:
            // Standard contrast
            applyStandardBrightness()
            
        case .outdoorSunny:
            // High contrast, bright mode
            applyHighContrast()
            increaseBrightness()
            
        case .dimLighting:
            // Reduce glare, softer colors
            applyLowLightMode()
        }
    }
}
```

### 3.3 Clarifications Needed from User

**Questions for User:**

1. **Player Switching:**
- Is the focus player toggle (on court/bench) sufficient?
- Or do you need to quickly switch between tracking different players in detail?
1. **Turnovers and Fouls:**
- Should these be tracked for the focus player?
- Or only points, rebounds, assists, steals, blocks as specified?
1. **Minutes Played:**
- Do you need accurate minutes played tracking?
- Or just whether player was on court during the game?
1. **Opponent Details:**
- Just track total opponent score?
- Or track individual opponent players too?
1. **Multiple Seasons:**
- Will the child stay on the same team across seasons?
- Or might they change teams requiring separate team management?

-----

## 4. UPDATED ASSUMPTIONS

### Original Assumptions to Revise:

1. **REVISED:** ~“Single season focus”~ → Support multiple seasons per team with archiving
1. **REVISED:** ~“Opponent score is secondary”~ → Opponent scoring needs equal priority to team scoring
1. **ADDED:** “User needs complete game statistics including minutes played for proper per-minute calculations”
1. **ADDED:** “Physical environment (bleachers, lighting) may vary significantly and affect usability”
1. **ADDED:** “Data longevity is critical - must support multiple years without performance degradation”

-----

## 5. PRIORITY ACTION ITEMS

### Immediate (Before Implementation):

1. ✅ Confirm with user: Which stats are mandatory vs optional
1. ✅ Clarify: Player switching requirement (toggle vs multi-player tracking)
1. ✅ Validate: Export format meets their needs (show samples)
1. ⚠️ Update: Architecture to include minutes played tracking
1. ⚠️ Enhance: Opponent scoring UX for better accessibility

### Phase 1 Enhancements:

1. Add player time tracking (entry/exit from game)
1. Improve opponent scoring button placement and size
1. Add environmental display adaptations
1. Implement season transition workflow

### Phase 2 Considerations:

1. Multi-team management (if child changes teams)
1. Advanced statistics requiring minutes played
1. Shot location tracking for focus player
1. Comparative analytics across seasons

-----

## 6. CONCLUSION

The architecture design is **85% aligned** with user requirements. The main gaps are:

**Critical:**

- Minutes played tracking (needed for complete statistics)
- Opponent scoring UX needs enhancement
- Player substitution tracking not fully specified

**Important:**

- Multi-season support needs clearer definition
- Environmental considerations should be incorporated

**Recommendations:**

1. **Implement immediately:** Minutes played tracking, enhanced opponent scoring UI
1. **Clarify with user:** Exact stat requirements, player switching needs
1. **Plan for Phase 1:** Season transitions, environmental adaptations
1. **Phase 2:** Multi-team support, advanced analytics

The core architecture is sound and addresses the main user needs. The gaps identified are primarily enhancements and clarifications rather than fundamental flaws.

**Next Steps:**

1. Review this gap analysis with the user
1. Get confirmation on the clarification questions
1. Update architecture documents with confirmed requirements
1. Proceed with implementation using updated specifications