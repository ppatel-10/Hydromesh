import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import 'button_styles.dart';

class ToggleButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isDragging = false;

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onPanStart: (_) => setState(() => _isDragging = true),
      onPanEnd: (_) => setState(() => _isDragging = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: widget.value ? AppTheme.primaryColor : ButtonStyles.darkSurface,
          border: Border.all(
            color: widget.value ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
          ),
          boxShadow: widget.value
              ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8)]
              : null,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: const ElasticOutCurve(0.8),
              left: widget.value ? 20.0 : 0.0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _isDragging ? 32.0 : 24.0, // Squish/Stretch on drag
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(widget.value ? -2 : 2, 0), // Inner shadow shifts
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
