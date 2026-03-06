import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'button_styles.dart';
import 'button_animation_config.dart';

class DestructiveButton extends StatefulWidget {
  final String text;
  final VoidCallback? onConfirmed;

  const DestructiveButton({
    super.key,
    required this.text,
    this.onConfirmed,
  });

  @override
  State<DestructiveButton> createState() => _DestructiveButtonState();
}

class _DestructiveButtonState extends State<DestructiveButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  double _progress = 0.0;
  bool _shaking = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onConfirmed == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isPressed = true;
      _progress = 1.0;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onConfirmed == null) return;
    
    // Attempted to tap instead of hold
    if (_progress > 0.0 && _progress < 1.0) {
      HapticFeedback.heavyImpact();
      setState(() => _shaking = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _shaking = false);
      });
    }

    setState(() {
      _isPressed = false;
      _progress = 0.0;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onConfirmed == null;

    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: ButtonAnimationConfig.pressDown,
        curve: ButtonAnimationConfig.pressCurve,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ButtonStyles.radius),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.dangerColor.withOpacity(isDisabled ? 0.2 : 0.8),
            ),
            child: Stack(
              children: [
                // Hold Progress Bar
                AnimatedContainer(
                  duration: _isPressed ? const Duration(seconds: 2) : const Duration(milliseconds: 200),
                  curve: Curves.linear,
                  width: _isPressed ? MediaQuery.of(context).size.width : 0,
                  height: 56,
                  color: AppTheme.dangerColor,
                  onEnd: () {
                    if (_isPressed && _progress == 1.0) {
                      HapticFeedback.mediumImpact();
                      widget.onConfirmed?.call();
                      setState(() {
                        _isPressed = false;
                        _progress = 0.0;
                      });
                    }
                  },
                ),
                // Text overlay
                Center(
                  child: Text(
                    _isPressed ? 'HOLD TO CONFIRM' : widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ).animate(target: _isPressed ? 1 : 0).fade(duration: 100.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (_shaking) {
      return button.animate().shakeX(amount: 5, duration: 400.ms);
    }
    return button;
  }
}
