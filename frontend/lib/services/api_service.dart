import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';
import '../models/land_listing.dart' as land;
import '../models/match_request.dart';
import '../models/notification.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get saved token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAccessToken);
  }

  // Save tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, accessToken);
    await prefs.setString(AppConstants.keyRefreshToken, refreshToken);
  }

  // Save user data
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserData, jsonEncode(userData));
  }

  // Get saved user data
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(AppConstants.keyUserData);
    if (userDataString != null) {
      return User.fromJson(jsonDecode(userDataString));
    }
    return null;
  }

  // Clear all saved data
  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
    await prefs.remove(AppConstants.keyUserData);
  }

  // Common headers
  Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (needsAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.register}'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body).toString());
    }
  }

  // Login
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.login}'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], data['refresh']);
      await _saveUserData(data['user']);
      return User.fromJson(data['user']);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
    }
  }

  // Get profile
  Future<User> getProfile() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.profile}'),
      headers: await _getHeaders(needsAuth: true),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      await _saveUserData(userData);
      return User.fromJson(userData);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Update profile
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.profileUpdate}'),
      headers: await _getHeaders(needsAuth: true),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body)['user'];
      await _saveUserData(userData);
      return User.fromJson(userData);
    } else {
      throw Exception(jsonDecode(response.body).toString());
    }
  }

  // Get counties
  Future<List<County>> getCounties() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.counties}'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => County.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load counties');
    }
  }

  // Get subcounties by county
  Future<List<Subcounty>> getSubcounties(int countyId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.subcounties}$countyId/subcounties/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Subcounty.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load subcounties');
    }
  }

  // Get restoration types
  Future<List<land.RestorationType>> getRestorationTypes() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.restorationTypes}'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => land.RestorationType.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load restoration types');
    }
  }

  // Get land listings
  Future<List<land.LandListing>> getLandListings({Map<String, String>? filters}) async {
    var uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.lands}');
    
    if (filters != null && filters.isNotEmpty) {
      uri = uri.replace(queryParameters: filters);
    }

    final response = await http.get(
      uri,
      headers: await _getHeaders(needsAuth: true),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => land.LandListing.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load land listings');
    }
  }

  // Create land listing
  Future<land.LandListing> createLandListing(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.lands}'),
      headers: await _getHeaders(needsAuth: true),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return land.LandListing.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body).toString());
    }
  }

  // Update land listing
  Future<land.LandListing> updateLandListing(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.lands}$id/'),
      headers: await _getHeaders(needsAuth: true),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return land.LandListing.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body).toString());
    }
  }

  // Delete land listing
  Future<void> deleteLandListing(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.lands}$id/'),
      headers: await _getHeaders(needsAuth: true),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(jsonDecode(response.body).toString());
    }
  }

  // Get match requests
  Future<List<MatchRequest>> getMatchRequests() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.matchRequests}'),
      headers: await _getHeaders(needsAuth: true),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MatchRequest.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load match requests');
    }
  }

  // Create match request
  Future<MatchRequest> createMatchRequest(int landListingId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.matchRequestsCreate}'),
      headers: await _getHeaders(needsAuth: true),
      body: jsonEncode({'land_listing_id': landListingId}),
    );

    if (response.statusCode == 201) {
      return MatchRequest.fromJson(jsonDecode(response.body)['match_request']);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to create match request');
    }
  }

  // Update match request status
  Future<MatchRequest> updateMatchRequestStatus(int requestId, String action) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.matchRequestsUpdateStatus}$requestId/update-status/'),
      headers: await _getHeaders(needsAuth: true),
      body: jsonEncode({'action': action}),
    );

    if (response.statusCode == 200) {
      return MatchRequest.fromJson(jsonDecode(response.body)['match_request']);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update match request');
    }
  }

  // Get notifications
  Future<List<AppNotification>> getNotifications() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.notifications}'),
      headers: await _getHeaders(needsAuth: true),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => AppNotification.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Mark notification as read
  Future<void> markNotificationRead(int notificationId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.notificationsMarkRead}$notificationId/mark-read/'),
      headers: await _getHeaders(needsAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }
}