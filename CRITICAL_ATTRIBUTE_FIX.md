# 🚨 CRITICAL: StatEvent Attribute Name Issue

## The Problem

You have attribute naming conflicts in your Core Data StatEvent entity. Based on the errors, here's what's happening:

```
❌ Ambiguous use of 'isSoftDeleted'
❌ Cannot assign to property: 'isDeleted' is a get-only property
❌ Invalid redeclaration of 'isSoftDeleted'
```

This means you likely have MULTIPLE attributes with similar names in your StatEvent entity.

---

## ✅ SOLUTION: Clean Up StatEvent Attributes

### Step 1: Open Your Core Data Model

1. Open `MyKidStats.xcdatamodeld`
2. Select the **StatEvent** entity
3. Look at the **Attributes** section

### Step 2: Check What Attributes You Have

You might have any combination of:
- `isDeleted` ❌
- `isSoftDeleted` ❌
- `isDelete` ✅ (This is what we want)

### Step 3: Delete ALL Delete-Related Attributes

**DELETE these if they exist:**
1. Select `isDeleted` → Press Delete
2. Select `isSoftDeleted` → Press Delete  
3. Select `isDelete` → Press Delete

### Step 4: Create ONE Clean Attribute

Add a NEW attribute:
- **Name:** `isDelete`
- **Type:** Boolean
- **Optional:** Unchecked (required)
- **Default Value:** NO

### Step 5: Verify Final StatEvent Attributes

Your StatEvent entity should have EXACTLY these 7 attributes:

| Name | Type | Optional | Default |
|------|------|----------|---------|
| id | UUID | ☐ No | - |
| playerId | UUID | ☐ No | - |
| gameId | UUID | ☐ No | - |
| timestamp | Date | ☐ No | - |
| statType | String | ☐ No | - |
| value | Integer 32 | ☐ No | 0 |
| **isDelete** | **Boolean** | **☐ No** | **NO** |

**COUNT THEM:** You should have exactly 7 attributes, no more, no less.

### Step 6: Verify Relationships

| Name | Destination | Type | Inverse |
|------|------------|------|---------|
| player | Player | To-One | statEvents |
| game | Game | To-One | statEvents |

### Step 7: Verify Codegen

With StatEvent entity selected, check Data Model Inspector (right panel):
- **Codegen:** Class Definition
- **Module:** Current Product Module

### Step 8: Save, Clean, and Build

```
⌘+S (Save)
⌘+Shift+K (Clean Build Folder)
⌘+B (Build)
```

---

## 🎯 Code Is Already Updated

All Swift code now uses `isDelete` consistently:

✅ `LiveGameViewModel.swift` → Uses `isDelete`
✅ `CalculateCareerStatsUseCase.swift` → Uses `isDelete`
✅ `Game+Extensions.swift` → Uses `isDelete`
✅ `StatEvent+Extensions.swift` → No delete property references

---

## 🔍 Why This Happened

You likely:
1. Started with `isDeleted` (as in the guide)
2. Encountered a naming conflict
3. Changed it to `isDelete` 
4. But didn't delete the old attribute
5. Or accidentally created `isSoftDeleted` as well

Core Data now has multiple attributes with similar names, causing conflicts.

---

## ⚠️ Double Check

After cleaning up, in Xcode's Core Data model editor, you should see:

```
StatEvent
├── Attributes (7)
│   ├── id (UUID)
│   ├── playerId (UUID)
│   ├── gameId (UUID)
│   ├── timestamp (Date)
│   ├── statType (String)
│   ├── value (Integer 32)
│   └── isDelete (Boolean) ← ONLY ONE delete-related attribute!
└── Relationships (2)
    ├── player → Player
    └── game → Game
```

---

## 🆘 If Still Failing

If you still get errors after this:

1. **Close Xcode completely**
2. **Delete DerivedData:**
   - Go to Xcode → Preferences → Locations
   - Click the arrow next to DerivedData path
   - Delete the folder for your project
3. **Reopen Xcode**
4. **Clean Build Folder:** ⌘+Shift+K
5. **Build:** ⌘+B

---

## 📸 What It Should Look Like

When you select StatEvent entity, the Attributes section should show:

```
Attributes                                    +  -
┌─────────────┬──────────────┬──────────┬─────────┐
│ Attribute   │ Type         │ Optional │ Default │
├─────────────┼──────────────┼──────────┼─────────┤
│ id          │ UUID         │          │         │
│ playerId    │ UUID         │          │         │
│ gameId      │ UUID         │          │         │
│ timestamp   │ Date         │          │         │
│ statType    │ String       │          │         │
│ value       │ Integer 32   │          │ 0       │
│ isDelete    │ Boolean      │          │ NO      │
└─────────────┴──────────────┴──────────┴─────────┘
```

**7 rows total. No `isDeleted`, no `isSoftDeleted`.**

---

**Fix this and your build should succeed!** 🚀
