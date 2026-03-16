import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class SafePoint {
  final String name;
  final double latitude;
  final double longitude;
  final String description;

  const SafePoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
  });
}

class SimulationProvider with ChangeNotifier {
  String _activeCity = 'london';
  int? _activeSimType;
  String? _activeSimName;
  bool _isLoading = false;
  bool _isStopping = false;

  String get activeCity => _activeCity;
  int? get activeSimType => _activeSimType;
  String? get activeSimName => _activeSimName;
  bool get isActive => _activeSimType != null;
  bool get isLoading => _isLoading;
  bool get isStopping => _isStopping;

  static const Map<String, List<SafePoint>> _safePoints = {
    'london': [
      SafePoint(name: 'Hyde Park Relief Camp', latitude: 51.5073, longitude: -0.1657, description: 'Emergency assembly at Hyde Park'),
      SafePoint(name: 'Battersea Park Safety Zone', latitude: 51.4826, longitude: -0.1561, description: 'High-ground shelter at Battersea'),
      SafePoint(name: 'Victoria Embankment Barrier', latitude: 51.5065, longitude: -0.1197, description: 'Flood defence barrier assembly point'),
      SafePoint(name: 'Olympic Park Emergency Hub', latitude: 51.5445, longitude: 0.0120, description: 'East London emergency coordination hub'),
    ],
    'mumbai': [
      SafePoint(name: 'Azad Maidan Relief Centre', latitude: 18.9390, longitude: 72.8347, description: 'Municipal emergency relief camp'),
      SafePoint(name: 'Shivaji Park Assembly', latitude: 19.0279, longitude: 72.8457, description: 'Open ground community relief area'),
      SafePoint(name: 'BKC Emergency Camp', latitude: 19.0650, longitude: 72.8650, description: 'Business district emergency shelter'),
      SafePoint(name: 'Andheri Sports Ground', latitude: 19.1184, longitude: 72.8482, description: 'Northern Mumbai safe assembly zone'),
    ],
    'miami': [
      SafePoint(name: 'Bayfront Park Shelter', latitude: 25.7744, longitude: -80.1868, description: 'Downtown waterfront assembly point'),
      SafePoint(name: 'Virginia Key Safety Area', latitude: 25.7388, longitude: -80.1621, description: 'Island emergency assembly zone'),
      SafePoint(name: 'Tropical Park Relief Hub', latitude: 25.7325, longitude: -80.3345, description: 'Inland high-ground shelter'),
      SafePoint(name: 'Amelia Earhart Park', latitude: 25.8890, longitude: -80.2856, description: 'Northern Miami emergency zone'),
    ],
    'tokyo': [
      SafePoint(name: 'Yoyogi Park Assembly', latitude: 35.6715, longitude: 139.6942, description: 'Central Tokyo emergency assembly'),
      SafePoint(name: 'Odaiba Relief Area', latitude: 35.6244, longitude: 139.7745, description: 'Waterfront emergency coordination zone'),
      SafePoint(name: 'Ueno Park Shelter', latitude: 35.7148, longitude: 139.7708, description: 'North Tokyo elevated safe area'),
      SafePoint(name: 'Shinjuku Gyoen Hub', latitude: 35.6852, longitude: 139.7100, description: 'Western Tokyo emergency relief centre'),
    ],
  };

  List<SafePoint> safePointsForCity(String city) =>
      _safePoints[city] ?? _safePoints['london']!;

  SafePoint nearestSafePoint(double userLat, double userLng) {
    final points = safePointsForCity(_activeCity);
    SafePoint nearest = points.first;
    double minDist = _haversine(userLat, userLng, nearest.latitude, nearest.longitude);
    for (final p in points.skip(1)) {
      final d = _haversine(userLat, userLng, p.latitude, p.longitude);
      if (d < minDist) {
        minDist = d;
        nearest = p;
      }
    }
    return nearest;
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  void setActiveCity(String city) {
    _activeCity = city;
    notifyListeners();
  }

  Future<bool> startSimulation(int type, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/simulation/run', {
        'type': type,
        'cityKey': _activeCity,
      });
      _isLoading = false;
      if (res['success'] == true) {
        _activeSimType = type;
        _activeSimName = name;
        notifyListeners();
        return true;
      }
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> stopSimulation() async {
    _isStopping = true;
    notifyListeners();
    try {
      await ApiService.post('/simulation/stop', {'cityKey': _activeCity});
    } catch (_) {}
    _isStopping = false;
    _activeSimType = null;
    _activeSimName = null;
    notifyListeners();
  }
}
