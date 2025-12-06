# Frontend Issues & Required Fixes

## ⚠️ Critical Issues Found

### 1. **Signup Flow is BROKEN** ❌

**Current Frontend Behavior:**
```dart
// signup_screen.dart sends:
{
  "email": "...",
  "password": "...",
  "role": "mother",
  "profileData": {  // ← Backend doesn't handle this!
    "name": "...",
    "phone_no": "...",
    "age": 28,
    "is_pregnant": true,
    "expected_delivery_date": "..."
  }
}
```

**Backend Actually Expects:**
1. **Step 1:** `POST /api/auth/signup` - Only email, password, role
2. **Step 2:** `POST /api/mother/create` - Create profile AFTER signup (with token)

**Fix Required:**
- Remove `profileData` from signup
- After signup success, navigate to profile creation screen
- Call `POST /api/mother/create` with token

---

### 2. **Login Response Parsing is WRONG** ❌

**Current Frontend Code:**
```dart
// login_screen.dart line 151-159
final token = parsedBody['token'];  // ← Wrong!
final role = parsedBody['data']["role"];

// Saves as:
await prefs.setString("jwt_token", token);
await prefs.setString("user_role", role);
```

**Actual Backend Response:**
```json
{
  "message": "Login successful",
  "data": {
    "id": "userId123",
    "email": "test@test.com",
    "role": "mother"
  },
  "token": "jwt_token_here"
}
```

**Fix Required:**
```dart
final token = parsedBody['token'];  // ✓ Correct
final role = parsedBody['data']['role'];  // ✓ Correct
final userId = parsedBody['data']['id'];  // Need this too!

// Save correctly:
await prefs.setString("token", token);  // Use 'token' not 'jwt_token'
await prefs.setString("role", role);    // Use 'role' not 'user_role'
await prefs.setString("userId", userId);
```

---

### 3. **Splash Screen Token Check is WRONG** ❌

**Current Frontend Code:**
```dart
// splash_screen.dart line 23-25
final token = prefs.getString("jwt_token");  // ← Wrong key!
final role = prefs.getString("user_role");   // ← Wrong key!
```

**Fix Required:**
```dart
final token = prefs.getString("token");  // Match what login saves
final role = prefs.getString("role");    // Match what login saves
```

---

### 4. **Home Screen Has NO API Integration** ❌

**Current Code:**
```dart
// home_screen.dart is all hardcoded:
Text('Hello, Fathima'),  // ← Hardcoded name
Text('In 26 weeks...'),  // ← Hardcoded data
```

**Fix Required:**
- Fetch mother profile: `GET /api/mother/me/profile`
- Fetch pregnancy progress: `GET /api/mother/me/pregnancy-progress`
- Display real data

---

### 5. **Mother Model Field Mismatch** ⚠️

**Frontend signup sends:**
- `is_pregnant` (boolean)

**Backend expects:**
- `status` (string: "pregnant", "delivered", "planning")
- OR can calculate from `expected_delivery_date` / `last_period_date`

**Fix:** Update signup to send `status` instead of `is_pregnant`

---

## 📋 Updated Task List (Priority Order)

### PRIORITY 1: Fix Broken Auth Flow (MUST DO FIRST)

#### Task 1.1: Fix Login Screen
**File:** `lib/screens/login_screen.dart`

**Changes:**
```dart
// Line 151-159, change to:
final parsedBody = jsonDecode(response.body);
final token = parsedBody['token'];
final role = parsedBody['data']['role'];
final userId = parsedBody['data']['id'];

// Save with correct keys:
await prefs.setString("token", token);
await prefs.setString("role", role);
await prefs.setString("userId", userId);
```

#### Task 1.2: Fix Signup Screen
**File:** `lib/screens/signup_screen.dart`

**Changes:**
1. **Remove profileData from signup** (lines 57-68)
2. **Only send**: email, password, role
3. **After signup success**: Navigate to profile creation screen (new screen)
4. **Save token correctly**: Use `"token"` and `"role"` keys

#### Task 1.3: Create Profile Creation Screen
**New File:** `lib/screens/mother/create_profile_screen.dart`

**Requirements:**
- Form with: name, phone_no, age, status dropdown, expected_delivery_date
- Load token from SharedPreferences
- Call: `POST /api/mother/create` with Authorization header
- Navigate to home after success

#### Task 1.4: Fix Splash Screen
**File:** `lib/screens/splash_screen.dart`

**Changes:**
```dart
// Line 24-25, change to:
final token = prefs.getString("token");  // Not "jwt_token"
final role = prefs.getString("role");    // Not "user_role"
```

