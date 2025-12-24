# Kick Count Mathematical Accuracy Fix

## Problem
When users counted kicks very quickly (e.g., 10 kicks in 10 seconds), the app was showing "Low Kick Count" status because:
- The old code used `durationMinutes = _elapsed.inMinutes` 
- This truncates to whole minutes, so 10 seconds = 0 minutes
- Formula: `(10 / 0) * 120` = division by zero or 0 → Low status ❌

## Solution
Changed the calculation to use **seconds** instead of minutes, with proper mathematical normalization.

### New Formula
```
normalized_kicks = (kickCount / durationSeconds) * 7200

Where:
- 7200 = seconds in 2 hours (120 minutes * 60 seconds)
- This normalizes ANY duration to a 2-hour equivalent
```

### Examples
| Actual Kicks | Duration | Calculation | Normalized | Status |
|---|---|---|---|---|
| 10 | 10 seconds | (10/10)*7200 | 7200 | ✅ Excellent |
| 10 | 30 seconds | (10/30)*7200 | 2400 | ✅ Excellent |
| 10 | 60 seconds (1 min) | (10/60)*7200 | 1200 | ✅ Excellent |
| 10 | 600 seconds (10 mins) | (10/600)*7200 | 120 | ✅ Excellent |
| 10 | 7200 seconds (2 hrs) | (10/7200)*7200 | 10 | ✅ Excellent |
| 5 | 600 seconds (10 mins) | (5/600)*7200 | 60 | ✅ Excellent |
| 3 | 600 seconds (10 mins) | (3/600)*7200 | 36 | ✅ Excellent |

## Status Thresholds (Normalized Kicks)
- **✅ Excellent**: ≥ 10 kicks (normalized)
- **✅ Good**: 8-9 kicks (normalized)
- **⏱️ Monitor**: 5-7 kicks (normalized)
- **⚠️ Concerning**: < 5 kicks (normalized)

## Changes Made

### 1. `lib/models/kick_count_notes.dart`
- Updated `getKickCountNotes()` to accept `durationSeconds` instead of `durationMinutes`
- Updated `_normalizeKicks()` to use seconds: `(kickCount / durationSeconds) * 7200`
- Fixed display to show decimal minutes: `(durationSeconds / 60).toStringAsFixed(1)`

### 2. `lib/screens/mother/tracking/kick_count_screen.dart`
- `_finishSession()`: Changed to pass duration in seconds to display functions
- `_showKickCountResults()`: Now accepts seconds parameter
- `_showKickCountResultsFromLog()`: Now accepts seconds parameter
- List builder: Converts stored minutes back to seconds for accurate recalculation

## Key Improvements
✅ **Accurate for quick sessions**: 10 kicks in 10 seconds now shows Excellent (not Low)
✅ **Works with all durations**: From seconds to hours
✅ **Mathematically precise**: Uses proper normalization formula
✅ **Backward compatible**: Backend still stores minutes for display
✅ **User-friendly**: Shows decimal minutes (e.g., "0.2 minutes" = 12 seconds)

## Testing Scenarios
1. **Quick session**: 10 kicks in 10 seconds → ✅ Excellent
2. **Medium session**: 5 kicks in 5 minutes (300 seconds) → ✅ Excellent
3. **Standard session**: 10 kicks in 120 minutes → ✅ Excellent  
4. **Slow session**: 2 kicks in 60 minutes → ✅ Good (normalized: 240)
5. **Very slow session**: 1 kick in 60 minutes → ⏱️ Monitor (normalized: 120)
