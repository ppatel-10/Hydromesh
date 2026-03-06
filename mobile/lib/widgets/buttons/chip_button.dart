import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'button_styles.dart';

class ChipButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const ChipButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<ChipButton> createState() => _ChipButtonState();
}

class _ChipButtonState extends State<ChipButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.selectionClick();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onSelected(!widget.isSelected);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : (widget.isSelected ? 1.05 : 1.0), // Bump on select
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.primaryColor : ButtonStyles.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
            ),
            boxShadow: widget.isSelected
                ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 12)]
                : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: widget.isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
