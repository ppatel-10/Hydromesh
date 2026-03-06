import 'package:flutter/material.dart';

class ButtonAnimationConfig {
  // Durations
  static const Duration pressDown = Duration(milliseconds: 80);
  static const Duration springBack = Duration(milliseconds: 300);
  static const Duration colorTransition = Duration(milliseconds: 60);
  static const Duration stateMorph = Duration(milliseconds: 400);
  static const Duration glowPulse = Duration(milliseconds: 2000);
  static const Duration shimmerSweep = Duration(milliseconds: 1500);

  // Curves
  static const Curve pressCurve = Curves.easeIn;
  
  // Custom elastic out curve to simulate spring stiffness: 180, damping: 12
  static const Curve springCurve = ElasticOutCurve(0.8); 
  
  static const Curve morphCurve = Curves.fastOutSlowIn;
}
