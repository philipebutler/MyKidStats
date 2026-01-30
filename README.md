# MyKidStats 🏀

A native iOS app for real-time basketball statistics tracking, built for parents who want to accurately capture their children's game performance.

![iOS](https://img.shields.io/badge/iOS-26.2%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## 📱 Overview

MyKidStats is designed for the sidelines—fast, intuitive stat tracking that works in 3-second action windows. Track detailed basketball statistics for multiple children across different teams and seasons, with automatic career stats aggregation.

### Key Features

- **⚡ Lightning Fast** - Record stats in under 50ms with optimized touch targets
- **👥 Multi-Child Support** - Track stats for multiple children, each with independent career records
- **📊 Comprehensive Stats** - Track 13+ basketball statistics including shooting, rebounds, assists, steals, blocks, turnovers, and fouls
- **🎯 Smart Defaults** - Remembers your last-used child and automatically focuses the right player
- **👨‍👩‍👧‍👦 Team Scoring** - Quick scoring for all teammates with jersey numbers
- **📈 Career Stats** - Automatic aggregation across teams and seasons
- **📤 Export & Share** - Share game summaries via text or files
- **🌙 Dark Mode** - Fully supports iOS dark mode with semantic colors
- **♿ Accessibility** - Dynamic Type support and iOS accessibility features
- **📴 Offline First** - No internet required; all data stored locally

## 🎯 Core Functionality

### Live Game Tracking
- **Focus Player Stats**: Large, optimized buttons (75pt) for recording your child's performance
- **Team Scoring**: Compact team roster for quick scoring of teammates
- **Opponent Score**: Track opponent scoring separately
- **Undo Last Action**: Floating undo button following iOS patterns

### Statistics Tracked
- **Shooting**: 2PT made/missed, 3PT made/missed, FT made/missed
- **Performance**: Rebounds, Assists, Steals, Blocks
- **Discipline**: Turnovers, Fouls

### Game Summary
After each game:
- Complete stat breakdown for your focus child
- Shooting percentages (FG%, 3P%, FT%)
- Season comparison (game vs. season average)
- Final score
- Shareable summary

## 🏗️ Architecture

### Technology Stack
- **Platform**: iOS 26.2+
- **Framework**: SwiftUI
- **Data**: Core Data with iCloud sync
- **Design**: iOS-native UI with SF Symbols

### Core Data Model
- **Child**: Player profiles with career stats
- **Team**: Team information and rosters
- **Player**: Links children to teams (junction table)
- **Game**: Individual game records
- **StatEvent**: Every stat recorded with undo support

### Design Principles
1. **Speed First**: Every interaction optimized for sideline use
2. **iOS-Native**: Semantic colors, SF Symbols, Dynamic Type
3. **Offline First**: No network dependency for core features
4. **Progressive Disclosure**: Advanced features don't clutter the main flow

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 17+
- iOS 26.2+ simulator or device
- Apple Developer account (for device testing)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/philipebutler/MyKidStats.git
cd MyKidStats
```

2. **Open in Xcode**
```bash
open MyKidStats.xcodeproj
```

3. **Build and Run**
- Select a simulator or connected device
- Press `⌘R` to build and run
- Or use the menu: Product → Run

### Running Tests

```bash
# Run all unit tests
xcodebuild test -scheme MyKidStats -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Or in Xcode
⌘U
```

## 📖 Usage

### First Time Setup
1. Launch the app
2. Add your first child from the Home screen
3. Create a team (name, season, organization)
4. Add your child and teammates to the team roster

### Starting a Game
1. Navigate to Home tab
2. Tap "Start Game" for your child
3. Select the team
4. Enter opponent name
5. Begin tracking stats!

### During the Game
- **Tap stat buttons** to record your child's performance
- **Tap teammate rows** to score for other players
- **Tap opponent score buttons** to track opponent
- **Use undo button** to correct mistakes
- Stats update in real-time with haptic feedback

### After the Game
1. Tap "End Game" button
2. View game summary with complete stats
3. Share summary via text or export to Files
4. Summary includes season comparison

## 🗂️ Project Structure

```
MyKidStats/
├── MyKidStats/
│   ├── MyKidStatsApp.swift          # App entry point
│   ├── ContentView.swift             # Main tab container
│   ├── Core/
│   │   ├── Data/                     # Core Data stack
│   │   ├── Domain/                   # Business logic
│   │   └── Navigation/               # Navigation coordinator
│   ├── Features/
│   │   ├── Home/                     # Home screen
│   │   ├── LiveGame/                 # Live game tracking
│   │   ├── Stats/                    # Career stats view
│   │   └── Teams/                    # Team management
│   ├── DesignSystem/
│   │   ├── Colors.swift              # Semantic color system
│   │   ├── Fonts.swift               # Typography scale
│   │   ├── Spacing.swift             # Layout constants
│   │   └── Components/               # Reusable UI components
│   └── Assets.xcassets/              # App icon and assets
├── MyKidStatsTests/                  # Unit tests
├── Documentation/                    # Architecture & design docs
└── README.md                         # This file
```

## 🎨 Design System

### Button Sizes (Optimized for Touch)
- **Focus Player Stats**: 75pt (most frequent actions)
- **Team Scoring**: 48pt (frequent actions)
- **Opponent Scoring**: 52pt (moderate frequency)
- **Undo**: 50pt (occasional but important)

### Color System
- Uses iOS semantic colors for automatic dark mode
- Custom accent colors for stat types (made, missed, positive, negative)
- Fully accessible with proper contrast ratios

### Typography
- System fonts with Dynamic Type support
- Specialized fonts for game timer and large scores
- Minimum scale factor for compact displays

## 🧪 Testing

The app includes comprehensive unit tests covering:
- Live stats calculation and aggregation
- Career stats computation
- Stat type definitions and behavior
- Game flow and state management
- Navigation coordination
- Export functionality
- Performance tests for critical paths

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👨‍💻 Author

**Philip Butler**
- GitHub: [@philipebutler](https://github.com/philipebutler)

## 🙏 Acknowledgments

- Built with SwiftUI and Core Data
- Icons from SF Symbols
- Follows iOS Human Interface Guidelines
- Inspired by the need for better youth sports stat tracking

## 📝 Version History

- **v1.0** (January 2026)
  - Initial release
  - Multi-child support
  - Live game tracking
  - Career stats aggregation
  - Export and sharing
  - iOS-native design system

---

**Built with ❤️ for basketball parents everywhere**
