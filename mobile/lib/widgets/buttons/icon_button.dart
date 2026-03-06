import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'button_styles.dart';
import 'button_animation_config.dart';

class IconButtonCircular extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const IconButtonCircular({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  State<IconButtonCircular> createState() => _IconButtonCircularState();
}

class _IconButtonCircularState extends State<IconButtonCircular> {
  bool _isPressed = false;
  bool _isHovered = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final isActive = _isPressed || _isHovered;

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: _isPressed ? ButtonAnimationConfig.pressDown : ButtonAnimationConfig.springBack,
          curve: _isPressed ? ButtonAnimationConfig.pressCurve : ButtonAnimationConfig.springCurve,
          child: AnimatedOpacity(
            opacity: isDisabled ? 0.4 : 1.0,
            duration: ButtonAnimationConfig.colorTransition,
            child: AnimatedContainer(
              duration: ButtonAnimationConfig.colorTransition,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppTheme.primaryColor : ButtonStyles.darkSurface,
                border: Border.all(
                  color: isActive ? AppTheme.primaryColor : Colors.white.withOpacity(0.08),
                  width: 1.0,
                ),
                boxShadow: isActive && !isDisabled
                    ? ButtonStyles.getGlow(AppTheme.primaryColor)
                    : null,
              ),
              child: AnimatedRotation(
                turns: _isPressed ? 0.05 : 0.0, // 15 degrees
                duration: ButtonAnimationConfig.springBack,
                curve: ButtonAnimationConfig.springCurve,
                child: Icon(
                  widget.icon,
                  color: isActive ? Colors.white : AppTheme.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        verticalOffset: 32,
        child: button,
      );
    }

    return button;
  }
}
