import 'package:intl/intl.dart';

/// Utility class for standardized date/time handling across the app.
/// All dates from API are in UTC and need to be converted to local time for display.
class DateTimeUtils {
  /// Parse an ISO 8601 string from API and convert to local time.
  /// Returns null if the string is null or invalid.
  static DateTime? parseToLocal(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Format a DateTime as time only: "h:mm a" (e.g., "2:30 PM")
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format a DateTime as date and time: "MMM d, h:mm a" (e.g., "Jan 26, 2:30 PM")
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  /// Format a DateTime as date only: "MMM d, yyyy" (e.g., "Jan 26, 2026")
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Format a DateTime as short date: "MMM d" (e.g., "Jan 26")
  static String formatShortDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('MMM d').format(dateTime);
  }

  /// Parse and format in one step - for displaying API dates.
  static String parseAndFormatDateTime(String? isoString) {
    final dt = parseToLocal(isoString);
    return formatDateTime(dt);
  }

  /// Parse and format time only from API string.
  static String parseAndFormatTime(String? isoString) {
    final dt = parseToLocal(isoString);
    return formatTime(dt);
  }
}
