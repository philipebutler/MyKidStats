# 🚀 Quick Fix Guide - Resolve All 12+ Build Errors
**Time Required: 15-30 minutes**

---

## 🎯 The Problem

**All errors are caused by ONE missing file:** The Core Data model (`.xcdatamodeld`)

```
❌ Cannot find type 'Child' in scope
❌ Cannot find type 'Player' in scope
❌ Cannot find type 'Game' in scope
❌ Cannot find type 'Team' in scope
❌ Cannot find type 'StatEvent' in scope
```

**Why?** Core Data needs a visual model file to auto-generate these classes. Without it, the classes don't exist, causing all downstream errors.

---

## ✅ The Solution (Step-by-Step)

### Step 1: Create Core Data Model File (5 minutes)

1. Open Xcode
2. File → New → File (⌘+N)
3. Scroll to **Core Data** section
4. Select **Data Model**
5. Name: `MyKidStats` (exactly this name)
6. Click **Create**

✅ **Checkpoint:** You should see `MyKidStats.xcdatamodeld` in your project navigator

---

### Step 2: Create Child Entity (2 minutes)

1. Click on `MyKidStats.xcdatamodeld` to open the model editor
2. Click **Add Entity** button at the bottom
3. Name it: `Child`

**Add Attributes:**
Click the + button under Attributes section:

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | ☐ No | - |
| name | String | ☐ No | - |
| dateOfBirth | Date | ☑ Yes | - |
| photoData | Binary Data | ☑ Yes | - |
| createdAt | Date | ☐ No | Current Date |
| lastUsed | Date | ☐ No | Current Date |

**Add Relationship:**
Click the + button under Relationships section:

| Name | Destination | Type | Inverse |
|------|------------|------|---------|
| playerInstances | Player | To-Many | child |

**Configure Codegen:**
1. Select the `Child` entity
2. Open Data Model Inspector (right panel)
3. Set **Codegen**: Class Definition
4. Set **Module**: Current Product Module

---

### Step 3: Create Player Entity (2 minutes)

1. Click **Add Entity**
2. Name: `Player`

**Attributes:**

| Name | Type | Optional |
|------|------|----------|
| id | UUID | ☐ No |
| childId | UUID | ☐ No |
| teamId | UUID | ☐ No |
| jerseyNumber | String | ☑ Yes |
| position | String | ☑ Yes |
| createdAt | Date | ☐ No |

**Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|------------|------|---------|-------------|
| child | Child | To-One | playerInstances | Nullify |
| team | Team | To-One | players | Nullify |
| statEvents | StatEvent | To-Many | player | Cascade |

**Codegen:** Class Definition, Current Product Module

---

### Step 4: Create Team Entity (2 minutes)

**Attributes:**

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | ☐ No | - |
| name | String | ☐ No | - |
| season | String | ☐ No | - |
| organization | String | ☑ Yes | - |
| isActive | Boolean | ☐ No | NO |
| createdAt | Date | ☐ No | - |
| colorHex | String | ☑ Yes | - |

**Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|------------|------|---------|-------------|
| players | Player | To-Many | team | Cascade |
| games | Game | To-Many | team | Cascade |

**Codegen:** Class Definition, Current Product Module

---

### Step 5: Create Game Entity (3 minutes)

**Attributes:**

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | ☐ No | - |
| teamId | UUID | ☐ No | - |
| focusChildId | UUID | ☐ No | - |
| opponentName | String | ☐ No | - |
| opponentScore | Integer 32 | ☐ No | 0 |
| gameDate | Date | ☐ No | - |
| location | String | ☑ Yes | - |
| isComplete | Boolean | ☐ No | NO |
| duration | Integer 32 | ☐ No | 0 |
| notes | String | ☑ Yes | - |
| createdAt | Date | ☐ No | - |
| updatedAt | Date | ☐ No | - |

**Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|------------|------|---------|-------------|
| team | Team | To-One | games | Nullify |
| statEvents | StatEvent | To-Many | game | Cascade |

**Codegen:** Class Definition, Current Product Module

---

### Step 6: Create StatEvent Entity (2 minutes)

**Attributes:**

⚠️ **CRITICAL:** The attribute MUST be named `isDelete` (NOT `isDeleted`, NOT `isSoftDeleted`).

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | ☐ No | - |
| playerId | UUID | ☐ No | - |
| gameId | UUID | ☐ No | - |
| timestamp | Date | ☐ No | - |
| statType | String | ☐ No | - |
| value | Integer 32 | ☐ No | 0 |
| isDelete | Boolean | ☐ No | NO |

