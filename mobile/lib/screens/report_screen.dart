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
  bool _submitted = false;
  Map<String, dynamic>? _submittedData;

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
      setState(() {
        _submitted = true;
        _submittedData = {
          'level': _selectedLevel,
          'description': _descriptionController.text.trim(),
          'lat': _currentLat,
          'lng': _currentLng,
        };
      });
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

    if (_submitted) return _buildSuccessState(context);

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

  Widget _buildSuccessState(BuildContext context) {
    final level = _submittedData?['level'] as String? ?? _selectedLevel;
    final desc = _submittedData?['description'] as String?;
    final lat = _submittedData?['lat'] as double?;
    final lng = _submittedData?['lng'] as double?;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.safeColor.withValues(alpha: 0.12),
                  border: Border.all(color: AppTheme.safeColor, width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 50, color: AppTheme.safeColor),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              const Text(
                'Report Submitted!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 8),

              const Text(
                'Thank you for helping your community stay safe.',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 28),

              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow(
                      Icons.water_drop_outlined,
                      'Water Level',
                      '${level[0].toUpperCase()}${level.substring(1)}',
                    ),
                    const Divider(color: AppTheme.surfaceLight, height: 20),
                    if (desc != null && desc.isNotEmpty) ...[
                      _summaryRow(
                          Icons.notes_rounded, 'Description', desc),
                      const Divider(color: AppTheme.surfaceLight, height: 20),
                    ],
                    _summaryRow(
                      Icons.location_on_outlined,
                      'Location',
                      lat != null
                          ? '${lat.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}'
                          : 'Default location used',
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.1).fadeIn(delay: 350.ms),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(
                            color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('View on Map'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/map');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.15),
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
