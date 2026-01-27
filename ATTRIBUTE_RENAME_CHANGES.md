# Attribute Rename: `isDeleted` → `isDelete`

## Summary
Changed the StatEvent entity's `isDeleted` attribute to `isDelete` to avoid a naming conflict in Core Data.

## Reason for Change
Core Data was reporting a naming conflict with the `isDeleted` attribute name on the Player entity (even though Player shouldn't have had this attribute). To resolve this, the attribute was renamed to `isDelete`.

## Files Updated

### 1. **LiveGameViewModel.swift**
Updated all references from `isDeleted` to `isDelete`:

- ✅ `loadExistingStats()` - Filter logic (2 occurrences)
- ✅ `recordFocusPlayerStat()` - Event creation
- ✅ `recordTeamPlayerScore()` - Event creation
- ✅ `softDeleteEvent()` - Soft delete logic

### 2. **CalculateCareerStatsUseCase.swift**
Updated predicate query:

- ✅ `fetchAllStats()` - NSPredicate filter changed from `isDeleted == false` to `isDelete == false`

### 3. **QUICK_FIX_GUIDE.md**
Updated documentation:

- ✅ StatEvent attribute table - Changed attribute name
- ✅ Indexes section - Updated index name

## Core Data Model Changes Required

Make sure your Core Data model (`MyKidStats.xcdatamodeld`) has:

**StatEvent Entity:**
- Attribute: `isDelete` (Boolean, required, default = NO)
- Index on `isDelete` for query performance

## Testing Checklist

After making these changes:

- [ ] Clean Build Folder (⌘+Shift+K)
- [ ] Build Project (⌘+B)
- [ ] Verify no "Cannot find type" errors
- [ ] Test live game stat recording
- [ ] Test undo functionality
- [ ] Test career stats calculation
- [ ] Run unit tests (⌘+U)

## Migration Notes

If you have existing data with `isDeleted`:
1. This is a breaking change for existing databases
2. You'll need to create a Core Data migration
3. Or delete the app and reinstall (only during development!)

## Future Considerations

The original `isDeleted` name is a common soft-delete pattern. If Core Data continues to have issues with this name, consider alternatives like:
- `deleted` (Boolean)
- `active` (Boolean, inverted logic)
- `status` (String or enum)

---

**Date:** January 26, 2026
**Status:** ✅ Complete - All code updated
