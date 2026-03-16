import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/simulation_provider.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/layout/aurora_background.dart';
import '../widgets/layout/fluid_nav_bar.dart';
import '../widgets/buttons/expandable_fab.dart';
import '../widgets/weather/weather_card.dart';
import '../widgets/common/progress_ring.dart';
import '../widgets/common/shimmer_skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isSosLoading = false;

  static const Map<String, List<double>> _cityDefaults = {
    'london': [51.5074, -0.1278],
    'mumbai': [19.0760, 72.8777],
    'miami': [25.7617, -80.1918],
    'tokyo': [35.6762, 139.6503],
  };

  Future<void> _handleSos(BuildContext context) async {
    final sim = context.read<SimulationProvider>();

    if (!sim.isActive) {
      Navigator.pushNamed(context, '/emergency');
      return;
    }

    setState(() => _isSosLoading = true);

    try {
      double? userLat, userLng;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission perm = await Geolocator.checkPermission();
          if (perm == LocationPermission.denied) {
            perm = await Geolocator.requestPermission();
          }
          if (perm != LocationPermission.denied && perm != LocationPermission.deniedForever) {
            final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
            ).timeout(const Duration(seconds: 8));
            userLat = pos.latitude;
            userLng = pos.longitude;
          }
        }
      } catch (_) {}

      final defaults = _cityDefaults[sim.activeCity] ?? _cityDefaults['london']!;
      userLat ??= defaults[0];
      userLng ??= defaults[1];

      final nearest = sim.nearestSafePoint(userLat, userLng);

      unawaited(
        context.read<EmergencyProvider>().sendEmergencyRequest(
          latitude: userLat,
          longitude: userLng,
          description: 'SOS during ${sim.activeSimName} simulation — routing to ${nearest.name}',
        ),
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/route',
        arguments: {
          'destLat': nearest.latitude,
          'destLng': nearest.longitude,
          'destName': nearest.name,
          'destDesc': nearest.description,
        },
      );
    } finally {
      if (mounted) setState(() => _isSosLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?.name ?? 'Citizen';
    final sim = context.watch<SimulationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AuroraBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context, userName, sim),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sim.isActive)
                            _buildSimulationBanner(sim),
                          const WeatherCard(),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Critical Tools'),
                          const SizedBox(height: 16),
                          _buildHorizontalScroll(context),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Recent Activity'),
                          const SizedBox(height: 16),
                          _buildActivityList(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SOS Persistent Button (left side)
            Positioned(
              bottom: 120,
              left: 24,
              child: _buildSosButton(context, sim),
            ),

            // Expandable FAB (right side)
            const Positioned(
              bottom: 120,
              right: 24,
              child: ExpandableFab(),
            ),

            // Fluid Bottom Navigation Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FluidNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  if (index == 1) Navigator.pushNamed(context, '/map');
                  if (index == 2) Navigator.pushNamed(context, '/alerts');
                  if (index == 3) Navigator.pushNamed(context, '/profile');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton(BuildContext context, SimulationProvider sim) {
    final isSimActive = sim.isActive;

    Widget button = Semantics(
      label: isSimActive
          ? 'Emergency SOS — routes to nearest safe point for active ${sim.activeSimName} simulation'
          : 'Emergency SOS — send distress signal',
      button: true,
      child: GestureDetector(
        onTap: _isSosLoading ? null : () => _handleSos(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.dangerColor,
            boxShadow: [
              BoxShadow(
                color: AppTheme.dangerColor.withOpacity(isSimActive ? 0.75 : 0.4),
                blurRadius: isSimActive ? 22 : 10,
                spreadRadius: isSimActive ? 4 : 1,
              ),
            ],
          ),
          child: _isSosLoading
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSimActive ? Icons.directions_run : Icons.sos,
                      color: Colors.white,
                      size: isSimActive ? 20 : 24,
                    ),
                    Text(
                      'SOS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (isSimActive) {
      return button
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.10, duration: 700.ms, curve: Curves.easeInOut);
    }
    return button;
  }

  Widget _buildSimulationBanner(SimulationProvider sim) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.dangerColor,
                boxShadow: [BoxShadow(color: AppTheme.dangerColor.withOpacity(0.8), blurRadius: 6)],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.5, duration: 600.ms),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMULATION ACTIVE: ${sim.activeSimName?.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.dangerColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${sim.activeCity[0].toUpperCase()}${sim.activeCity.substring(1)} · Press SOS ← to evacuate',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/simulation'),
              child: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
    );
  }

  Widget _buildAppBar(BuildContext context, String name, SimulationProvider sim) {
    final hour = DateTime.now().hour;
    String greeting = 'Good evening';
    if (hour < 12) greeting = 'Good morning';
    else if (hour < 17) greeting = 'Good afternoon';

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ProgressRing(
                    progress: 0.85,
                    size: 32,
                    strokeWidth: 3,
                    centerChild: Text('85', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ClipRect(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting,',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/simulation'),
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.surfaceLight,
                        child: Icon(Icons.terminal, size: 16, color: AppTheme.dangerColor),
                      ),
                      if (sim.isActive)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.dangerColor,
                              border: Border.all(color: AppTheme.background, width: 1.5),
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(end: 1.3, duration: 600.ms),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.surfaceLight,
                    child: Icon(Icons.logout, size: 16, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05);
  }

  Widget _buildHorizontalScroll(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _buildToolCard(context, title: 'Live Flood Map', icon: Icons.map_outlined, color: AppTheme.primaryColor, route: '/map', delay: 100),
          const SizedBox(width: 16),
          _buildToolCard(context, title: 'Report Incident', icon: Icons.add_a_photo_outlined, color: AppTheme.warningColor, route: '/report', delay: 200),
          const SizedBox(width: 16),
          _buildToolCard(context, title: 'Safe Routes', icon: Icons.route_outlined, color: AppTheme.safeColor, route: '/route', delay: 300),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, height: 1.2)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildActivityList() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Dismissible(
            key: Key('activity_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) {},
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.check_circle_outline, color: AppTheme.safeColor),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Report Verified', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Downtown river overflow alert', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Text('2h ago', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (400 + (index * 100)).ms).slideX(begin: 0.05),
        );
      }),
    );
  }
}