**You should have EXACTLY 7 attributes. Count them!**

**Relationships:**

| Name | Destination | Type | Inverse | Delete Rule |
|------|------------|------|---------|-------------|
| player | Player | To-One | statEvents | Nullify |
| game | Game | To-One | statEvents | Nullify |

**Codegen:** Class Definition, Current Product Module

---

### Step 7: Add Indexes for Performance (2 minutes)

For each entity, select it and add indexes in the Data Model Inspector:

**Child:**
- Index on: `id` (check "Unique")

**Player:**
- Index on: `id` (check "Unique")
- Index on: `childId`
- Index on: `teamId`

**Team:**
- Index on: `id` (check "Unique")
- Index on: `isActive`

**Game:**
- Index on: `id` (check "Unique")
- Index on: `teamId`
- Index on: `focusChildId`
- Index on: `isComplete`

**StatEvent:**
- Index on: `id` (check "Unique")
- Index on: `playerId`
- Index on: `gameId`
- Index on: `isDeleted`

---

### Step 8: Save and Build (1 minute)

1. **Save** the Core Data model: ⌘+S
2. **Clean** build folder: ⌘+Shift+K
3. **Build** project: ⌘+B

---

## ✅ Verification Checklist

After building, you should see:

- [ ] ✅ **0 build errors** (all 12+ errors gone!)
- [ ] ✅ Can open `MyKidStats.xcdatamodeld` and see 5 entities
- [ ] ✅ Each entity has Codegen = "Class Definition"
- [ ] ✅ Quick Open (⌘+Shift+O) finds `Child`, `Player`, `Game`, `Team`, `StatEvent`
- [ ] ✅ App builds successfully
- [ ] ✅ Tests run (⌘+U)

---

## 🎯 Expected Results

**Before:** 12+ errors, app won't build
```
❌ Cannot find type 'Child' in scope
❌ Cannot find type 'Player' in scope
❌ Cannot find type 'Game' in scope
... 9+ more errors
```

**After:** 0 errors, app builds and runs
```
✅ Build succeeded
✅ 35+ tests passing
✅ App launches successfully
```

---

## 🆘 Troubleshooting

### Problem: Still seeing "Cannot find type" errors

**Solution:**
1. Select each entity in the model
2. Check Data Model Inspector (right panel)
3. Verify **Codegen** is set to "Class Definition"
4. Clean build folder (⌘+Shift+K)
5. Build again (⌘+B)

### Problem: Relationships not showing up

**Solution:**
1. Create all 5 entities FIRST
2. THEN add relationships
3. Use the dropdown to select destination entities
4. Make sure inverse is set on both sides

### Problem: "Module not found" errors

**Solution:**
1. Select entity
2. Data Model Inspector
3. Set **Module** to "Current Product Module"
4. Do this for ALL 5 entities

### Problem: Xcode can't find the model

**Solution:**
1. Check the file is in your project navigator
2. Select the file
3. File Inspector → Target Membership
4. Make sure "MyKidStats" target is checked

---

## 📚 What Happens Behind the Scenes

When you set Codegen to "Class Definition":

1. Xcode reads your `.xcdatamodeld` file
2. At build time, it generates Swift classes automatically
3. These classes are placed in DerivedData (not in your source)
4. Your code can now use `Child`, `Player`, etc.
5. Your extensions (Child+Extensions.swift) extend these generated classes

**You never see the generated code** - it's automatic!

---

## 🎓 Learn More

- **Apple's Core Data Guide:** https://developer.apple.com/documentation/coredata
- **Codegen Options:** https://developer.apple.com/documentation/coredata/modeling_data
- **Project Documentation:** See `BUILD_FIX_AND_SETUP_GUIDE.md` for detailed explanations

---

## ✨ Next Steps After Fix

Once all errors are resolved:

1. ✅ Run the app (⌘+R) - You should see the basketball icon
2. ✅ Run tests (⌘+U) - Should see 35+ passing tests
3. ✅ Preview `DesignSystemPreview.swift` - See the design system
4. 🚀 Ready to implement Part 2 (UI Components)!

---

**Time to Complete:** 15-30 minutes
**Difficulty:** Easy (just following steps)
**Impact:** Fixes ALL current build errors

🏀 Let's get building! 🚀
