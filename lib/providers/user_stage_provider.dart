import 'package:flutter/foundation.dart';
import 'package:project_frontend/apiService.dart';

/// Centralized state management for user's pregnancy/postpartum stage
/// and baby data. Wrap your app with ChangeNotifierProvider<UserStageProvider>
class UserStageProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _isInitialLoad = true; // First load vs refresh
  bool _isPregnant = true;
  bool _profileNotFound = false;
  String? _errorMessage;
  Map<String, dynamic>? _motherProfile;
  List<Map<String, dynamic>> _babies = [];
  String? _selectedBabyId;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialLoad => _isInitialLoad; // True only on first load
  bool get isPregnant => _isPregnant;
  bool get isPostpartum => !_isPregnant;
  bool get profileNotFound => _profileNotFound;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get motherProfile => _motherProfile;
  List<Map<String, dynamic>> get babies => _babies;
  bool get hasBaby => _babies.isNotEmpty;
  String? get selectedBabyId => _selectedBabyId;

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get currently selected baby, or first baby if none selected
  Map<String, dynamic>? get selectedBaby {
    if (_babies.isEmpty) return null;
    if (_selectedBabyId == null) return _babies.first;
    return _babies.firstWhere(
      (b) => b['_id'] == _selectedBabyId,
      orElse: () => _babies.first,
    );
  }

  /// Load user profile and determine stage
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null; // Clear previous errors on retry
    notifyListeners();
    debugPrint("UserStageProvider: Loading profile...");

    try {
      final response = await ApiService().get('/mother/me/profile');
      debugPrint(
        "UserStageProvider: Profile response status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        _motherProfile = response.data['data'];
        _profileNotFound = false;
        _errorMessage = null;

        // pregnancy_week is returned at root level of response, not inside data
        final pregWeek = response.data['pregnancy_week'];
        if (pregWeek != null) {
          _motherProfile?['pregnancy_week'] = pregWeek;
        }

        debugPrint("UserStageProvider: Profile data: $_motherProfile");
        debugPrint(
          "UserStageProvider: Profile status: ${_motherProfile?['status']}, week: $pregWeek",
        );
        // Fix: Backend doesn't return is_pregnant, check status field instead
        final status = _motherProfile?['status'];
        _isPregnant = status == 'pregnant' || status != 'delivered';
        debugPrint("UserStageProvider: isPregnant = $_isPregnant");

        // If postpartum, also load babies
        if (!_isPregnant) {
          debugPrint(
            "UserStageProvider: User is postpartum, loading babies...",
          );
          await _loadBabies();
        } else {
          debugPrint("UserStageProvider: User is pregnant, skipping baby load");
        }
      } else if (response.statusCode == 404) {
        // Profile not found - user needs to complete signup details
        debugPrint(
          "UserStageProvider: Profile not found (404). User needs to complete profile.",
        );
        _profileNotFound = true;
        _motherProfile = null;
      } else if (response.statusCode == 0) {
        // Network error (statusCode 0 indicates network failure)
        debugPrint(
          "UserStageProvider: Network error occurred",
        );
        _errorMessage =
            'Unable to connect to server. Please check your internet connection and try again.';
      } else {
        debugPrint(
          "UserStageProvider: Failed to load profile: ${response.message}",
        );
        _errorMessage =
            response.message ?? 'Failed to load profile. Please try again.';
      }
    } catch (e) {
      debugPrint('UserStageProvider: Failed to load profile: $e');
      _errorMessage =
          'Network error: Unable to connect. Please check your connection and try again.';
    }

    _isLoading = false;
    _isInitialLoad = false; // After first load, this stays false
    notifyListeners();
  }

  /// Load all babies for this mother
  Future<void> _loadBabies() async {
    debugPrint("UserStageProvider: _loadBabies called");
    try {
      final response = await ApiService().get('/baby/my-babies');
      debugPrint(
        "UserStageProvider: Babies response status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        debugPrint("UserStageProvider: Raw babies data: $data");

        if (data is List) {
          _babies = List<Map<String, dynamic>>.from(data);
          debugPrint("UserStageProvider: Loaded ${_babies.length} babies");

          // Validate selectedBabyId exists in the list, or reset it
          if (_babies.isEmpty) {
            _selectedBabyId = null;
            debugPrint("UserStageProvider: No babies, clearing selectedBabyId");
          } else if (_selectedBabyId == null ||
              !_babies.any((b) => b['_id'] == _selectedBabyId)) {
            // Auto-select first baby if none selected or if current selection is invalid
            _selectedBabyId = _babies.first['_id'];
            debugPrint(
              "UserStageProvider: Auto-selected baby ID: $_selectedBabyId",
            );
          }
        } else {
          debugPrint("UserStageProvider: Warning - Babies data is not a list!");
        }
      } else {
        debugPrint(
          "UserStageProvider: Failed to load babies: ${response.message}",
        );
      }
    } catch (e) {
      debugPrint('UserStageProvider: Error loading babies: $e');
    }
  }

  /// Switch to a different baby
  void selectBaby(String babyId) {
    debugPrint("UserStageProvider: Switching to baby $babyId");
    if (_babies.any((b) => b['_id'] == babyId)) {
      _selectedBabyId = babyId;
      notifyListeners();
    } else {
      debugPrint("UserStageProvider: Baby ID not found in list");
    }
  }

  /// Called after marking delivery - refresh data
  Future<void> onDeliveryMarked() async {
    debugPrint("UserStageProvider: onDeliveryMarked called");
    await loadProfile();
  }

  /// Add a new baby (after creating via API)
  void addBaby(Map<String, dynamic> baby) {
    debugPrint("UserStageProvider: Manually adding baby: $baby");
    _babies.add(baby);
    if (_selectedBabyId == null) {
      _selectedBabyId = baby['_id'];
    }
    notifyListeners();
  }

  /// Refresh babies list
  Future<void> refreshBabies() async {
    debugPrint("UserStageProvider: refreshBabies called");
    await _loadBabies();
    notifyListeners();
  }
}
