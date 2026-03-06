import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/flood_report.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class ReportProvider with ChangeNotifier {
  List<FloodReport> _reports = [];
  bool _isLoading = false;
  String? _error;
  IO.Socket? _socket;

  List<FloodReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSocketConnected => _socket?.connected ?? false;

  ReportProvider() {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io(AppConfig.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket?.on('new_report', (data) {
      if (data != null) {
        final newReport = FloodReport.fromJson(data);
        _reports.insert(0, newReport);
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

  // Fetch all reports
  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.get('/reports');

    _isLoading = false;
    if (result['success']) {
      _reports = (result['data'] as List)
          .map((r) => FloodReport.fromJson(r))
          .toList();
    } else {
      _error = result['error'];
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
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }
}