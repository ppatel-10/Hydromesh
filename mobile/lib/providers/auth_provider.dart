import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get error => _error;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth_token');
    if (saved != null) {
      _token = saved;
      ApiService.setToken(saved); // restore into HTTP client too
      notifyListeners();
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AuthService.login(email, password);

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      _token = result['token'];
      await _saveToken(_token!);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String role = 'citizen',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AuthService.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      _token = result['token'];
      await _saveToken(_token!);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  void logout() {
    AuthService.logout();
    _clearToken();
    _user = null;
    _token = null;
    notifyListeners();
  }
}