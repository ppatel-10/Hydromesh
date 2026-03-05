import 'package:flutter/material.dart';

class MapProvider with ChangeNotifier {
  double _latitude = 51.505;
  double _longitude = -0.09;
  double _zoom = 13.0;
  bool _isLoading = false;
  String? _error;

  double get latitude => _latitude;
  double get longitude => _longitude;
  double get zoom => _zoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void updateZoom(double zoom) {
    _zoom = zoom;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
