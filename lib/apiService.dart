import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Global navigator key - set this in your main.dart
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Get the stored JWT token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Clear the token and navigate to login screen
  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');

    // Navigate to login screen
    if (navigatorKey?.currentState != null) {
      navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Build headers with authorization token
  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// GET request with automatic token handling and 401 redirect
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$kBaseRoute$endpoint').replace(
        queryParameters: queryParams,
      );
      final headers = await _buildHeaders(additionalHeaders: additionalHeaders);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return ApiResponse(
          success: false,
          statusCode: 401,
          message: 'Unauthorized. Please login again.',
        );
      }

      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  /// POST request with automatic token handling and 401 redirect
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$kBaseRoute$endpoint');
      final headers = await _buildHeaders(additionalHeaders: additionalHeaders);

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return ApiResponse(
          success: false,
          statusCode: 401,
          message: 'Unauthorized. Please login again.',
        );
      }

      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  /// PUT request with automatic token handling and 401 redirect
  Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$kBaseRoute$endpoint');
      final headers = await _buildHeaders(additionalHeaders: additionalHeaders);

      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return ApiResponse(
          success: false,
          statusCode: 401,
          message: 'Unauthorized. Please login again.',
        );
      }

      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  /// DELETE request with automatic token handling and 401 redirect
  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$kBaseRoute$endpoint');
      final headers = await _buildHeaders(additionalHeaders: additionalHeaders);

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return ApiResponse(
          success: false,
          statusCode: 401,
          message: 'Unauthorized. Please login again.',
        );
      }

      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  /// Parse HTTP response into ApiResponse
  ApiResponse _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      return ApiResponse(
        success: isSuccess,
        statusCode: response.statusCode,
        data: data,
        message: isSuccess ? null : (data['message'] ?? 'Request failed'),
      );
    } catch (e) {
      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
        message: 'Failed to parse response',
      );
    }
  }
}

/// Response wrapper for API calls
class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? message;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
  });
}
