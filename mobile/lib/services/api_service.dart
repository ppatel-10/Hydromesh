import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on TimeoutException {
      return {'success': false, 'error': 'Request timed out — server may be waking up, try again'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.runtimeType}'};
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> body
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on TimeoutException {
      return {'success': false, 'error': 'Request timed out — server may be waking up, try again'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.runtimeType}'};
    }
  }

  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        String errorMsg = 'Server error ${response.statusCode}';
        if (data is Map) {
          if (data['message'] != null) {
            errorMsg = data['message'].toString();
          } else if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            errorMsg = (data['errors'] as List)
                .map((e) => e is Map ? e['msg'] ?? e['message'] ?? '' : e.toString())
                .where((s) => s.toString().isNotEmpty)
                .join(', ');
          } else if (data['error'] != null) {
            errorMsg = data['error'].toString();
          }
        }
        return {'success': false, 'error': errorMsg};
      }
    } catch (_) {
      return {'success': false, 'error': 'Invalid server response (${response.statusCode})'};
    }
  }
}