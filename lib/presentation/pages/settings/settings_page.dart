import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth.dart';

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
        children: [
          // Security section
          _SectionHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Unlock'),
            subtitle: const Text('Use fingerprint or face to unlock'),
            trailing: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                // Simplified - would need proper state management
                return Switch(
                  value: false,
                  onChanged: (value) {
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
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Auto-lock Timeout'),
            subtitle: const Text('5 minutes'),
            onTap: () {
              // Show timeout picker
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_off),
            title: const Text('Clear Clipboard'),
            subtitle: const Text('30 seconds'),
            onTap: () {
              // Show timeout picker
            },
          ),
          const Divider(),

          // Appearance section
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {
              // Show theme picker
            },
          ),
          const Divider(),

          // Data section
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Vault'),
            subtitle: const Text('Export encrypted backup'),
            onTap: () {
              // Export functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import'),
            subtitle: const Text('Import from backup or other managers'),
            onTap: () {
              // Import functionality
            },
          ),
          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: const Text('View on GitHub'),
            onTap: () {
              // Open GitHub
            },
          ),
          const SizedBox(height: 32),

          // Danger zone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Vault'),
                    content: const Text(
                      'This will permanently delete all your data. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Reset vault
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete Everything'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text(
                'Reset Vault',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
