import 'package:flutter/foundation.dart';
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/models/caregiver.dart';
import 'package:project_frontend/models/caregiver_booking.dart';

class CaregiverProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Caregiver? _profile;
  List<CaregiverBooking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  bool _wasUnauthorized = false;

  // Getters
  Caregiver? get profile => _profile;
  List<CaregiverBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;
  bool get wasUnauthorized => _wasUnauthorized;

  // Booking counts
  int get pendingCount => _bookings.where((b) => b.status == 'pending').length;
  int get acceptedCount =>
      _bookings.where((b) => b.status == 'accepted').length;
  int get completedCount =>
      _bookings.where((b) => b.status == 'completed').length;

  // Filtered bookings
  List<CaregiverBooking> get pendingBookings =>
      _bookings.where((b) => b.status == 'pending').toList();
  List<CaregiverBooking> get acceptedBookings =>
      _bookings.where((b) => b.status == 'accepted').toList();
  List<CaregiverBooking> get completedBookings =>
      _bookings.where((b) => b.status == 'completed').toList();

  /// Get currently active booking (accepted and within date range)
  CaregiverBooking? get activeBooking {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      return _bookings.firstWhere((b) {
        if (b.status != 'accepted') return false;
        final start = DateTime(
          b.startDate.year,
          b.startDate.month,
          b.startDate.day,
        );
        final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
        return !today.isBefore(start) && !today.isAfter(end);
      });
    } catch (_) {
      return null;
    }
  }

  /// Total earnings from completed bookings
  double get totalEarnings {
    return completedBookings.fold(0.0, (sum, b) => sum + b.totalAmount);
  }

  /// Number of completed jobs
  int get completedJobsCount => completedBookings.length;

  /// Load caregiver profile from API
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    _wasUnauthorized = false;
    notifyListeners();

    try {
      final response = await _api.get('/caregiver/me/profile');

      if (response.success && response.data != null) {
        _profile = Caregiver.fromJson(response.data['data']);
      } else if (response.statusCode == 401) {
        // 401 unauthorized - ApiService handles redirect to login
        _wasUnauthorized = true;
        _profile = null;
      } else {
        _error = response.message ?? 'Failed to load profile';
        // 404 means profile doesn't exist yet - not an error
        if (response.statusCode == 404) {
          _error = null;
          _profile = null;
        }
      }
    } catch (e) {
      _error = 'Error loading profile: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load bookings assigned to this caregiver
  Future<void> loadBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/caregiver-booking/for-me');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        _bookings = data.map((e) => CaregiverBooking.fromJson(e)).toList();
      } else {
        _error = response.message ?? 'Failed to load bookings';
      }
    } catch (e) {
      _error = 'Error loading bookings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Accept a pending booking
  Future<bool> acceptBooking(String bookingId) async {
    try {
      final response = await _api.put('/caregiver-booking/$bookingId/accept');

      if (response.success) {
        // Update local booking status
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          await loadBookings(); // Refresh bookings
        }
        return true;
      } else {
        _error = response.message ?? 'Failed to accept booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error accepting booking: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reject a pending booking
  Future<bool> rejectBooking(String bookingId) async {
    try {
      final response = await _api.put('/caregiver-booking/$bookingId/reject');

      if (response.success) {
        await loadBookings(); // Refresh bookings
        return true;
      } else {
        _error = response.message ?? 'Failed to reject booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error rejecting booking: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark a booking as completed
  Future<bool> completeBooking(String bookingId) async {
    try {
      final response = await _api.put('/caregiver-booking/$bookingId/complete');

      if (response.success) {
        await loadBookings(); // Refresh bookings
        return true;
      } else {
        _error = response.message ?? 'Failed to complete booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error completing booking: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update caregiver profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.put('/caregiver/me/profile', body: data);

      if (response.success && response.data != null) {
        _profile = Caregiver.fromJson(response.data['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear all data (for logout)
  void clear() {
    _profile = null;
    _bookings = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
