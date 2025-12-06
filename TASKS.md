# Flutter Development Tasks

## Setup (Do This First)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Update API URL
**File:** `lib/constants.dart`
```dart
const String baseUrl = "http://10.0.2.2:3000/api";  // For Android emulator
// OR
const String baseUrl = "http://localhost:3000/api";  // For iOS simulator
// OR
const String baseUrl = "http://YOUR_IP:3000/api";  // For real device
```

### 3. Add Required Packages
**File:** `pubspec.yaml` (under dependencies)
```yaml
intl: ^0.18.0
url_launcher: ^6.1.0
cached_network_image: ^3.2.0
```
Then run: `flutter pub get`

---

## Task 1: Fix Profile Creation Flow (2-3 hours)

**Goal:** After signup, redirect to create mother profile

**Steps:**
1. Create `lib/screens/mother/create_profile_screen.dart`
2. Add form fields: name, phone, age, is_pregnant, expected_delivery_date
3. On signup success in `signup_screen.dart`, navigate to create profile
4. API call: `POST /api/mother/create` with token
5. After profile created, navigate to mother app shell

**API Example:**
```dart
POST /api/mother/create
Headers: {"Authorization": "Bearer $token"}
Body: {"name": "...", "phone_no": "...", "age": 28, "is_pregnant": true}
```

---

## Task 2: Build Home/Dashboard Screen (3-4 hours)

**Goal:** Show pregnancy progress and quick stats

**File:** `lib/screens/mother/mother_home_screen.dart`

**Features to add:**
1. Pregnancy progress card (weeks, trimester, countdown)
   - API: `GET /api/mother/me/pregnancy-progress`
2. Welcome message with mother's name
3. Quick action buttons:
   - Log Weight
   - Log Symptoms
   - Log Kicks
4. Recent activity summary

---

## Task 3: Discover/Articles Tab (3-4 hours)

**Goal:** Browse and read articles

### 3a. Create Article List Screen
**File:** `lib/screens/mother/discover_screen.dart`

**Features:**
1. Fetch featured articles: `GET /api/article/featured`
2. Show categories: `GET /api/article/categories`
3. Display as cards with: image, title, summary, read time
4. Tap to open article detail

### 3b. Create Article Detail Screen
**File:** `lib/screens/mother/article_detail_screen.dart`

**Features:**
1. Fetch full article: `GET /api/article/:id`
2. Show: title, image, content, category badge
3. Back button

---

## Task 4: Weight Tracking (2-3 hours)

**Goal:** Log and view weight during pregnancy

### 4a. Create Weight Log Screen
**File:** `lib/screens/mother/tracking/weight_log_screen.dart`

**Features:**
1. List all weight logs: `GET /api/mother/me/weight-logs`
2. Add new log button → opens dialog/bottom sheet
3. Form: weight (number), notes (optional), date (auto)
4. API: `POST /api/mother/me/weight-logs`
5. Show logs as list with date + weight

---

## Task 5: Symptom Tracking (2-3 hours)

**File:** `lib/screens/mother/tracking/symptom_log_screen.dart`

**Features:**
1. List symptoms: `GET /api/mother/me/symptom-logs`
2. Add symptom form:
   - Select symptoms (checkboxes): nausea, fatigue, back_pain, headache, etc.
   - Select severity: mild/moderate/severe
   - Notes (optional)
3. API: `POST /api/mother/me/symptom-logs`
4. Display with colored severity indicators

---

## Task 6: Kick Counter (1-2 hours)

**File:** `lib/screens/mother/tracking/kick_counter_screen.dart`

**Features:**
1. Big button to count kicks
2. Display kick count + duration
3. Save button → `POST /api/mother/me/kick-counts`
4. History list: `GET /api/mother/me/kick-counts`

**Simple UI:**
- Counter display (large number)
- Tap anywhere to increment
- Timer showing duration
- Save & Reset buttons

---

## Task 7: Caregiver List (2-3 hours)

**File:** `lib/screens/mother/caregiver_list_screen.dart`

