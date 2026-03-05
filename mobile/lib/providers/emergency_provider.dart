import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmergencyProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _requestSent = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get requestSent => _requestSent;
  String? get error => _error;

  Future<bool> sendEmergencyRequest({
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.post('/emergency', {
        'latitude': latitude,
        'longitude': longitude,
        'description': description ?? 'Emergency assistance needed',
      });

      _isLoading = false;
      if (result['success']) {
        _requestSent = true;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to send emergency request';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Connection error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void resetRequest() {
    _requestSent = false;
    _error = null;
    notifyListeners();
  }
}
