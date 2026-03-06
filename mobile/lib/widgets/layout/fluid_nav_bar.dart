import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';

class FluidNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FluidNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => _handleTap(0),
              ),
              _NavBarItem(
                icon: Icons.map_rounded,
                label: 'Map',
                isSelected: currentIndex == 1,
                onTap: () => _handleTap(1),
              ),
              _NavBarItem(
                icon: Icons.notifications_rounded,
                label: 'Alerts',
                isSelected: currentIndex == 2,
                onTap: () => _handleTap(2),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 3,
                onTap: () => _handleTap(3),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutExpo);
  }

  void _handleTap(int index) {
    if (currentIndex != index) {
      HapticFeedback.lightImpact();
      onTap(index);
    }
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: const ElasticOutCurve(0.8),
              padding: EdgeInsets.all(isSelected ? 10 : 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                size: isSelected ? 26 : 24,
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isSelected ? 4 : 0,
                margin: const EdgeInsets.top(4),
                width: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