**Features:**
1. Fetch caregivers: `GET /api/caregiver/all`
2. Display as cards: name, experience, shift, amount, rating
3. Filter by shift (dropdown)
4. Tap to view details → caregiver profile screen

---

## Task 8: Caregiver Booking (3-4 hours)

### 8a. Caregiver Profile Screen
**File:** `lib/screens/mother/caregiver_profile_screen.dart`
- Show full details
- "Book Now" button → opens booking form

### 8b. Booking Form
**File:** `lib/screens/mother/booking_form_screen.dart`
- Fields: start_date, end_date, shift, accommodation, address, notes
- Calculate total amount
- API: `POST /api/caregiver-booking/create`

### 8c. My Bookings Screen
**File:** `lib/screens/mother/my_bookings_screen.dart`
- List: `GET /api/caregiver-booking/my-bookings`
- Show status badge (pending/accepted/rejected)
- Cancel option for pending bookings

---

## Task 9: Emergency Contacts (1-2 hours)

**File:** `lib/screens/mother/emergency_contacts_screen.dart`

**Features:**
1. List contacts: `GET /api/mother/me/emergency-contacts`
2. Add contact form (name, phone, relation)
   - API: `POST /api/mother/me/emergency-contacts`
3. Delete contact: `DELETE /api/mother/me/emergency-contacts/:id`
4. Call button using `url_launcher` package:
   ```dart
   import 'package:url_launcher/url_launcher.dart';
   await launchUrl(Uri.parse('tel:$phoneNumber'));
   ```

---

## Task 10: Baby Profile & Tracking (3-4 hours)

**Note:** Only show after mother marks delivery

### 10a. Add Baby Profile
**File:** `lib/screens/mother/baby/add_baby_screen.dart`
- Form: name, gender, birth_date, birth_weight
- API: `POST /api/baby/create`

### 10b. Baby List
**File:** `lib/screens/mother/baby/baby_list_screen.dart`
- List: `GET /api/baby/my-babies`
- Tap to view baby details/tracking

### 10c. Baby Tracking Screen
**File:** `lib/screens/mother/baby/baby_tracking_screen.dart`
- Tabs: Feeding, Sleep, Diaper, Vaccinations
- Add log buttons for each type
- APIs:
  - `POST /api/baby/:id/feeding`
  - `POST /api/baby/:id/sleep`
  - `POST /api/baby/:id/diaper`

---

## Task 11: Appointments (2-3 hours)

**File:** `lib/screens/mother/appointments_screen.dart`

**Features:**
1. List appointments: `GET /api/appointment/my-appointments`
2. Add appointment button → form
3. Form fields: title, venue_type, venue_name, doctor_name, date, time
4. API: `POST /api/appointment/create`
5. Edit/Delete options

---

## Task 12: Profile & Settings (1-2 hours)

**File:** `lib/screens/mother/profile_screen.dart`

**Features:**
1. Show mother profile: `GET /api/mother/me/profile`
2. Edit profile option
3. Change password option: `PUT /api/auth/change-password`
4. Logout button (clear token from SharedPreferences)

---

## Optional Enhancements

### Charts/Graphs
- Add `fl_chart` package
- Weight progress line chart
- Symptom frequency bar chart

### Mark Delivery
- Button to mark baby delivered
- API: `POST /api/mother/me/mark-delivery`
- Switch UI from pregnancy mode to postnatal mode

### Notifications
- Local notifications for appointments
- Reminders for checkups

---

## Testing Checklist

- [ ] Signup → Profile Creation → Home works
- [ ] Can browse and read articles
- [ ] Can log weight/symptoms/kicks
- [ ] Can view caregivers and create booking
- [ ] Emergency contacts work with call button
- [ ] Baby tracking works after delivery
- [ ] Appointments CRUD works
- [ ] Logout clears token and returns to login

---

## API Reference

**Backend must be running:** `http://localhost:3000`

**Full API docs:** See `maternity-support-system-backend/API_ROUTES.md`

**Authentication:**
```dart
final response = await http.get(
  Uri.parse('$baseUrl/endpoint'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
);
```
