import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/password_entry.dart';
import '../../blocs/vault/vault.dart';

/// Main vault page showing all password entries.
class VaultPage extends StatefulWidget {
  final VoidCallback onAddEntry;
  final void Function(PasswordEntry entry) onViewEntry;
  final VoidCallback onOpenSettings;
  final VoidCallback onLock;

  const VaultPage({
    super.key,
    required this.onAddEntry,
    required this.onViewEntry,
    required this.onOpenSettings,
    required this.onLock,
  });

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VaultBloc>().add(const VaultLoadEntries());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<VaultBloc>().add(VaultSearchEntries(query));
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Lock vault',
            onPressed: widget.onLock,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: widget.onOpenSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vault...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: BlocBuilder<VaultBloc, VaultState>(
              builder: (context, state) {
                if (state is VaultLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VaultError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<VaultBloc>().add(
                            const VaultLoadEntries(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is VaultLoaded) {
                  if (state.filteredEntries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.searchQuery?.isNotEmpty == true
                                ? Icons.search_off
                                : Icons.lock_open,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery?.isNotEmpty == true
                                ? 'No entries found'
                                : 'Your vault is empty',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.searchQuery?.isNotEmpty == true
                                ? 'Try a different search term'
                                : 'Tap + to add your first entry',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = state.filteredEntries[index];
                      return _EntryCard(
                        entry: entry,
                        onTap: () => widget.onViewEntry(entry),
                        onCopyUsername: entry.username != null
                            ? () =>
                                  _copyToClipboard(entry.username!, 'Username')
                            : null,
                        onCopyPassword: entry.password != null
                            ? () =>
                                  _copyToClipboard(entry.password!, 'Password')
                            : null,
                        onToggleFavorite: () {
                          context.read<VaultBloc>().add(
                            VaultToggleFavorite(entry.id),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onCopyUsername;
  final VoidCallback? onCopyPassword;
  final VoidCallback onToggleFavorite;

  const _EntryCard({
    required this.entry,
    required this.onTap,
    this.onCopyUsername,
    this.onCopyPassword,
    required this.onToggleFavorite,
  });

  IconData _getCategoryIcon() {
    switch (entry.categoryId) {
      case 'login':
        return Icons.person;
      case 'card':
        return Icons.credit_card;
      case 'identity':
        return Icons.badge;
      case 'secure_note':
        return Icons.note;
      default:
        return Icons.lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.username != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.username!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
              if (onCopyUsername != null)
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Copy username',
                  onPressed: onCopyUsername,
                ),
              if (onCopyPassword != null)
                IconButton(
                  icon: const Icon(Icons.key),
                  tooltip: 'Copy password',
                  onPressed: onCopyPassword,
                ),
              IconButton(
                icon: Icon(
                  entry.isFavorite ? Icons.star : Icons.star_border,
                  color: entry.isFavorite ? Colors.amber : null,
                ),
                tooltip: entry.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
