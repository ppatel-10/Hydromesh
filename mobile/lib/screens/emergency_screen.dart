import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/emergency_provider.dart';
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
                    // Success State
                    const Icon(Icons.check_circle_outline, size: 100, color: AppTheme.safeColor)
                        .animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    const Text(
                      'Help is on the way',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.safeColor),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                    const Text(
                      'Your request has been broadcasted to responders within 10km. Please stay at your current location if it is safe to do so.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.5),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 48),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const CircularProgressIndicator(color: AppTheme.primaryColor),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Waiting for responder assignment...', 
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                                SizedBox(height: 4),
                                Text('Priority: HIGH', 
                                    style: TextStyle(color: AppTheme.dangerColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.2).fadeIn(delay: 600.ms),
                    const SizedBox(height: 32),
                    NeonButton(
                      text: 'CANCEL REQUEST',
                      icon: Icons.cancel,
                      neonColor: Colors.grey.shade700,
                      onPressed: () => provider.resetRequest(),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
