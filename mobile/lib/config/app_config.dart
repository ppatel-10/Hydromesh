class AppConfig {
  static const String appName = 'HydroMesh';

  // Switch between local dev (true) and production Render (false)
  static const bool _useLocalhost = true;

  static const String _localIp = '192.168.0.170'; // your Mac's LAN IP
  static const String _localBaseUrl = 'http://$_localIp:3000/api';
  static const String _localSocketUrl = 'http://$_localIp:3000';

  static const String _prodBaseUrl = 'https://hydromesh-api.onrender.com/api';
  static const String _prodSocketUrl = 'https://hydromesh-api.onrender.com';

  static const String apiBaseUrl = _useLocalhost ? _localBaseUrl : _prodBaseUrl;
  static const String socketUrl = _useLocalhost ? _localSocketUrl : _prodSocketUrl;
  
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