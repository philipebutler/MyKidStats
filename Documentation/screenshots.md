Screenshots Needed for Help System
10 Screenshots Required:
screenshot-add-child

What to capture: Players tab → Tap '+' button → Show the "Add Child" form
Used in: "Managing Players" topic
screenshot-create-team

What to capture: Teams tab → Create team form with fields visible
Used in: "Teams & Seasons" and "Quick Start Guide" topics
screenshot-start-game

What to capture: Home tab → "Start New Game" button and team selection flow
Used in: "Quick Start Guide" and "Tracking Games" topics
screenshot-live-game

What to capture: Live tab during active game showing full interface (score, stat buttons, team scoring)
Used in: "Quick Start Guide" and "Tracking Games" topics
screenshot-stat-buttons

What to capture: Close-up of the large stat recording buttons (2PT, 3PT, FT, REB, AST, etc.)
Used in: "Tracking Games" topic
screenshot-team-scoring

What to capture: Team scoring section at bottom of Live Game view with teammate roster
Used in: "Tracking Games" topic
screenshot-end-game

What to capture: Game summary view shown after tapping "End Game" button
Used in: "Quick Start Guide" and "Tracking Games" topics
screenshot-game-summary

What to capture: Alternative view of completed game summary (can be same as end-game)
Used in: "Quick Start Guide" topic
screenshot-career-stats

What to capture: Stats tab showing career statistics overview
Used in: "Stats & Analysis" topic
screenshot-team-breakdown

What to capture: Stats tab scrolled to "Team Breakdown" section
Used in: "Stats & Analysis" topic
screenshot-share

What to capture: iOS share sheet with game summary text visible
Used in: "Sharing & Export" topic

#!/bin/bash

SCREENSHOTS=(
  "screenshot-add-child"
  "screenshot-create-team"
  "screenshot-start-game"
  "screenshot-live-game"
  "screenshot-stat-buttons"
  "screenshot-team-scoring"
  "screenshot-end-game"
  "screenshot-game-summary"
  "screenshot-career-stats"
  "screenshot-team-breakdown"
  "screenshot-share"
)

ASSETS_DIR="MyKidStats/Assets.xcassets"

for name in "${SCREENSHOTS[@]}"; do
  echo "Processing $name..."
  
  # Create imageset directory
  mkdir -p "$ASSETS_DIR/${name}.imageset"
  
  # Copy image from Desktop (adjust path if needed)
  if [ -f "$HOME/Desktop/${name}.png" ]; then
    cp "$HOME/Desktop/${name}.png" "$ASSETS_DIR/${name}.imageset/"
    
    # Create Contents.json
    cat > "$ASSETS_DIR/${name}.imageset/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "${name}.png",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    echo "✓ Added $name"
  else
    echo "⚠ Skipped $name (not found on Desktop)"
  fi
done

echo "Done! Open Xcode to verify."

How to Add to Xcode
Method 1: Using Xcode (Recommended)
Open Assets Catalog

In Xcode, open Assets.xcassets
Add Each Screenshot

Right-click in Assets catalog
Select "New Image Set"
Name it exactly (e.g., screenshot-add-child)
Drag PNG file into the "Universal" slot
Repeat for all 11 screenshots
Set Properties (for each image)

Select image set
In Attributes Inspector (right panel):
Render As: Original Image
Resizing: Preserve Vector Data (unchecked for PNG)
Devices: Universal