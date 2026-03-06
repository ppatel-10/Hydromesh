import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'button_styles.dart';
import 'button_animation_config.dart';

class SocialButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.text,
    required this.icon,
    this.iconColor = Colors.white,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
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

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: ButtonAnimationConfig.pressDown,
        curve: ButtonAnimationConfig.pressCurve,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.4 : 1.0,
          duration: ButtonAnimationConfig.colorTransition,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: ButtonStyles.darkSurface,
              borderRadius: BorderRadius.circular(ButtonStyles.radius),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Stack(
              children: [
                // Shimmer
                if (!isDisabled)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ButtonStyles.radius),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.0),
                          ],
                          begin: const Alignment(-2.0, -0.5),
                          end: const Alignment(2.0, 0.5),
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: ButtonAnimationConfig.shimmerSweep, delay: 4.seconds),
                  ),
                
                // Content
                Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedRotation(
                              turns: _isPressed ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutBack,
                              child: Icon(widget.icon, color: widget.iconColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
