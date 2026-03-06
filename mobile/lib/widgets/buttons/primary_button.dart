import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'button_styles.dart';
import 'button_animation_config.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSuccess;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading || widget.isSuccess) return;
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
    final isMorphing = widget.isLoading || widget.isSuccess;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: _isPressed ? ButtonAnimationConfig.pressDown : ButtonAnimationConfig.springBack,
        curve: _isPressed ? ButtonAnimationConfig.pressCurve : ButtonAnimationConfig.springCurve,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.4 : 1.0,
          duration: ButtonAnimationConfig.colorTransition,
          child: AnimatedContainer(
            duration: ButtonAnimationConfig.stateMorph,
            curve: ButtonAnimationConfig.morphCurve,
            height: 56,
            width: isMorphing ? 56 : MediaQuery.of(context).size.width, // Morphs to circle
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMorphing ? 28 : ButtonStyles.radius),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(_isPressed ? 0.8 : 1.0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: _isPressed || isDisabled || isMorphing
                  ? null
                  : ButtonStyles.getGlow(AppTheme.primaryColor),
            ),
            child: Center(
              child: _buildChild(),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .boxShadow(
             begin: BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 0),
             end: BoxShadow(color: AppTheme.primaryColor.withOpacity(0.8), blurRadius: 25, spreadRadius: 2),
             duration: ButtonAnimationConfig.glowPulse,
             curve: Curves.easeInOut,
           ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (widget.isSuccess) {
      return const Icon(Icons.check, color: Colors.white, size: 28)
          .animate().scale(curve: Curves.elasticOut, duration: 600.ms);
    }
    if (widget.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ).animate().fadeIn();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ).animate().fadeIn(duration: 200.ms);
  }
}
