import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/apiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Local stats
  double? _latestWeight;
  double? get latestWeight => _latestWeight;

  int? _symptomCount;
  int? get symptomCount => _symptomCount;

  int? _lastKickCount;
  int? get lastKickCount => _lastKickCount;

  DateTime? _expectedDeliveryDate;
  DateTime? get expectedDeliveryDate => _expectedDeliveryDate;

  DateTime? _actualDeliveryDate;
  DateTime? get actualDeliveryDate => _actualDeliveryDate;

  // Dashboard stats
  int _todayFeedCount = 0;
  int get todayFeedCount => _todayFeedCount;

  String? _lastFeedTime;
  String? get lastFeedTime => _lastFeedTime;

  double _todaySleepHours = 0;
  double get todaySleepHours => _todaySleepHours;

  int _todayDiaperCount = 0;
  int get todayDiaperCount => _todayDiaperCount;

  // Cache tracking
  String? _lastFetchedBabyId;

  // Helper methods from HomeScreen
  int getWeeksRemaining(int? currentWeek) {
    if (currentWeek == null) return 0;
    return 40 - currentWeek;
  }

  int getBabyAgeWeeks() {
    if (_actualDeliveryDate == null) return 0;
    return DateTime.now().difference(_actualDeliveryDate!).inDays ~/ 7;
  }

  // Fetch local non-provider stats (weight logs, etc)
  Future<void> fetchAdditionalStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final profileRes = await ApiService().get('/mother/me/profile');

      if (profileRes.statusCode == 200) {
        // API returns { message, data, pregnancy_week } - access nested data
        final responseData = profileRes.data;
        final profile = responseData['data'] as Map<String, dynamic>? ?? {};

        final weightLogs = profile['weight_logs'] as List? ?? [];
        if (weightLogs.isNotEmpty) {
          _latestWeight = (weightLogs.last['weight_kg'] as num?)?.toDouble();
        }

        final symptomLogs = profile['symptom_logs'] as List? ?? [];
        if (symptomLogs.isNotEmpty) {
          final lastSymptoms = symptomLogs.last['symptoms'] as List? ?? [];
          _symptomCount = lastSymptoms.length;
        }

        final kickCounts = profile['kick_counts'] as List? ?? [];
        if (kickCounts.isNotEmpty) {
          _lastKickCount = kickCounts.last['kick_count'];
        }

        if (profile['expected_delivery_date'] != null) {
          _expectedDeliveryDate = DateTime.tryParse(
            profile['expected_delivery_date'],
          );
        }
        if (profile['actual_delivery_date'] != null) {
          _actualDeliveryDate = DateTime.tryParse(
            profile['actual_delivery_date'],
          );
        }
      } else {
        // Handle 404 - profile not found (user needs to complete signup details)
        debugPrint("HomeProvider: Profile not found (404), clearing stats");
      }
    } catch (e) {
      debugPrint("Error fetching home additional stats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load stats for a specific baby
  Future<void> loadBabyStats(String babyId) async {
    if (babyId == _lastFetchedBabyId && _todayFeedCount > 0) {
      return; // cache check
    }
    _lastFetchedBabyId = babyId;

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final results = await Future.wait([
        ApiService().get('/baby/$babyId/feeding'),
        ApiService().get('/baby/$babyId/sleep'),
        ApiService().get('/baby/$babyId/diaper'),
      ]);

      int feedCount = 0;
      String? lastFeed;
      double sleepHours = 0;
      int diaperCount = 0;

      // Process feeding
      if (results[0].statusCode == 200) {
        final data = results[0].data is String
            ? jsonDecode(results[0].data)
            : results[0].data;
        // Check if data structure is valid (handle raw json or map)
        final feeds = (data is Map && data['data'] != null)
            ? (data['data'] as List)
            : <dynamic>[];

        for (var feed in feeds) {
          if (feed['start_time']?.toString().startsWith(today) == true) {
            feedCount++;
            lastFeed ??= feed['start_time'];
          }
        }
      }

      // Process sleep
      if (results[1].statusCode == 200) {
        final data = results[1].data is String
            ? jsonDecode(results[1].data)
            : results[1].data;
        final sleeps = (data is Map && data['data'] != null)
            ? (data['data'] as List)
            : <dynamic>[];

        for (var sleep in sleeps) {
          if (sleep['start_time']?.toString().startsWith(today) == true &&
              sleep['end_time'] != null) {
            final start = DateTime.parse(sleep['start_time']);
            final end = DateTime.parse(sleep['end_time']);
            sleepHours += end.difference(start).inMinutes / 60.0;
          }
        }
      }

      // Process diapers
      if (results[2].statusCode == 200) {
        final data = results[2].data is String
            ? jsonDecode(results[2].data)
            : results[2].data;
        final diapers = (data is Map && data['data'] != null)
            ? (data['data'] as List)
            : <dynamic>[];

        for (var diaper in diapers) {
          if (diaper['time']?.toString().startsWith(today) == true) {
            diaperCount++;
          }
        }
      }

      _todayFeedCount = feedCount;
      _lastFeedTime = lastFeed;
      _todaySleepHours = sleepHours;
      _todayDiaperCount = diaperCount;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading baby stats in home screen: $e');
    }
  }
}
