class AppConfig {
  static const String appName = 'HydroMesh';
  // TODO: Update to your Render.com service URL after deployment
  // e.g. https://hydromesh-backend.onrender.com/api
  static const String apiBaseUrl = 'https://backend-six-omega-34.vercel.app/api';
  static const String socketUrl = 'https://backend-six-omega-34.vercel.app';
  
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