import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Dark Background
        Container(color: AppTheme.background),
        
        // Animated Mesh Gradients (Aurora Effect)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.15),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .move(duration: 10.seconds, begin: const Offset(0, 0), end: const Offset(150, 100), curve: Curves.easeInOutSine)
          .scaleXY(begin: 1.0, end: 1.5, duration: 8.seconds, curve: Curves.easeInOut),
        ),
        
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor.withOpacity(0.1),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .move(duration: 12.seconds, begin: const Offset(0, 0), end: const Offset(-100, -150), curve: Curves.easeInOutSine)
          .scaleXY(begin: 1.0, end: 1.2, duration: 10.seconds, curve: Curves.easeInOut),
        ),

        // Noise/Grain Texture Overlay (Simulated with blend mode or subtle opacity pattern if we had an asset, 
        // but we'll use a very heavy blur to blend the orbs into an aurora)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Foreground Content
        SafeArea(child: child),
      ],
    );
  }
}
