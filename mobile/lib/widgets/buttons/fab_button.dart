import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'button_styles.dart';
import 'button_animation_config.dart';

class FabButton extends StatefulWidget {
  final IconData icon;
  final String? text;
  final VoidCallback? onPressed;
  final bool isExpanded;

  const FabButton({
    super.key,
    required this.icon,
    this.text,
    this.onPressed,
    this.isExpanded = false,
  });

  @override
  State<FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<FabButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

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
    final isExpanded = widget.isExpanded && widget.text != null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: _isPressed ? ButtonAnimationConfig.pressDown : ButtonAnimationConfig.springBack,
        curve: _isPressed ? ButtonAnimationConfig.pressCurve : ButtonAnimationConfig.springCurve,
        child: AnimatedContainer(
          duration: ButtonAnimationConfig.stateMorph,
          curve: ButtonAnimationConfig.morphCurve,
          height: 64,
          width: isExpanded ? 160 : 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.accentColor, // Rive-style dual gradient
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: _isPressed || isDisabled
                ? null
                : ButtonStyles.getGlow(AppTheme.primaryColor),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shimmer overlay layer
              if (!isDisabled)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: const Alignment(-2.0, -2.0),
                        end: const Alignment(2.0, 2.0),
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                   .shimmer(duration: ButtonAnimationConfig.shimmerSweep, delay: 3.seconds),
                ),
              // Content
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSlide(
                    offset: Offset(_isPressed ? 0 : 0, _isPressed ? -0.1 : 0),
                    duration: ButtonAnimationConfig.pressDown,
                    child: Icon(widget.icon, color: Colors.white, size: 28),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.text!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ).animate().slideX(begin: 0.5).fadeIn(duration: 300.ms),
                  ]
                ],
              ),
            ],
          ),
        ).animate() // Entry animation
         .slideY(begin: 1.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack)
         .fadeIn(),
      ),
    );
  }
}
