import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/accessibility_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/report_screen.dart';
import '../screens/route_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/simulation_screen.dart';
import '../screens/button_showcase_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fade(const SplashScreen());
      case '/accessibility':
        return _slideUp(const AccessibilityScreen());
      case '/login':
        return _fade(const LoginScreen());
      case '/home':
        return _fade(const HomeScreen());
      case '/map':
        return _fade(const MapScreen());
      case '/report':
        return _slideUp(const ReportScreen());
      case '/route':
        return _slideUp(const RouteScreen());
      case '/emergency':
        return _slideUp(const EmergencyScreen());
      case '/simulation':
        return _slideUp(const SimulationScreen());
      case '/buttons':
        return _fade(const ButtonShowcaseScreen());
      case '/alerts':
        return _fade(const AlertsScreen());
      case '/profile':
        return _slideUp(const ProfileScreen());
      default:
        return _fade(Scaffold(
          body: Center(child: Text('Route not found: ${settings.name}')),
        ));
    }
  }

  /// Fade transition — peer-level navigation (home ↔ map/alerts/profile)
  static Route<T> _fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: page.runtimeType.toString()),
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      ),
    );
  }

  /// Slide-up transition — detail / action screens
  static Route<T> _slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: page.runtimeType.toString()),
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }
}