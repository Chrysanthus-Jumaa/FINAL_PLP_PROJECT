class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000/api'; // Android emulator
  // Use 'http://localhost:8000/api' for web
  // Use 'http://YOUR_COMPUTER_IP:8000/api' for physical device
  
  // Endpoints
  static const String register = '/register/';
  static const String login = '/login/';
  static const String profile = '/profile/';
  static const String profileUpdate = '/profile/update/';
  static const String counties = '/counties/';
  static const String subcounties = '/counties/'; // + {id}/subcounties/
  static const String restorationTypes = '/restoration-types/';
  static const String lands = '/lands/';
  static const String matchRequests = '/match-requests/';
  static const String matchRequestsCreate = '/match-requests/create/';
  static const String matchRequestsUpdateStatus = '/match-requests/'; // + {id}/update-status/
  static const String notifications = '/notifications/';
  static const String notificationsMarkRead = '/notifications/'; // + {id}/mark-read/
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  
  // Cloudinary (we'll configure these later)
  static const String cloudinaryCloudName = 'your_cloud_name';
  static const String cloudinaryUploadPreset = 'your_upload_preset';
  
  // App Info
  static const String appName = 'ZingiraNakama';
  static const String appSlogan = 'Connecting Land to Purpose';
}