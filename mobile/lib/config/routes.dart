import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/report_screen.dart';
import '../screens/route_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/simulation_screen.dart';
import '../screens/button_showcase_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/map':
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case '/report':
        return MaterialPageRoute(builder: (_) => const ReportScreen());
      case '/route':
        return MaterialPageRoute(builder: (_) => const RouteScreen());
      case '/emergency':
        return MaterialPageRoute(builder: (_) => const EmergencyScreen());
      case '/simulation':
        return MaterialPageRoute(builder: (_) => const SimulationScreen());
      case '/buttons':
        return MaterialPageRoute(builder: (_) => const ButtonShowcaseScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}