---

### PRIORITY 2: Fix Home Screen with Real Data

#### Task 2.1: Create API Service Class
**New File:** `lib/services/api_service.dart`

**Purpose:** Centralize all API calls
```dart
class ApiService {
  static Future<Map<String, dynamic>> getMotherProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.get(
      Uri.parse('$kBaseRoute/mother/me/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    return jsonDecode(response.body);
  }
  
  // Add more methods...
}
```

#### Task 2.2: Update Home Screen
**File:** `lib/screens/mother/home_screen.dart`

**Changes:**
1. Convert to StatefulWidget
2. Fetch data in `initState()`:
   - `GET /api/mother/me/profile`
   - `GET /api/mother/me/pregnancy-progress`
3. Display real name, pregnancy weeks, countdown
4. Show loading state while fetching

---

### PRIORITY 3: Build Missing Core Features

#### Task 3.1: Weight Tracking
**New File:** `lib/screens/mother/tracking/weight_log_screen.dart`
- List: `GET /api/mother/me/weight-logs`
- Add: `POST /api/mother/me/weight-logs`

#### Task 3.2: Symptom Tracking
**New File:** `lib/screens/mother/tracking/symptom_log_screen.dart`
- List: `GET /api/mother/me/symptom-logs`
- Add: `POST /api/mother/me/symptom-logs`

#### Task 3.3: Discover/Articles Tab
**New File:** `lib/screens/mother/discover_screen.dart`
- Featured: `GET /api/article/featured`
- By category: `GET /api/article/category/:category`
- Detail view: `GET /api/article/:id`

#### Task 3.4: Caregiver Booking
**Update:** `lib/screens/mother/caregiver_list_screen.dart`
- Fix API call: `GET /api/caregiver/all`
- Add booking flow: `POST /api/caregiver-booking/create`

---

## 🔧 Quick Fixes Checklist

### Before Any Development:
- [ ] Update `lib/constants.dart` - Set correct IP/URL
- [ ] Run `flutter pub get`
- [ ] Backend must be running on `http://localhost:3000`

### Auth Flow Fixes (DO FIRST):
- [ ] Fix login token/role saving keys
- [ ] Fix signup to NOT send profileData
- [ ] Create profile creation screen
- [ ] Fix splash screen token check
- [ ] Test full flow: signup → create profile → home

### Data Display Fixes:
- [ ] Create ApiService class
- [ ] Update home screen to fetch real data
- [ ] Add loading states
- [ ] Add error handling

### New Features:
- [ ] Weight tracking screen
- [ ] Symptom tracking screen
- [ ] Discover/Articles tab
- [ ] Caregiver booking completion

---

## 🚨 BREAKING CHANGES SUMMARY

| Issue | Current | Should Be |
|-------|---------|-----------|
| Signup flow | Sends profileData | Only email/password/role, then separate profile creation |
| Login save key | `"jwt_token"` | `"token"` |
| Login save key | `"user_role"` | `"role"` |
| Splash check key | `"jwt_token"` | `"token"` |
| Splash check key | `"user_role"` | `"role"` |
| Mother field | `is_pregnant` boolean | `status` string |
| Home screen | Hardcoded data | API fetched data |

---

## ⏱️ Estimated Time to Fix

| Task | Time | Priority |
|------|------|----------|
| Fix login/signup/splash keys | 30 mins | 🔴 CRITICAL |
| Create profile creation screen | 2 hours | 🔴 CRITICAL |
| Create ApiService class | 1 hour | 🟡 HIGH |
| Fix home screen with API | 2 hours | 🟡 HIGH |
| Weight tracking | 2 hours | 🟢 MEDIUM |
| Symptom tracking | 2 hours | 🟢 MEDIUM |
| Discover tab | 3 hours | 🟢 MEDIUM |
| Caregiver booking | 3 hours | 🟢 LOW |

**Total Critical Fixes:** ~5 hours
**Total to MVP:** ~15 hours

---

## 🎯 Recommended Action Plan

### Day 1: Fix Auth (Must Complete)
1. Fix login screen token saving
2. Fix signup screen (remove profileData)
3. Fix splash screen token check
4. Create profile creation screen
5. Test complete auth flow

### Day 2: Real Data Integration
1. Create ApiService class
2. Update home screen with API calls
3. Add loading/error states
4. Test with real backend data

### Day 3: Build Features
1. Weight tracking screen
2. Symptom tracking screen
3. Discover/Articles tab

### Day 4: Polish & Test
1. Caregiver booking flow
2. UI improvements
3. End-to-end testing
4. Bug fixes
