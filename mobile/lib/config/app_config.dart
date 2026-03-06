class AppConfig {
  static const String appName = 'HydroMesh';
  static const String apiBaseUrl = 'https://hydromesh-backend.onrender.com/api';
  static const String socketUrl = 'https://hydromesh-backend.onrender.com';
  
  // Map settings
  static const double defaultLatitude = 51.5074;
  static const double defaultLongitude = -0.1278;
  static const double defaultZoom = 13.0;
  
  // Water levels
  static const List<String> waterLevels = [
    'ankle',
    'knee',
    'waist',
    'chest',
    'above_head'
  ];
}