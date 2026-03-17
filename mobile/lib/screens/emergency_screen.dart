import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/emergency_provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/neon_button.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  Future<void> _sendEmergencyRequest() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to send an emergency request'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final provider = Provider.of<EmergencyProvider>(context, listen: false);
    double lat = 0, lng = 0;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm != LocationPermission.denied && perm != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }
    } catch (_) {}

    await provider.sendEmergencyRequest(
      latitude: lat,
      longitude: lng,
      description: 'Emergency assistance needed',
    );
    if (mounted) HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, provider, _) {
        final isRequesting = provider.isLoading;
        final requestSent = provider.requestSent;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Emergency Response'),
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.dangerColor),
                            const SizedBox(width: 12),
                            Expanded(child: Text(provider.error!, style: const TextStyle(color: AppTheme.dangerColor))),
                          ],
                        ),
                      ),
                    ),
                  if (!requestSent) ...[
                  GestureDetector(
                    onTap: isRequesting ? null : _sendEmergencyRequest,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.dangerColor.withOpacity(0.1),
                        border: Border.all(color: AppTheme.dangerColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.dangerColor.withOpacity(0.4),
                            blurRadius: 50,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Center(
                    child: isRequesting
                            ? const CircularProgressIndicator(color: AppTheme.dangerColor)
                          : const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sos_rounded, size: 64, color: AppTheme.dangerColor),
                                SizedBox(height: 8),
                                Text(
                                  'TAP TO REQUEST\nHELP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.dangerColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scaleXY(end: 1.05, duration: 1.seconds),
                ).animate().fadeIn(duration: 500.ms),
                
                const SizedBox(height: 48),
                
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What happens next?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.location_on, 'Your GPS location is shared instantly'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.notifications_active, 'Nearby responders are alerted'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.chat_bubble, 'A direct line is opened for communication'),
                    ],
                  ),
                ).animate().slideY(begin: 0.1).fadeIn(delay: 200.ms),
                  ] else ...[
                    // ── Success State ───────────────────────────────
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.safeColor.withValues(alpha: 0.12),
                        border: Border.all(color: AppTheme.safeColor, width: 2),
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 52, color: AppTheme.safeColor),
                    ).animate().scale(
                        duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 24),

                    const Text(
                      'Help is on the way',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.safeColor),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 12),

                    const Text(
                      'Stay calm. Your exact location has been shared with responders within 10 km.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.6),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 32),

                    // What to do checklist
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('While you wait',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 16),
                          _buildCheckItem(
                              'Stay at your current location if it is safe'),
                          _buildCheckItem(
                              'Keep your phone charged and nearby'),
                          _buildCheckItem(
                              'Move to higher ground only if water rises'),
                          _buildCheckItem(
                              'Signal your location with a flashlight or noise'),
                        ],
                      ),
                    ).animate().slideY(begin: 0.15).fadeIn(delay: 400.ms),

                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.priority_high_rounded,
                                color: AppTheme.dangerColor, size: 20),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Connecting to responders…',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                SizedBox(height: 3),
                                Text('Avg response time · 6–10 min',
                                    style: TextStyle(
                                        color: AppTheme.dangerColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.15).fadeIn(delay: 550.ms),

                    const SizedBox(height: 28),

                    NeonButton(
                      text: 'CANCEL REQUEST',
                      icon: Icons.cancel_outlined,
                      neonColor: Colors.grey.shade700,
                      onPressed: () => provider.resetRequest(),
                    ).animate().fadeIn(delay: 700.ms),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.safeColor.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.check, color: AppTheme.safeColor, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
        ),
      ],
    );
  }
}
