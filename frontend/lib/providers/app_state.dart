import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/land_listing.dart' as land;
import '../models/match_request.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // User state
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Data state
  List<land.LandListing> _landListings = [];
  List<MatchRequest> _matchRequests = [];
  List<AppNotification> _notifications = [];
  int _unreadNotificationCount = 0;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<land.LandListing> get landListings => _landListings;
  List<MatchRequest> get matchRequests => _matchRequests;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationCount => _unreadNotificationCount;
  bool get isAuthenticated => _currentUser != null;
  bool get isRestorer => _currentUser?.role == 'restorer';
  bool get isOrganization => _currentUser?.role == 'organization';

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize app (check if user is already logged in)
  Future<void> initializeApp() async {
    setLoading(true);
    try {
      final savedUser = await _apiService.getSavedUser();
      if (savedUser != null) {
        _currentUser = savedUser;
        // Load initial data
        await Future.wait([
          loadLandListings(),
          loadMatchRequests(),
          loadNotifications(),
        ]);
      }
    } catch (e) {
      debugPrint('Initialize error: $e');
    } finally {
      setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    setLoading(true);
    clearError();
    try {
      _currentUser = await _apiService.login(email, password);
      
      // Load initial data after login
      await Future.wait([
        loadLandListings(),
        loadMatchRequests(),
        loadNotifications(),
      ]);
      
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearSavedData();
    _currentUser = null;
    _landListings = [];
    _matchRequests = [];
    _notifications = [];
    _unreadNotificationCount = 0;
    notifyListeners();
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    try {
      _currentUser = await _apiService.getProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Refresh profile error: $e');
    }
  }

  // Load land listings
  Future<void> loadLandListings({Map<String, String>? filters}) async {
    try {
      _landListings = await _apiService.getLandListings(filters: filters);
      notifyListeners();
    } catch (e) {
      debugPrint('Load land listings error: $e');
      setError('Failed to load land listings');
    }
  }

  // Add land listing
  Future<bool> addLandListing(Map<String, dynamic> data) async {
    setLoading(true);
    clearError();
    try {
      await _apiService.createLandListing(data);
      await loadLandListings();
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Update land listing
  Future<bool> updateLandListing(int id, Map<String, dynamic> data) async {
    setLoading(true);
    clearError();
    try {
      await _apiService.updateLandListing(id, data);
      await loadLandListings();
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Delete land listing
  Future<bool> deleteLandListing(int id) async {
    setLoading(true);
    clearError();
    try {
      await _apiService.deleteLandListing(id);
      await loadLandListings();
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Load match requests
  Future<void> loadMatchRequests() async {
    try {
      _matchRequests = await _apiService.getMatchRequests();
      notifyListeners();
    } catch (e) {
      debugPrint('Load match requests error: $e');
    }
  }

  // Create match request
  Future<bool> createMatchRequest(int landListingId) async {
    setLoading(true);
    clearError();
    try {
      await _apiService.createMatchRequest(landListingId);
      await Future.wait([
        loadMatchRequests(),
        loadLandListings(),
      ]);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Update match request status
  Future<bool> updateMatchRequestStatus(int requestId, String action) async {
    setLoading(true);
    clearError();
    try {
      await _apiService.updateMatchRequestStatus(requestId, action);
      await Future.wait([
        loadMatchRequests(),
        loadLandListings(),
        loadNotifications(),
      ]);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Load notifications
  Future<void> loadNotifications() async {
    try {
      _notifications = await _apiService.getNotifications();
      _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      debugPrint('Load notifications error: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationRead(int notificationId) async {
    try {
      await _apiService.markNotificationRead(notificationId);
      await loadNotifications();
    } catch (e) {
      debugPrint('Mark notification read error: $e');
    }
  }
}