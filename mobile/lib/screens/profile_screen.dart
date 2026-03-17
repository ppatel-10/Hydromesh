import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    if (!mounted) return;
    setState(() => _notificationsEnabled = val);
  }

  void _showThemePicker(BuildContext context) {
    final tp = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ThemePickerSheet(current: tp.mode),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const SingleChildScrollView(
          child: Text(
            'HydroMesh collects location data, flood reports, and emergency requests to provide real-time '
            'flood prediction and community emergency response services.\n\n'
            '• Location data is only collected when you submit a report or send an SOS request.\n'
            '• Your reports are shared anonymously with the community.\n'
            '• We never sell your data to third parties.\n'
            '• All data is stored securely on Supabase (EU servers).\n'
            '• You can request data deletion by contacting support.\n\n'
            'Open-source under MIT License. View source at github.com/theSaksham02/Hydromesh.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.6, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeMode = context.watch<ThemeProvider>().mode;
    final user = auth.user;
    final name = user?.name ?? 'Hydromesh User';
    final email = user?.email ?? 'Not available';
    final role = user?.role ?? 'citizen';

    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : null;

    final roleColor = role == 'responder'
        ? AppTheme.warningColor
        : role == 'admin'
            ? AppTheme.dangerColor
            : AppTheme.safeColor;

    final themeLabel = _themeModeLabel(themeMode);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Semantics(
            label: 'Logout',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.textSecondary),
              tooltip: 'Logout',
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Avatar + Name ─────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.8),
                          AppTheme.accentColor.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: initials != null
                          ? Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_rounded,
                              color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(email,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: roleColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: roleColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),

            const SizedBox(height: 20),

            // ── Settings ──────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _SettingRow(
                    icon: Icons.notifications_rounded,
                    iconColor: AppTheme.primaryColor,
                    label: 'Push Notifications',
                    subtitle: 'Receive flood & emergency alerts',
                    trailing: Semantics(
                      label: 'Toggle push notifications',
                      child: Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const Divider(color: AppTheme.surfaceLight, height: 24),
                  _SettingRow(
                    icon: Icons.palette_outlined,
                    iconColor: AppTheme.accentColor,
                    label: 'Appearance',
                    subtitle: themeLabel,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ThemeDot(mode: themeMode),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppTheme.textSecondary),
                      ],
                    ),
                    onTap: () => _showThemePicker(context),
                  ),
                  const Divider(color: AppTheme.surfaceLight, height: 24),
                  _SettingRow(
                    icon: Icons.map_outlined,
                    iconColor: AppTheme.safeColor,
                    label: 'View Live Map',
                    subtitle: 'Open flood & report map',
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () => Navigator.pushNamed(context, '/map'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.08),

            const SizedBox(height: 16),

            // ── About ────────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  const _SettingRow(
                    icon: Icons.info_outline,
                    iconColor: AppTheme.textSecondary,
                    label: 'Version',
                    subtitle: 'Hydromesh v1.0.0  ·  Open Source (MIT)',
                  ),
                  const Divider(color: AppTheme.surfaceLight, height: 24),
                  _SettingRow(
                    icon: Icons.shield_outlined,
                    iconColor: AppTheme.textSecondary,
                    label: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.08),

            const SizedBox(height: 24),

            // ── Sign Out ─────────────────────────────────────────────
            Semantics(
              label: 'Sign out of Hydromesh',
              button: true,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerColor.withValues(alpha: 0.12),
                    foregroundColor: AppTheme.dangerColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                        color: AppTheme.dangerColor.withValues(alpha: 0.35)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
            ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return 'Dark (current)';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.highContrast:
        return 'High Contrast';
      case AppThemeMode.colorblind:
        return 'Colorblind-Friendly';
    }
  }
}

// ── Theme Dot ─────────────────────────────────────────────────────────────────
class _ThemeDot extends StatelessWidget {
  final AppThemeMode mode;
  const _ThemeDot({required this.mode});

  @override
  Widget build(BuildContext context) {
    final color = switch (mode) {
      AppThemeMode.dark => AppTheme.primaryColor,
      AppThemeMode.light => const Color(0xFF1A6EFF),
      AppThemeMode.highContrast => const Color(0xFFFFD600),
      AppThemeMode.colorblind => const Color(0xFF3B82F6),
    };
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );
  }
}

// ── Theme Picker Sheet ────────────────────────────────────────────────────────
class _ThemePickerSheet extends StatefulWidget {
  final AppThemeMode current;
  const _ThemePickerSheet({required this.current});

  @override
  State<_ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends State<_ThemePickerSheet> {
  late AppThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  static const _options = [
    (mode: AppThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_rounded, color: Color(0xFF4F8EF7)),
    (mode: AppThemeMode.light, label: 'Light', icon: Icons.light_mode_rounded, color: Color(0xFF1A6EFF)),
    (mode: AppThemeMode.highContrast, label: 'High Contrast', icon: Icons.contrast_rounded, color: Color(0xFFFFD600)),
    (mode: AppThemeMode.colorblind, label: 'Colorblind-Friendly', icon: Icons.remove_red_eye_outlined, color: Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Appearance',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            final isSelected = _selected == opt.mode;
            return InkWell(
              onTap: () async {
                setState(() => _selected = opt.mode);
                await context.read<ThemeProvider>().setTheme(opt.mode);
                if (context.mounted) Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected
                      ? opt.color.withValues(alpha: 0.12)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? opt.color.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: opt.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(opt.icon, color: opt.color, size: 18),
                    ),
                    const SizedBox(width: 16),
                    Text(opt.label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? opt.color : null,
                        )),
                    const Spacer(),
                    if (isSelected)
                      Icon(Icons.check_rounded, color: opt.color, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Setting Row ───────────────────────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
