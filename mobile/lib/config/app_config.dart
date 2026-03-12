class AppConfig {
  static const String appName = 'HydroMesh';

  // Switch between: 'local', 'render', 'azure'
  static const String _env = 'render';

  static const String _localIp = '192.168.0.170'; // your Mac's LAN IP
  static const String _localBaseUrl = 'http://$_localIp:3000/api';
  static const String _localSocketUrl = 'http://$_localIp:3000';

  static const String _renderBaseUrl = 'https://hydromesh-api.onrender.com/api';
  static const String _renderSocketUrl = 'https://hydromesh-api.onrender.com';

  // Azure App Service — update name after creating the app
  static const String _azureAppName = 'hydromesh-api';
  static const String _azureBaseUrl = 'https://$_azureAppName.azurewebsites.net/api';
  static const String _azureSocketUrl = 'https://$_azureAppName.azurewebsites.net';

  static String get apiBaseUrl {
    switch (_env) {
      case 'local': return _localBaseUrl;
      case 'azure': return _azureBaseUrl;
      default: return _renderBaseUrl;
    }
  }

  static String get socketUrl {
    switch (_env) {
      case 'local': return _localSocketUrl;
      case 'azure': return _azureSocketUrl;
      default: return _renderSocketUrl;
    }
  }
  
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