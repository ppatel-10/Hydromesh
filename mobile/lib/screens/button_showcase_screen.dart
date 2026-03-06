import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'ghost_button.dart';
import 'icon_button.dart';
import 'fab_button.dart';
import 'toggle_button.dart';
import 'destructive_button.dart';
import 'social_button.dart';
import 'chip_button.dart';

class ButtonShowcaseScreen extends StatefulWidget {
  const ButtonShowcaseScreen({super.key});

  @override
  State<ButtonShowcaseScreen> createState() => _ButtonShowcaseScreenState();
}

class _ButtonShowcaseScreenState extends State<ButtonShowcaseScreen> {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _toggleValue = false;
  
  // Chip state
  final List<bool> _chipStates = [true, false, false];

  void _simulateLoading() async {
    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isSuccess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Premium Button System'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: '1. Primary CTA',
              child: PrimaryButton(
                text: 'CONTINUE',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {},
              ),
            ),
            
            _buildSection(
              title: '2. Secondary / Outlined',
              child: SecondaryButton(
                text: 'Save Draft',
                icon: Icons.save_outlined,
                onPressed: () {},
              ),
            ),
            
            _buildSection(
              title: '3. Ghost / Text',
              child: Row(
                children: [
                  GhostButton(
                    text: 'Cancel',
                    onPressed: () {},
                  ),
                  const Spacer(),
                  GhostButton(
                    text: 'Learn More',
                    icon: Icons.info_outline,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            _buildSection(
              title: '4. Icon Buttons',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButtonCircular(
                    icon: Icons.settings,
                    onPressed: () {},
                    tooltip: 'Settings',
                  ),
                  IconButtonCircular(
                    icon: Icons.favorite_border,
                    onPressed: () {},
                  ),
                  IconButtonCircular(
                    icon: Icons.share,
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            _buildSection(
              title: '5. Floating Action (FAB)',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FabButton(
                    icon: Icons.add,
                    onPressed: () {},
                  ),
                  FabButton(
                    icon: Icons.edit,
                    text: 'Create',
                    isExpanded: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            _buildSection(
              title: '6. Custom Toggle',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ToggleButton(
                    value: _toggleValue,
                    onChanged: (val) => setState(() => _toggleValue = val),
                  ),
                ],
              ),
            ),

            _buildSection(
              title: '7. Loading & Morphing',
              child: PrimaryButton(
                text: 'SAVE CHANGES',
                isLoading: _isLoading,
                isSuccess: _isSuccess,
                onPressed: _simulateLoading,
              ),
            ),

            _buildSection(
              title: '8. Destructive (Hold to Confirm)',
              child: DestructiveButton(
                text: 'DELETE ACCOUNT',
                onConfirmed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account Deleted!')),
                  );
                },
              ),
            ),

            _buildSection(
              title: '9. Social Login',
              child: SocialButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                onPressed: () {},
              ),
            ),

            _buildSection(
              title: '10. Filter Chips',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChipButton(
                      label: 'All Activity',
                      isSelected: _chipStates[0],
                      onSelected: (val) => setState(() => _chipStates[0] = val),
                    ),
                    const SizedBox(width: 8),
                    ChipButton(
                      label: 'Emergency',
                      isSelected: _chipStates[1],
                      onSelected: (val) => setState(() => _chipStates[1] = val),
                    ),
                    const SizedBox(width: 8),
                    ChipButton(
                      label: 'Reports',
                      isSelected: _chipStates[2],
                      onSelected: (val) => setState(() => _chipStates[2] = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    // Generate staggered fade-in animations for the showcase
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }
}
