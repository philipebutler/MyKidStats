//
//  HelpTopic.swift
//  MyKidStats
//
//  Created by Copilot on 2/1/26.
//

import SwiftUI

enum HelpCategory: String, CaseIterable, Identifiable {
    case gettingStarted = "Getting Started"
    case coreFeatures = "Core Features"
    case tipsAndTricks = "Tips & Tricks"
    case aboutSupport = "About & Support"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .gettingStarted: return "star.fill"
        case .coreFeatures: return "square.grid.2x2.fill"
        case .tipsAndTricks: return "lightbulb.fill"
        case .aboutSupport: return "info.circle.fill"
        }
    }
    
    var topics: [HelpTopic] {
        switch self {
        case .gettingStarted:
            return [.welcome, .quickStart, .appOverview]
        case .coreFeatures:
            return [.managingPlayers, .teamsAndSeasons, .trackingGames, .statsAndAnalysis, .sharingExport]
        case .tipsAndTricks:
            return [.bestPractices, .troubleshooting]
        case .aboutSupport:
            return [.aboutApp, .dataManagement]
        }
    }
}

enum HelpTopic: String, CaseIterable, Identifiable {
    case welcome = "Welcome to MyKidStats"
    case quickStart = "Quick Start Guide"
    case appOverview = "App Overview"
    case managingPlayers = "Managing Players"
    case teamsAndSeasons = "Teams & Seasons"
    case trackingGames = "Tracking Games"
    case statsAndAnalysis = "Stats & Analysis"
    case sharingExport = "Sharing & Export"
    case bestPractices = "Best Practices"
    case troubleshooting = "Troubleshooting"
    case aboutApp = "About the App"
    case dataManagement = "Data Management"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .welcome: return "hand.wave.fill"
        case .quickStart: return "bolt.fill"
        case .appOverview: return "map.fill"
        case .managingPlayers: return "person.2.fill"
        case .teamsAndSeasons: return "person.3.fill"
        case .trackingGames: return "play.circle.fill"
        case .statsAndAnalysis: return "chart.bar.fill"
        case .sharingExport: return "square.and.arrow.up"
        case .bestPractices: return "star.circle.fill"
        case .troubleshooting: return "wrench.and.screwdriver.fill"
        case .aboutApp: return "info.circle"
        case .dataManagement: return "externaldrive.fill"
        }
    }
    
    var category: HelpCategory {
        switch self {
        case .welcome, .quickStart, .appOverview:
            return .gettingStarted
        case .managingPlayers, .teamsAndSeasons, .trackingGames, .statsAndAnalysis, .sharingExport:
            return .coreFeatures
        case .bestPractices, .troubleshooting:
            return .tipsAndTricks
        case .aboutApp, .dataManagement:
            return .aboutSupport
        }
    }
    
    var content: HelpContent {
        switch self {
        case .welcome:
            return HelpContent(
                title: "Welcome to MyKidStats",
                sections: [
                    HelpSection(
                        title: "Track Your Child's Basketball Journey",
                        body: "MyKidStats is designed for parents who want to accurately capture their children's basketball game performance. Whether you're courtside at a game or helping your child track their progress, this app makes it fast and easy to record detailed statistics.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Key Features",
                        body: """
                        • Lightning-fast stat recording during live games
                        • Track multiple children across different teams
                        • Comprehensive basketball statistics
                        • Automatic career stats aggregation
                        • Share game summaries instantly
                        • Works completely offline
                        """,
                        imageName: nil
                    )
                ]
            )
            
        case .quickStart:
            return HelpContent(
                title: "Quick Start Guide",
                sections: [
                    HelpSection(
                        title: "Get Started in 5 Steps",
                        body: "Follow these steps to start tracking your first game:",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "1. Add Your Child",
                        body: "Tap the 'Players' tab at the bottom, then tap the '+' button to add your child's name and basic information.",
                        imageName: "screenshot-add-child"
                    ),
                    HelpSection(
                        title: "2. Create a Team",
                        body: "Go to the 'Teams' tab and create a team for your child. Enter the team name, season, and optionally add team colors and organization details.",
                        imageName: "screenshot-create-team"
                    ),
                    HelpSection(
                        title: "3. Start a New Game",
                        body: "From the 'Home' tab, tap 'Start New Game' on your child's card. Select the team and optionally enter the opponent's name.",
                        imageName: "screenshot-start-game"
                    ),
                    HelpSection(
                        title: "4. Record Stats",
                        body: "During the game, tap the large buttons to record your child's stats in real-time. Use the team scoring section to track teammates' points.",
                        imageName: "screenshot-live-game"
                    ),
                    HelpSection(
                        title: "5. View Game Summary",
                        body: "Tap 'End Game' when finished to see the complete game summary with stats, percentages, and the option to share results.",
                        imageName: "screenshot-game-summary"
                    )
                ]
            )
            
        case .appOverview:
            return HelpContent(
                title: "App Overview",
                sections: [
                    HelpSection(
                        title: "Navigation Tabs",
                        body: "The app has five main tabs:",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "🏠 Home",
                        body: "View recent activity, start new games, and access quick actions. Shows your children's last games and upcoming features.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "▶️ Live",
                        body: "Track games in real-time. This tab activates when you start a game and shows all active games. The interface is optimized for quick stat recording during live action.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "📊 Stats",
                        body: "View comprehensive career statistics for each child. See shooting percentages, career highs, and performance breakdown by team and season.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "👥 Teams",
                        body: "Manage teams, add players, and view team history. Create new teams for different seasons or organizations.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "👤 Players",
                        body: "Manage your children's profiles. Add new children, edit information, and view their teams and game history.",
                        imageName: nil
                    )
                ]
            )
            
        case .managingPlayers:
            return HelpContent(
                title: "Managing Players",
                sections: [
                    HelpSection(
                        title: "Adding Your First Child",
                        body: "Navigate to the 'Players' tab and tap the '+' button in the top right corner. Enter your child's name and optionally add their date of birth. You can add multiple children if you're tracking stats for more than one player.",
                        imageName: "screenshot-add-child"
                    ),
                    HelpSection(
                        title: "Editing Player Information",
                        body: "Tap on a child's name in the Players tab to view their details. You can update their name, date of birth, and see all teams they're associated with.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Multiple Children",
                        body: "MyKidStats supports tracking stats for multiple children. Each child has their own independent career statistics, teams, and game history. When starting a game or viewing stats, select which child you want to focus on.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Player vs. Teammate",
                        body: "In the app, a 'Player' refers to your child on a specific team. Your child is tracked with full detailed stats. Teammates on the same team can have their scoring tracked during games, but won't have individual career stats unless you add them as children.",
                        imageName: nil
                    )
                ]
            )
            
        case .teamsAndSeasons:
            return HelpContent(
                title: "Teams & Seasons",
                sections: [
                    HelpSection(
                        title: "Creating a Team",
                        body: "Teams represent the different squads your child plays for (e.g., school team, rec league, travel team). To create a team, go to the Teams tab and tap the '+' button. Enter the team name, season (e.g., 'Fall 2026'), and optional organization name.",
                        imageName: "screenshot-create-team"
                    ),
                    HelpSection(
                        title: "Team Details",
                        body: """
                        When creating a team, you can customize:
                        
                        • Team Name: The name of the team
                        • Season: The season/year (e.g., "Fall 2026", "Spring 2025")
                        • Organization: League or school name (optional)
                        • Team Colors: Choose a color to identify the team
                        • Jersey Number: Your child's number on this team
                        • Position: Your child's position (optional)
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Multiple Teams",
                        body: "Your child can be on multiple teams. Each team has separate stats and history. When starting a game, you'll select which team is playing. Career stats automatically aggregate across all teams.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Adding Teammates",
                        body: "From the Teams tab, you can add other players to the team roster. This allows you to quickly track their scoring during games. Enter their name and jersey number to make game-time recording easier.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Managing Teams",
                        body: "You can mark teams as inactive when the season ends, but their stats remain in your child's career history. This keeps your active team list clean while preserving historical data.",
                        imageName: nil
                    )
                ]
            )
            
        case .trackingGames:
            return HelpContent(
                title: "Tracking Games",
                sections: [
                    HelpSection(
                        title: "Starting a Game",
                        body: "From the Home tab, tap 'Start New Game' on your child's card. Select the team that's playing and optionally enter the opponent's name. The app automatically switches to the Live tab to begin tracking.",
                        imageName: "screenshot-start-game"
                    ),
                    HelpSection(
                        title: "Live Game Interface",
                        body: "The live game screen is optimized for speed and simplicity during games. The top shows the current score (your team vs opponent). Large buttons for your child's stats are in the center, with team scoring at the bottom.",
                        imageName: "screenshot-live-game"
                    ),
                    HelpSection(
                        title: "Recording Your Child's Stats",
                        body: """
                        Tap the large buttons to record stats:
                        
                        🎯 2PT: Two-point field goal (made/missed)
                        🏹 3PT: Three-point field goal (made/missed)
                        🎯 FT: Free throw (made/missed)
                        🔄 REB: Rebound
                        🤝 AST: Assist
                        ⚡ STL: Steal
                        🛡️ BLK: Block
                        ❌ TO: Turnover
                        
                        For made/missed shots, tap the green checkmark for made or red X for missed. Points are automatically added to your team's score.
                        """,
                        imageName: "screenshot-stat-buttons"
                    ),
                    HelpSection(
                        title: "Team Scoring",
                        body: "Scroll down to see the Team Scoring section. Here you can quickly tap +1, +2, or +3 buttons next to teammates' names to record their scoring. This gives context to your child's performance without tracking full stats for everyone.",
                        imageName: "screenshot-team-scoring"
                    ),
                    HelpSection(
                        title: "Opponent Score",
                        body: "Update the opponent's score using the +/- buttons at the top of the screen. This helps track the game's context and competitiveness.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Using Undo",
                        body: "Made a mistake? Tap the 'Undo' button at the bottom of the screen to reverse the last action. This works for your child's stats, team scoring, and opponent score changes.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Sharing During the Game",
                        body: "Want to share stats mid-game? Tap the share icon in the top right corner to send a text summary of the current stats to family, friends, or your group chat.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Ending the Game",
                        body: "When the game is over, tap the red 'End Game' button at the bottom. This marks the game as complete and shows the game summary with full stats, percentages, and season comparisons.",
                        imageName: "screenshot-end-game"
                    )
                ]
            )
            
        case .statsAndAnalysis:
            return HelpContent(
                title: "Stats & Analysis",
                sections: [
                    HelpSection(
                        title: "Career Stats Overview",
                        body: "The Stats tab shows comprehensive career statistics aggregated across all games and teams. If you have multiple children, use the dropdown menu at the top to switch between them.",
                        imageName: "screenshot-career-stats"
                    ),
                    HelpSection(
                        title: "Statistics Explained",
                        body: """
                        Understanding the key stats:
                        
                        • Games Played: Total games recorded
                        • PPG: Points per game average
                        • FG%: Field goal percentage (all made shots / all attempts)
                        • 3P%: Three-point percentage
                        • FT%: Free throw percentage
                        • RPG: Rebounds per game
                        • APG: Assists per game
                        • SPG: Steals per game
                        • BPG: Blocks per game
                        • TPG: Turnovers per game
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Shooting Breakdown",
                        body: "The shooting section shows detailed made/attempted stats for 2-pointers, 3-pointers, and free throws, along with percentages. This helps identify areas of strength and opportunities for improvement.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Career Highs",
                        body: "See your child's best single-game performances across all stats. This includes career high points, rebounds, assists, steals, and blocks.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Team Breakdown",
                        body: "View stats broken down by team and season. This shows how your child performs with different teams and tracks improvement over time.",
                        imageName: "screenshot-team-breakdown"
                    ),
                    HelpSection(
                        title: "Game History",
                        body: "Access the Past Games section (coming soon) to review individual game performances, compare games, and track trends over the season.",
                        imageName: nil
                    )
                ]
            )
            
        case .sharingExport:
            return HelpContent(
                title: "Sharing & Export",
                sections: [
                    HelpSection(
                        title: "Share Game Summary",
                        body: "After a game or from the game history, tap the share icon to send a text summary. The summary includes the final score, your child's complete stat line with percentages, and game details.",
                        imageName: "screenshot-share"
                    ),
                    HelpSection(
                        title: "Share Options",
                        body: "The iOS share sheet lets you send game summaries via Messages, Mail, Notes, or any other app that accepts text. It's optimized for text messaging so you can quickly update family members after games.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Summary Format",
                        body: """
                        The shared summary includes:
                        
                        • Game date and opponent
                        • Final score
                        • Your child's complete stat line
                        • Shooting percentages (FG%, 3P%, FT%)
                        • Breakdown of 2PT, 3PT, and FT shooting
                        • Rebounds, assists, steals, blocks, turnovers
                        
                        Example:
                        "Game vs Warriors - W 45-42
                        Sarah: 18 PTS, 5 REB, 3 AST
                        FG: 7/12 (58%), 3P: 2/4 (50%), FT: 2/3 (67%)"
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Share Anytime",
                        body: "You can share game summaries at any time - during the game, immediately after, or weeks later when reviewing past games. Stats are always preserved and accessible.",
                        imageName: nil
                    )
                ]
            )
            
        case .bestPractices:
            return HelpContent(
                title: "Best Practices",
                sections: [
                    HelpSection(
                        title: "During Live Games",
                        body: """
                        Tips for accurate stat tracking:
                        
                        • Focus on your child's actions first - teammate scoring can be updated during breaks
                        • Use the undo button immediately if you make a mistake
                        • Don't worry about perfection - some stats are judgment calls
                        • Update opponent score periodically to maintain game context
                        • Record stats as they happen rather than trying to remember multiple plays
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Organizing Teams",
                        body: """
                        Keep your teams organized:
                        
                        • Use clear season labels (e.g., "Fall 2026", "Winter 2025-26")
                        • Include organization names for clarity ("Lincoln Middle School", "City Rec League")
                        • Choose distinct team colors to quickly identify teams
                        • Add all regular teammates with jersey numbers for quick game-time entry
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Recording Stats Accurately",
                        body: """
                        Guidelines for common scenarios:
                        
                        • Rebound: Record when your child secures possession after a missed shot
                        • Assist: Record when your child's pass directly leads to a made basket
                        • Steal: Record when your child takes the ball from an opponent
                        • Block: Record when your child deflects an opponent's shot attempt
                        • Turnover: Record when your child loses possession (bad pass, traveling, etc.)
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Using Multiple Devices",
                        body: "Each device maintains its own local data. If you use multiple devices (e.g., iPhone and iPad), data won't automatically sync. Choose one primary device for tracking to keep stats consistent.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Regular Backups",
                        body: "While the app stores all data locally on your device, consider periodically using the 'Share Game Summary' feature to keep text records of important games. You can also take screenshots of career stats as informal backups.",
                        imageName: nil
                    )
                ]
            )
            
        case .troubleshooting:
            return HelpContent(
                title: "Troubleshooting",
                sections: [
                    HelpSection(
                        title: "Game Not Starting",
                        body: """
                        If you can't start a game:
                        
                        • Make sure you've added at least one child (Players tab)
                        • Verify the child has at least one team (Teams tab)
                        • Try closing and reopening the app
                        • Check that you don't already have an active game for that child
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Stats Not Saving",
                        body: """
                        If stats aren't being recorded:
                        
                        • Ensure you see visual feedback when tapping buttons (they should briefly highlight)
                        • Check that the score updates after recording made shots
                        • Verify you tapped 'End Game' before leaving the Live tab
                        • If a game is abandoned, stats may not be saved - always end games properly
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Missing Teams or Players",
                        body: """
                        If teams or players aren't appearing:
                        
                        • Check that the team is marked as 'Active'
                        • Verify the player/child was properly saved (look in Players tab)
                        • Make sure you're looking at the correct child (check dropdown if you have multiple)
                        • Try restarting the app
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Incorrect Stats",
                        body: """
                        To fix incorrect stats:
                        
                        • Use the Undo button during a live game
                        • After a game ends, stats are saved and can't be edited (this preserves data integrity)
                        • For future games, use the Undo feature immediately when you spot errors
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "App Performance Issues",
                        body: """
                        If the app is slow or unresponsive:
                        
                        • Close and restart the app
                        • Ensure your device has adequate storage space
                        • Update to the latest version of the app if available
                        • Restart your device if problems persist
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Still Having Issues?",
                        body: "If you continue to experience problems, please report them on our GitHub repository. Go to Settings → Support → GitHub Repository to file an issue with details about the problem.",
                        imageName: nil
                    )
                ]
            )
            
        case .aboutApp:
            return HelpContent(
                title: "About the App",
                sections: [
                    HelpSection(
                        title: "MyKidStats",
                        body: "A native iOS app designed for parents who want to accurately track their children's basketball game performance. Built with SwiftUI for a fast, modern experience.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Development Philosophy",
                        body: "MyKidStats is designed around real-world use at the sidelines. Every feature prioritizes speed and simplicity because you're tracking stats during 3-second action windows while watching the game.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Privacy & Data",
                        body: "All your data stays on your device. MyKidStats works completely offline and doesn't send any information to external servers. Your children's stats and personal information remain private and under your control.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Open Source",
                        body: "MyKidStats is open source and available on GitHub. You can view the code, contribute improvements, or report issues. Find the link in Settings → Support.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Future Plans",
                        body: """
                        Planned features include:
                        
                        • Enhanced game history with filtering and search
                        • Data export to CSV for external analysis
                        • Shot charts and heat maps
                        • Player comparison tools
                        • Practice mode for tracking training sessions
                        """,
                        imageName: nil
                    )
                ]
            )
            
        case .dataManagement:
            return HelpContent(
                title: "Data Management",
                sections: [
                    HelpSection(
                        title: "Local Storage",
                        body: "All data is stored locally on your device using Core Data, Apple's framework for persistent storage. This means your stats are always available offline and load instantly.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Data Structure",
                        body: """
                        The app organizes data hierarchically:
                        
                        • Children (your kids)
                          └─ Players (instances on specific teams)
                             └─ Games
                                └─ Stat Events
                        
                        This structure allows the same child to play on multiple teams while maintaining career-wide statistics.
                        """,
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Backups",
                        body: "Your MyKidStats data is included in your device's standard iOS backups (iCloud or iTunes/Finder). If you restore your device from a backup, all your stats will be restored.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Deleting Data",
                        body: "You can reset all data from Settings → Data Management → Reset All Data. This permanently deletes all children, teams, games, and statistics. This action cannot be undone, so use with caution.",
                        imageName: nil
                    ),
                    HelpSection(
                        title: "Data Integrity",
                        body: "Once a game is ended, its stats become read-only to preserve the historical record. This prevents accidental modifications while allowing you to build an accurate career history.",
                        imageName: nil
                    )
                ]
            )
        }
    }
}

struct HelpContent {
    let title: String
    let sections: [HelpSection]
}

struct HelpSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let imageName: String?
}
