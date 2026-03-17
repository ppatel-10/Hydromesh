import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/flood_report.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class ReportProvider with ChangeNotifier {
  List<FloodReport> _reports = [];
  bool _isLoading = false;
  String? _error;
  bool _fromCache = false;
  IO.Socket? _socket;

  static const _cacheKey = 'cached_reports';

  List<FloodReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get fromCache => _fromCache;
  bool get isSocketConnected => _socket?.connected ?? false;

  ReportProvider() {
    _initSocket();
    _loadCache(); // show cached data instantly on startup
  }

  // Load previously cached reports from SharedPreferences
  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null && _reports.isEmpty) {
        final list = jsonDecode(raw) as List;
        _reports = list.map((r) => FloodReport.fromJson(r)).toList();
        _fromCache = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  // Persist current reports to cache
  Future<void> _saveCache(List<FloodReport> reports) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(reports.map((r) => r.toJson()).toList());
      await prefs.setString(_cacheKey, raw);
    } catch (_) {}
  }

  void _initSocket() {
    _socket = IO.io(AppConfig.socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    _socket?.on('new_report', (data) {
      if (data != null) {
        final newReport = FloodReport.fromJson(data);
        _reports.insert(0, newReport);
        _fromCache = false;
        _saveCache(_reports);
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  // Fetch all reports — falls back to cache on failure
  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.get('/reports');

    _isLoading = false;
    if (result['success']) {
      final data = result['data'];
      if (data is List) {
        _reports = data
            .whereType<Map<String, dynamic>>()
            .map((r) => FloodReport.fromJson(r))
            .toList();
      } else {
        _reports = [];
      }
      _fromCache = false;
      _error = null;
      _saveCache(_reports);
    } else {
      _error = result['error'];
      // Keep showing cached data — don't clear _reports
    }
    notifyListeners();
  }

  // Submit report
  Future<bool> submitReport(FloodReport report) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.post('/reports', report.toJson());

    _isLoading = false;
    if (result['success']) {
      _reports.insert(0, FloodReport.fromJson(result['data']));
      _fromCache = false;
      _saveCache(_reports);
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }
}