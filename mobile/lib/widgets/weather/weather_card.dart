import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/weather_provider.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../common/glass_card.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather(
        AppConfig.defaultLatitude,
        AppConfig.defaultLongitude,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return GlassCard(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ).animate().shimmer();
        }

        if (weatherProvider.error != null || weatherProvider.currentWeather == null) {
          return const GlassCard(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: AppTheme.textSecondary),
                SizedBox(width: 12),
                Text('Weather data unavailable', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        final data = weatherProvider.currentWeather!['current_weather'];
        final temp = data['temperature']?.toString() ?? '--';
        final wind = data['windspeed']?.toString() ?? '--';
        final isRaining = data['weathercode'] != null && (data['weathercode'] > 50);

        return GlassCard(
          padding: const EdgeInsets.all(20),
          color: isRaining ? AppTheme.primaryColor.withOpacity(0.1) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Conditions', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$temp°C',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wind: $wind km/h', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          Text(isRaining ? 'Rain Expected' : 'Clear', 
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              color: isRaining ? AppTheme.primaryColor : AppTheme.safeColor,
                            )
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              Icon(
                isRaining ? Icons.storm : Icons.wb_sunny,
                size: 48,
                color: isRaining ? AppTheme.primaryColor : AppTheme.warningColor,
              ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(end: 0.1, duration: 2.seconds),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
      },
    );
  }
}
