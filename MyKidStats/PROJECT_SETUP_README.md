# MyKidStats - Project Structure Setup

## ✅ Completed Steps

The directory structure has been set up according to Part 1 of the Implementation Plan:

### Core Layer
- **Core/Data/CoreData/**
  - `CoreDataStack.swift` - Core Data persistence management
  - **Extensions/** - Entity helper methods (Child, Player, Team, Game, StatEvent)

- **Core/Domain/**
  - **Models/** - `LiveStats.swift`, `CareerStats.swift`
  - **Enums/** - `StatType.swift`

### Design System
- **DesignSystem/**
  - `Colors.swift` - Color palette with dark mode support
  - `Fonts.swift` - Typography system
  - `Spacing.swift` - Layout constants

## 🚧 Next Steps (Do in Xcode)

### 1. Fix .gitkeep Build Error
**In Xcode:**
1. Select your project in the Navigator (top blue icon)
2. Select the "MyKidStats" target
3. Go to "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. Find any `.gitkeep` files in the list
6. Select them and click the "-" button to remove them
7. Build again (⌘+B)

### 2. Add Files to Xcode Project
All the Swift files have been created but need to be added to your Xcode project:

1. In Xcode, right-click on "MyKidStats" folder in the Navigator
2. Choose "Add Files to 'MyKidStats'..."
3. Navigate to your project folder
4. Select the following folders:
   - `Core/`
   - `DesignSystem/`
5. **IMPORTANT:** Check these options:
   - ✅ "Copy items if needed"
   - ✅ "Create groups" (NOT "Create folder references")
   - ✅ Add to target: MyKidStats
6. Click "Add"

### 3. Create Core Data Model (.xcdatamodeld)
You need to create the Core Data model file manually in Xcode:

1. Right-click on project → New File
2. Choose "Data Model" under Core Data section
3. Name it: `MyKidStats`
4. Save it in the project root

Then follow the detailed instructions in `AI_Implementation_Part1_Foundation.md` starting at **Task 1.3** to:
- Create 5 entities (Child, Player, Team, Game, StatEvent)
- Add attributes with proper types
- Configure relationships
- Set up indexes
- Configure Codegen to "Class Definition"

### 4. Organize Files in Xcode (Optional but Recommended)
Create folder groups to match the structure:

```
MyKidStats/
├── App/
│   ├── MyKidStatsApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Data/
│   │   └── CoreData/
│   │       ├── CoreDataStack.swift
│   │       └── Extensions/
│   ├── Domain/
│   │   ├── Models/
│   │   └── Enums/
│   └── Utilities/
├── Features/
│   ├── Home/
│   ├── LiveGame/
│   ├── Stats/
│   └── Teams/
├── DesignSystem/
│   ├── Colors.swift
│   ├── Fonts.swift
│   └── Spacing.swift
└── Resources/
```

To create groups:
- Right-click in Navigator → New Group
- Drag files into the appropriate groups

## 📋 Verification Checklist

After completing the above steps, verify:

- [ ] Project builds successfully (⌘+B)
- [ ] No .gitkeep errors
- [ ] All Swift files are in the project navigator
- [ ] Core Data model (.xcdatamodeld) exists and opens
- [ ] All 5 entities created in Core Data model
- [ ] Extensions compile (they'll have errors until Core Data entities are created)
- [ ] Design system files compile
- [ ] App runs in simulator

## 🔧 Troubleshooting

### "Cannot find type 'Child' in scope"
This means the Core Data model isn't created yet or Codegen isn't set to "Class Definition". Complete Step 3 above.

### "Multiple commands produce .gitkeep"
Complete Step 1 above to remove .gitkeep files from Copy Bundle Resources.

### Files not showing in Xcode
Make sure you used "Add Files to..." (Step 2) and selected "Create groups"

## 📚 Next Phase
Once all checks pass, continue with Part 2 of the implementation plan for UI components.
