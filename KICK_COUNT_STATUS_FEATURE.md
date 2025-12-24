# Kick Count Feature - Recent List Status Display

## Summary of Changes

### 1. Enhanced List Display
The recent kick count history list now shows:
- **Status Badge**: Visual indicator (Excellent/Good/Monitor/Concerning)
- **Status Icon**: Color-coded icon based on kick count status
  - ✅ Green check - Excellent/Good (normal movement)
  - ⏱️ Orange schedule - Monitor (below typical but okay)
  - ⚠️ Red warning - Concerning (needs attention)
- **Interactive**: Click any log to view detailed results with guidance

### 2. Clickable List Items
- Each log entry is now tappable
- Shows the same result dialog that appears after a session
- Displays personalized guidance based on kick count

### 3. Data Structure
All kick count data sent to backend includes:

**Session Metadata:**
- `date` - When session was completed
- `start_time` - When session started
- `duration_minutes` - How long the session took

**Kick Data:**
- `kick_count` - Total number of kicks counted
- `average_intensity` - 1-5 scale of kick intensity
- `context_tags` - Contextual information (After Meal, Cold Drink, etc.)

**Notes:**
- `notes` - General session notes
- `diary_notes` - Personal mother's notes about the session

### 4. Status Calculation Logic
The status is determined using ACOG guidelines:

| Normalized Kicks | Status | Recommendation |
|---|---|---|
| 10+ | ✅ Excellent | Keep monitoring normally |
| 8-9 | ✅ Good | Continue regular tracking |
| 5-7 | ⏱️ Monitor | Try wake-up techniques; recount in 2 hours |
| <5 | ⚠️ Concerning | Try wake-up methods; contact doctor if continues |

**Calculation:** `(actual_kicks / duration_minutes) * 120`
- This normalizes all sessions to a standard 2-hour (120-minute) period per ACOG guidelines

### 5. How It Works

1. **User Views Recent Kicks List**
   - Each item shows: kick count, date/time, and status badge
   - Icons are color-coded by status

2. **User Clicks a Log Entry**
   - Shows detailed results dialog
   - Same info shown after a fresh session
   - Includes personalized guidance

3. **Backend Data Persistence**
   - All session data is stored with timestamps
   - Status is calculated on-the-fly from kick_count + duration_minutes
   - User can review historical sessions anytime

### Files Modified/Created:
- `lib/models/kick_count_notes.dart` - Status and guidance logic
- `lib/screens/mother/tracking/kick_count_screen.dart` - Enhanced list UI and interactions
- `API_KICK_COUNT_DATA.md` - API documentation

### Testing Checklist:
- [ ] Start a new kick count session
- [ ] Count some kicks (try 12 kicks in 5 minutes = Excellent)
- [ ] Finish session - see result dialog
- [ ] View recent kicks list - check status badges appear
- [ ] Click a previous log - see result dialog with same guidance
- [ ] Try different kick counts to see different statuses:
  - 10+ kicks = Excellent
  - 8-9 kicks = Good
  - 5-7 kicks = Monitor
  - <5 kicks = Concerning
