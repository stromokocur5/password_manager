import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

/// Settings page.
class SettingsPage extends StatelessWidget {
  final VoidCallback onBack;

  const SettingsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security section
          _SectionHeader(title: 'Security', delay: 0),
          _SettingsTile(
            icon: Icons.fingerprint,
            iconColor: AppColors.categoryLogin,
            title: 'Biometric Unlock',
            subtitle: 'Use fingerprint or face to unlock',
            trailing: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Switch(
                  value: false,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    if (value) {
                      context.read<AuthBloc>().add(const AuthEnableBiometric());
                    } else {
                      context.read<AuthBloc>().add(
                        const AuthDisableBiometric(),
                      );
                    }
                  },
                );
              },
            ),
            delay: 50,
          ),
          _SettingsTile(
            icon: Icons.timer,
            iconColor: AppColors.categoryCard,
            title: 'Auto-lock Timeout',
            subtitle: '5 minutes',
            onTap: () {},
            delay: 100,
          ),
          _SettingsTile(
            icon: Icons.content_paste_off,
            iconColor: AppColors.categoryNote,
            title: 'Clear Clipboard',
            subtitle: '30 seconds',
            onTap: () {},
            delay: 150,
          ),
          const SizedBox(height: 24),

          // Appearance section
          _SectionHeader(title: 'Appearance', delay: 200),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              String currentTheme = 'System default';
              if (state is SettingsLoaded) {
                switch (state.settings.themeMode) {
                  case 'light':
                    currentTheme = 'Light';
                    break;
                  case 'dark':
                    currentTheme = 'Dark';
                    break;
                  case 'system':
                  default:
                    currentTheme = 'System default';
                    break;
                }
              }

              return _SettingsTile(
                icon: Icons.dark_mode,
                iconColor: AppColors.categoryIdentity,
                title: 'Theme',
                subtitle: currentTheme,
                onTap: () {
                  _showThemeDialog(context);
                },
                delay: 250,
              );
            },
          ),
          const SizedBox(height: 24),

          // Data section
          _SectionHeader(title: 'Data', delay: 300),
          _SettingsTile(
            icon: Icons.upload,
            iconColor: AppColors.success,
            title: 'Export Vault',
            subtitle: 'Export encrypted backup',
            onTap: () {},
            delay: 350,
          ),
          _SettingsTile(
            icon: Icons.download,
            iconColor: AppColors.info,
            title: 'Import',
            subtitle: 'Import from backup or other managers',
            onTap: () {},
            delay: 400,
          ),
          const SizedBox(height: 24),

          // About section
          _SectionHeader(title: 'About', delay: 450),
          _SettingsTile(
            icon: Icons.info,
            iconColor: AppColors.textSecondaryLight,
            title: 'Version',
            subtitle: '1.0.0',
            delay: 500,
          ),
          _SettingsTile(
            icon: Icons.code,
            iconColor: AppColors.textSecondaryLight,
            title: 'Source Code',
            subtitle: 'View on GitHub',
            onTap: () {},
            delay: 550,
          ),
          const SizedBox(height: 32),

          // Danger zone
          _DangerZone(delay: 600),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              label: 'System Default',
              value: 'system',
              onTap: () {
                context.read<SettingsBloc>().add(
                  const SettingsUpdateTheme('system'),
                );
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              label: 'Light',
              value: 'light',
              onTap: () {
                context.read<SettingsBloc>().add(
                  const SettingsUpdateTheme('light'),
                );
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              label: 'Dark',
              value: 'dark',
              onTap: () {
                context.read<SettingsBloc>().add(
                  const SettingsUpdateTheme('dark'),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), onTap: onTap);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int delay;

  const _SectionHeader({required this.title, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.woodyBrown,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 300.ms,
        )
        .slideX(begin: -0.1, end: 0, duration: 300.ms);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int delay;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return BrandCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondaryLight,
                  size: 20,
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 300.ms,
        )
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }
}

class _DangerZone extends StatelessWidget {
  final int delay;

  const _DangerZone({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.error.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  title: Text('Reset Vault', style: AppTypography.headline3),
                  content: Text(
                    'This will permanently delete all your data. This action cannot be undone.',
                    style: AppTypography.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Delete Everything'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.error),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reset Vault',
                    style: AppTypography.button.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: delay),
      duration: 400.ms,
    );
  }
}
