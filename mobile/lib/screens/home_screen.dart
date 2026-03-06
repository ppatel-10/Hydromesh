import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?.name ?? 'Citizen';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AuroraBackground(
        child: Stack(
          children: [
            // Main Scrollable Content
            Positioned.fill(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context, userName),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WeatherCard(),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Critical Tools'),
                          const SizedBox(height: 16),
                          _buildHorizontalScroll(context),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Recent Activity'),
                          const SizedBox(height: 16),
                          _buildActivityList(),
                          const SizedBox(height: 120), // Padding for Bottom Nav Bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Expandable FAB
            const Positioned(
              bottom: 120, // Right above the nav bar
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    // Generate context greeting based on time
    final hour = DateTime.now().hour;
    String greeting = 'Good evening';
    if (hour < 12) greeting = 'Good morning';
    else if (hour < 17) greeting = 'Good afternoon';

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 90,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ProgressRing(
                  progress: 0.85, 
                  size: 40, 
                  strokeWidth: 4,
                  centerChild: Text('85', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/simulation'),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.surfaceLight,
                    child: Icon(Icons.terminal, size: 16, color: AppTheme.dangerColor),
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
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
          _buildToolCard(
            context,
            title: 'Live Flood Map',
            icon: Icons.map_outlined,
            color: AppTheme.primaryColor,
            route: '/map',
            delay: 100,
          ),
          const SizedBox(width: 16),
          _buildToolCard(
            context,
            title: 'Report Incident',
            icon: Icons.add_a_photo_outlined,
            color: AppTheme.warningColor,
            route: '/report',
            delay: 200,
          ),
          const SizedBox(width: 16),
          _buildToolCard(
            context,
            title: 'Safe Routes',
            icon: Icons.route_outlined,
            color: AppTheme.safeColor,
            route: '/route',
            delay: 300,
          ),
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
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
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
            onDismissed: (direction) {
              // Handle dismissal (e.g. archive notification)
            },
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle_outline, color: AppTheme.safeColor),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Verified',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Downtown river overflow alert',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '2h ago',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (400 + (index * 100)).ms).slideX(begin: 0.05),
        );
      }),
    );
  }
}
