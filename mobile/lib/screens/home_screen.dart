import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../models/flood_report.dart';
import '../config/theme.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/weather/weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?.name ?? 'Citizen';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.dangerColor,
        child: const Icon(Icons.emergency, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/emergency'),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scaleXY(end: 1.05, duration: 1.seconds),
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: TextStyle(
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
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (provider.reports.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.textSecondary),
                SizedBox(width: 12),
                Text('No flood reports yet.', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }
        return Column(
          children: provider.reports.take(5).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final report = entry.value;
            final color = _waterLevelColor(report.waterLevel);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.water_drop, color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${report.waterLevel.toUpperCase()} Water Level',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.description?.isNotEmpty == true
                                ? report.description!
                                : 'Flood report submitted',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTime(report.createdAt),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (400 + (i * 100)).ms).slideX(begin: 0.05),
            );
          }).toList(),
        );
      },
    );
  }

  Color _waterLevelColor(String level) {
    switch (level) {
      case 'ankle': return AppTheme.safeColor;
      case 'knee': return AppTheme.warningColor;
      case 'waist': return Colors.orange;
      case 'chest': return AppTheme.dangerColor;
      case 'above_head': return AppTheme.accentColor;
      default: return Colors.grey;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Just now';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
