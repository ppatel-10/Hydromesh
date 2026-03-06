import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'button_styles.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  bool _isOpen = false;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 250,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Sub-actions
          if (_isOpen) ...[
            _buildSubAction(
              icon: Icons.report,
              label: 'Report',
              color: AppTheme.warningColor,
              bottomOffset: 80,
              delay: 0,
              onTap: () {
                _toggle();
                Navigator.pushNamed(context, '/report');
              },
            ),
            _buildSubAction(
              icon: Icons.route,
              label: 'Route',
              color: AppTheme.safeColor,
              bottomOffset: 140,
              delay: 50,
              onTap: () {
                _toggle();
                Navigator.pushNamed(context, '/route');
              },
            ),
            _buildSubAction(
              icon: Icons.sos,
              label: 'SOS',
              color: AppTheme.dangerColor,
              bottomOffset: 200,
              delay: 100,
              onTap: () {
                _toggle();
                Navigator.pushNamed(context, '/emergency');
              },
            ),
          ],

          // Main FAB
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOpen ? ButtonStyles.darkSurface : AppTheme.dangerColor,
                  border: Border.all(
                    color: _isOpen ? Colors.white.withOpacity(0.1) : AppTheme.dangerColor,
                    width: 1.5,
                  ),
                  boxShadow: _isOpen ? null : ButtonStyles.getGlow(AppTheme.dangerColor),
                ),
                child: AnimatedRotation(
                  turns: _isOpen ? 0.125 : 0.0, // Rotate 45 degrees to make an X
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    Icons.add,
                    color: _isOpen ? Colors.white : Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubAction({
    required IconData icon,
    required String label,
    required Color color,
    required double bottomOffset,
    required int delay,
    required VoidCallback onTap,
  }) {
    return Positioned(
      bottom: bottomOffset,
      right: 8,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ButtonStyles.darkSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: 1.5),
                boxShadow: ButtonStyles.getGlow(color),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.5, end: 0, duration: 200.ms, curve: Curves.easeOutBack).fadeIn(duration: 200.ms),
    );
  }
}
