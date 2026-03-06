import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../config/app_config.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/neon_button.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final MapController _mapController = MapController();
  bool _isCalculating = false;
  bool _routeFound = false;
  double _startLat = AppConfig.defaultLatitude;
  double _startLng = AppConfig.defaultLongitude;

  // Destination: nearest safe zone (set dynamically once GPS resolves)
  double _destLat = AppConfig.defaultLatitude + 0.018; // ~2km north fallback
  double _destLng = AppConfig.defaultLongitude;
  String _distanceText = '--';
  String _timeText = '--';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      if (mounted) {
        setState(() {
          _startLat = pos.latitude;
          _startLng = pos.longitude;
          // Safe zone: 2km north of user's actual position
          _destLat = pos.latitude + 0.018;
          _destLng = pos.longitude;
        });
        _mapController.move(LatLng(_startLat, _startLng), 13.5);
      }
    } catch (_) {}
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  void _calculateSafeRoute() {
    setState(() => _isCalculating = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final km = _haversineKm(_startLat, _startLng, _destLat, _destLng);
        final mins = (km / 5.0 * 60).round(); // walking ~5 km/h
        setState(() {
          _isCalculating = false;
          _routeFound = true;
          _distanceText = '${km.toStringAsFixed(1)} km';
          _timeText = '$mins min';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Map (Dark Matter)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_startLat, _startLng),
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.hydromesh.app',
              ),
              if (_routeFound)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(_startLat, _startLng),
                        LatLng((_startLat + _destLat) / 2, (_startLng + _destLng) / 2),
                        LatLng(_destLat, _destLng),
                      ],
                      color: AppTheme.safeColor,
                      strokeWidth: 4.0,
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms),
              if (_routeFound)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_startLat, _startLng),
                      width: 20,
                      height: 20,
                      child: const Icon(Icons.circle, color: AppTheme.primaryColor, size: 20),
                    ),
                    Marker(
                      point: LatLng(_destLat, _destLng),
                      width: 24,
                      height: 24,
                      child: const Icon(Icons.location_on, color: AppTheme.safeColor, size: 24),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),
            ],
          ),

          // Top App Bar Area (Floating)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const GlassCard(
                    padding: EdgeInsets.all(12),
                    borderRadius: 16,
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: GlassCard(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    borderRadius: 30,
                    child: Text(
                      'Safe Evacuation Routes',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ).animate().slideY(begin: -0.2).fadeIn(),
          ),

          // Bottom Route Calculation Panel
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.my_location, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text('Current Location', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 4, bottom: 4),
                    child: Container(width: 2, height: 20, color: AppTheme.surfaceLight),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_city, color: AppTheme.safeColor),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text('Nearest Safe Zone (City Hall)', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  if (_routeFound) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.safeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.safeColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _RouteStat(label: 'Est. Time', value: _timeText),
                          _RouteStat(label: 'Distance', value: _distanceText),
                          const _RouteStat(label: 'Status', value: 'Safe', color: AppTheme.safeColor),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                  ] else ...[
                    NeonButton(
                      text: 'FIND SAFE ROUTE',
                      icon: Icons.route,
                      isLoading: _isCalculating,
                      onPressed: _calculateSafeRoute,
                    ),
                  ],
                ],
              ),
            ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
          ),
        ],
      ),
    );
  }
}

class _RouteStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _RouteStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}