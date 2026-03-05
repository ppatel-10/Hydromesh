import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../providers/report_provider.dart';
import '../models/flood_report.dart';
import '../widgets/common/glass_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. The Map Layer
          Consumer<ReportProvider>(
            builder: (context, reportProvider, child) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    AppConfig.defaultLatitude,
                    AppConfig.defaultLongitude,
                  ),
                  initialZoom: AppConfig.defaultZoom,
                ),
                children: [
                  // Dark Mode Tile Layer 
                  // (Using CartoDB Dark Matter as a placeholder for a dark map theme)
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.hydromesh.app',
                  ),
                  
                  // F-07: Example Risk Zones (Polygons)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: const [
                          LatLng(51.515, -0.105),
                          LatLng(51.510, -0.090),
                          LatLng(51.500, -0.095),
                          LatLng(51.505, -0.110),
                        ],
                        color: AppTheme.dangerColor.withOpacity(0.2),
                        borderStrokeWidth: 2,
                        borderColor: AppTheme.dangerColor.withOpacity(0.8),
                        isFilled: true,
                      ),
                    ],
                  ),

                  // User Reports
                  MarkerLayer(
                    markers: reportProvider.reports.map((report) {
                      return _buildMarker(report);
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          // 2. Top Floating Navigation Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  borderRadius: 30,
                  child: const Text(
                    'Live Flood Map',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                Consumer<ReportProvider>(
                  builder: (context, provider, child) {
                    return _buildFloatingButton(
                      icon: Icons.my_location,
                      isLoading: provider.isLoading,
                      onTap: () {
                        provider.fetchReports();
                        _mapController.move(
                          LatLng(AppConfig.defaultLatitude, AppConfig.defaultLongitude),
                          AppConfig.defaultZoom,
                        );
                      },
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2);
                  },
                ),
              ],
            ),
          ),

          // 3. Bottom Legend and Action Panel
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendCard().animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 56), // spacer to balance the FAB
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/report'),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Report Flood',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scaleXY(end: 1.02, duration: 1.5.seconds),
                     
                     const SizedBox(width: 56), // Spacer for centering
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap, bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: isLoading
            ? const SizedBox(
                width: 24, height: 24, 
                child: CircularProgressIndicator(strokeWidth: 2)
              )
            : Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Marker _buildMarker(FloodReport report) {
    final color = _getWaterLevelColor(report.waterLevel);
    return Marker(
      point: LatLng(report.latitude, report.longitude),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _showReportDetails(report),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Center(
            child: Icon(Icons.water_drop, color: Colors.white, size: 24),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 800.ms),
      ),
    );
  }

  Color _getWaterLevelColor(String waterLevel) {
    switch (waterLevel) {
      case 'ankle': return AppTheme.safeColor;
      case 'knee': return AppTheme.warningColor;
      case 'waist': return Colors.orange;
      case 'chest': return AppTheme.dangerColor;
      case 'above_head': return AppTheme.accentColor;
      default: return Colors.grey;
    }
  }

  Widget _buildLegendCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Risk Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _legendItem(AppTheme.safeColor, 'Low'),
              const SizedBox(width: 16),
              _legendItem(AppTheme.warningColor, 'Med'),
              const SizedBox(width: 16),
              _legendItem(AppTheme.dangerColor, 'High'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showReportDetails(FloodReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 30, // Round top corners
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.warning_rounded, color: _getWaterLevelColor(report.waterLevel), size: 32),
                const SizedBox(width: 12),
                Text(
                  '${report.waterLevel.toUpperCase()} LEVEL',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (report.description != null) ...[
              Text(
                report.description!,
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reported Just Now', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLight,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
