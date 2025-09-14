class AppConstants {
  // App Information
  static const String appName = 'Safe Haven';
  static const String appVersion = '1.0.0';
  
  // Emergency Messages
  static const String emergencyLocationMessage = 
      'EMERGENCY! I need help immediately. My current location is: ';
  static const String safeMessage = 
      'I am safe now. Thank you for your concern.';
  
  // Timer Settings
  static const int emergencyCheckInMinutes = 5; // 5 minutes default
  static const int fakeCallDelaySeconds = 3; // 3 seconds delay
  
  // Storage Keys
  static const String emergencyContactsKey = 'emergency_contacts';
  static const String medicalInfoKey = 'medical_info';
  static const String checkInTimerKey = 'check_in_timer_minutes';
  
  // Audio Settings
  static const String sirenAudioPath = 'sounds/siren.mp3';
  static const double sirenVolume = 1.0;
  
  // Location Settings
  static const double locationAccuracy = 10.0; // meters
  static const int locationTimeoutSeconds = 10;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardElevation = 4.0;
  static const double buttonHeight = 48.0;
  
  // Colors (Material Design)
  static const int primaryColorValue = 0xFFE53E3E; // Red
  static const int secondaryColorValue = 0xFF2D3748; // Dark Gray
  static const int successColorValue = 0xFF38A169; // Green
  static const int warningColorValue = 0xFFD69E2E; // Yellow
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Shake Detection
  static const double shakeThreshold = 15.0;
  static const Duration shakeTimeout = Duration(seconds: 2);
}
