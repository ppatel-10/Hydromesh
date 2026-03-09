import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/report_provider.dart';
import '../providers/auth_provider.dart';
import '../models/flood_report.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/neon_button.dart';
import '../widgets/report/water_level_selector.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descriptionController = TextEditingController();
  String _selectedLevel = 'ankle';
  double? _currentLat;
  double? _currentLng;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocating = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLocating = false);
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
        _isLocating = false;
      });
    } catch (e) {
      setState(() => _isLocating = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a report'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final report = FloodReport(
      latitude: _currentLat ?? AppConfig.defaultLatitude,
      longitude: _currentLng ?? AppConfig.defaultLongitude,
      waterLevel: _selectedLevel,
      description: _descriptionController.text.trim(),
    );

    final provider = Provider.of<ReportProvider>(context, listen: false);
    final success = await provider.submitReport(report);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: AppTheme.safeColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit report'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<ReportProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('New Incident Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GPS Location Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _isLocating
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _currentLat != null ? Icons.location_on : Icons.location_off,
                          color: _currentLat != null ? AppTheme.safeColor : AppTheme.textSecondary,
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isLocating
                          ? 'Locating your position...'
                          : _currentLat != null
                              ? 'GPS: ${_currentLat!.toStringAsFixed(4)}, ${_currentLng!.toStringAsFixed(4)}'
                              : 'Location unavailable — using default',
                      style: TextStyle(
                        color: _currentLat != null ? Colors.white : AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (_currentLat == null && !_isLocating)
                    GestureDetector(
                      onTap: _getLocation,
                      child: const Icon(Icons.refresh, color: AppTheme.primaryColor, size: 20),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WaterLevelSelector(
                    onSelected: (level) => setState(() => _selectedLevel = level),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 24),
            
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details & Observations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Describe the situation (e.g. road blocked, rapid flow)...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            NeonButton(
              text: 'SUBMIT REPORT',
              icon: Icons.send_rounded,
              isLoading: isLoading,
              onPressed: _submitReport,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}
