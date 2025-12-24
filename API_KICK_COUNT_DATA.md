// KICK COUNT API DATA STRUCTURE
// This document shows what data is being sent to and expected from the backend

/* ========================
   POST /api/mother/me/kick-counts
   ========================
   
   REQUEST BODY:
   {
     "date": "2025-12-24T10:30:00.000Z",           // ISO 8601 - current date/time
     "start_time": "2025-12-24T10:25:00.000Z",     // ISO 8601 - session start
     "kick_count": 12,                              // Integer - number of kicks
     "duration_minutes": 5,                         // Integer - how long session took
     "notes": "Session finished",                   // String - general notes
     "average_intensity": 3,                        // Integer 1-5 - kick intensity level
     "context_tags": ["After Meal", "Morning"],    // Array - contextual tags
     "diary_notes": "Baby very active today"       // String (optional) - user notes
   }
   
   RESPONSE (201 Created):
   {
     "status": "success",
     "data": {
       "_id": "507f1f77bcf86cd799439011",
       "date": "2025-12-24T10:30:00.000Z",
       "start_time": "2025-12-24T10:25:00.000Z",
       "kick_count": 12,
       "duration_minutes": 5,
       "notes": "Session finished",
       "average_intensity": 3,
       "context_tags": ["After Meal", "Morning"],
       "diary_notes": "Baby very active today",
       "mother_id": "507f1f77bcf86cd799439012",
       "created_at": "2025-12-24T10:30:00.000Z",
       "updated_at": "2025-12-24T10:30:00.000Z"
     }
   }
*/

/* ========================
   GET /api/mother/me/kick-counts
   ========================
   
   RESPONSE (200 OK):
   {
     "status": "success",
     "data": [
       {
         "_id": "507f1f77bcf86cd799439011",
         "date": "2025-12-24T10:30:00.000Z",
         "start_time": "2025-12-24T10:25:00.000Z",
         "kick_count": 12,
         "duration_minutes": 5,
         "notes": "Session finished",
         "average_intensity": 3,
         "context_tags": ["After Meal", "Morning"],
         "diary_notes": "Baby very active today",
         "mother_id": "507f1f77bcf86cd799439012",
         "created_at": "2025-12-24T10:30:00.000Z",
         "updated_at": "2025-12-24T10:30:00.000Z"
       },
       {
         "_id": "507f1f77bcf86cd799439013",
         "date": "2025-12-23T14:15:00.000Z",
         "start_time": "2025-12-23T14:10:00.000Z",
         "kick_count": 8,
         "duration_minutes": 7,
         "notes": "Session finished",
         "average_intensity": 2,
         "context_tags": ["Cold Drink", "Evening"],
         "diary_notes": null,
         "mother_id": "507f1f77bcf86cd799439012",
         "created_at": "2025-12-23T14:15:00.000Z",
         "updated_at": "2025-12-23T14:15:00.000Z"
       }
     ]
   }
*/

// FRONTEND DATA MODEL (lib/models/tracking_models.dart)
class KickCountLog {
  final String? id;                      // Backend MongoDB _id
  final DateTime date;                   // When session was completed
  final DateTime startTime;              // When session started
  final int kickCount;                   // Number of kicks counted
  final int? durationMinutes;            // Session duration in minutes
  final String? notes;                   // General notes
  final int? averageIntensity;           // 1-5 scale of kick intensity
  final List<String> contextTags;        // Context like 'After Meal', 'Cold Drink'
  final String? diaryNotes;              // User personal notes
}

// KICK COUNT STATUS LEVELS (lib/models/kick_count_notes.dart)
// Based on ACOG recommendation: 10 movements in 2 hours (120 minutes)
//
// ✅ EXCELLENT: 10+ kicks normalized to 2-hour period
// ✅ GOOD:      8-9 kicks normalized
// ⏱️  MONITOR:   5-7 kicks - suggest wake-up techniques
// ⚠️  CONCERNING: <5 kicks - urgent actionable steps, contact doctor

// EXAMPLE: If user feels 5 kicks in 10 minutes
// Normalized = (5 / 10) * 120 = 60 kicks equivalent = EXCELLENT
