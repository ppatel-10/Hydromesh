import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/simulation_provider.dart';
import '../widgets/common/glass_card.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  static const List<Map<String, dynamic>> _cities = [
    {'name': 'London', 'id': 'london'},
    {'name': 'Mumbai', 'id': 'mumbai'},
    {'name': 'Miami', 'id': 'miami'},
    {'name': 'Tokyo', 'id': 'tokyo'},
  ];

  static const List<Map<String, dynamic>> _simulations = [
    {'type': 1, 'name': 'Flash Flood', 'desc': 'Sudden spike of severe reports', 'icon': Icons.flash_on},
    {'type': 2, 'name': 'Rising Tide', 'desc': 'Gradual escalation of water levels', 'icon': Icons.waves},
    {'type': 3, 'name': 'Mass Evacuation', 'desc': 'Radius escape vector stress-test', 'icon': Icons.run_circle_outlined},
    {'type': 4, 'name': 'Responder Coordination', 'desc': 'Simulate multiple SOS beacons', 'icon': Icons.health_and_safety},
    {'type': 5, 'name': 'Global Anomaly', 'desc': 'Spawns events across multiple cities', 'icon': Icons.public},
  ];

  Future<void> _runSimulation(BuildContext context, int type, String name) async {
    final sim = context.read<SimulationProvider>();
    final ok = await sim.startSimulation(type, name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '$name simulation active! Open Map or press SOS to evacuate.'
            : 'Failed to start simulation. Check connection.'),
        backgroundColor: ok ? AppTheme.safeColor : AppTheme.dangerColor,
      ),
    );
  }

  Future<void> _stopSimulation(BuildContext context) async {
    await context.read<SimulationProvider>().stopSimulation();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulation stopped & data cleared'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final isActive = sim.isActive;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('God Mode'),
            if (isActive) ...[
              const SizedBox(width: 10),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.dangerColor,
                  boxShadow: [BoxShadow(color: AppTheme.dangerColor.withOpacity(0.7), blurRadius: 6)],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.5, duration: 600.ms),
            ],
          ],
        ),
      ),
      body: sim.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isActive) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppTheme.dangerColor, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active: ${sim.activeSimName}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    ),
                                    Text(
                                      'Region: ${sim.activeCity[0].toUpperCase()}${sim.activeCity.substring(1)}',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Press SOS on the home screen to get your evacuation route.',
                            style: TextStyle(color: AppTheme.safeColor, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Semantics(
                            label: 'Stop active simulation',
                            button: true,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.dangerColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: sim.isStopping ? null : () => _stopSimulation(context),
                                icon: sim.isStopping
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.stop_circle_outlined),
                                label: Text(sim.isStopping ? 'Stopping...' : 'Stop & Reset Simulation'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1),
                    const SizedBox(height: 24),
                  ],

                  const Text('Select Target Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _cities.map((city) {
                      final isSelected = sim.activeCity == city['id'];
                      return Semantics(
                        label: 'Select ${city['name']} as target region',
                        selected: isSelected,
                        child: ChoiceChip(
                          label: Text(city['name'] as String),
                          selected: isSelected,
                          onSelected: (_) => context.read<SimulationProvider>().setActiveCity(city['id'] as String),
                          selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                          backgroundColor: AppTheme.surfaceLight,
                          side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 32),
                  const Text('Trigger Simulation Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  ..._simulations.map((sim_item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Semantics(
                          label: 'Run ${sim_item['name']} simulation: ${sim_item['desc']}',
                          button: true,
                          child: GestureDetector(
                            onTap: () => _runSimulation(context, sim_item['type'] as int, sim_item['name'] as String),
                            child: GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Icon(sim_item['icon'] as IconData, color: AppTheme.dangerColor, size: 32),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(sim_item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(sim_item['desc'] as String, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.play_arrow, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: (100 * (sim_item['type'] as int)).ms).slideX(begin: 0.1),
                      )),
                ],
              ),
            ),
    );
  }
}
