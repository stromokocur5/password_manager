import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/password_entry.dart';
import '../../blocs/vault/vault.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

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
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
            const SizedBox(width: 12),
            Text('$label copied'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: const AnimatedLogoSmall(),
        ),
        title: Text(
          'SecureVault',
          style: AppTypography.headline3.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Lock vault',
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onLock();
            },
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vault...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
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
                  return _buildLoadingState();
                }

                if (state is VaultError) {
                  return _buildErrorState(state.message);
                }

                if (state is VaultLoaded) {
                  if (state.filteredEntries.isEmpty) {
                    return _buildEmptyState(state.searchQuery);
                  }

                  return _buildEntryList(state.filteredEntries);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedLogo(size: 60)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1500.ms,
                color: AppColors.accent.withAlpha(50),
              ),
          const SizedBox(height: 24),
          Text(
            'Loading vault...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AnimatedButton(
            label: 'Retry',
            icon: Icons.refresh,
            expanded: false,
            onPressed: () =>
                context.read<VaultBloc>().add(const VaultLoadEntries()),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).shake(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildEmptyState(String? searchQuery) {
    final isSearch = searchQuery?.isNotEmpty == true;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.woodyBrown.withAlpha(10),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              isSearch ? Icons.search_off : Icons.lock_open,
              size: 56,
              color: AppColors.woodyBrown.withAlpha(100),
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 24),
          Text(
            isSearch ? 'No entries found' : 'Your vault is empty',
            style: AppTypography.headline3.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'Try a different search term'
                : 'Tap + to add your first entry',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildEntryList(List<PasswordEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _EntryCard(
              entry: entry,
              onTap: () => widget.onViewEntry(entry),
              onCopyUsername: entry.username != null
                  ? () => _copyToClipboard(entry.username!, 'Username')
                  : null,
              onCopyPassword: entry.password != null
                  ? () => _copyToClipboard(entry.password!, 'Password')
                  : null,
              onToggleFavorite: () {
                HapticFeedback.lightImpact();
                context.read<VaultBloc>().add(VaultToggleFavorite(entry.id));
              },
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 50 * index),
              duration: 300.ms,
            )
            .slideX(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: 50 * index),
              duration: 300.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onAddEntry();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withAlpha(80),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.woodyBrown, size: 28),
      ),
    ).animate().scale(
      begin: const Offset(0, 0),
      duration: 400.ms,
      curve: Curves.elasticOut,
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
    final categoryColor = getCategoryColor(entry.categoryId);

    return BrandCard(
      onTap: onTap,
      accentColor: categoryColor,
      child: Row(
        children: [
          // Category icon with colored background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(_getCategoryIcon(), color: categoryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.username != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.username!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action buttons
          if (onCopyUsername != null)
            IconButton(
              icon: const Icon(Icons.person_outline, size: 20),
              tooltip: 'Copy username',
              onPressed: onCopyUsername,
              visualDensity: VisualDensity.compact,
            ),
          if (onCopyPassword != null)
            IconButton(
              icon: const Icon(Icons.key, size: 20),
              tooltip: 'Copy password',
              onPressed: onCopyPassword,
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.star : Icons.star_border,
              color: entry.isFavorite ? AppColors.warning : null,
              size: 20,
            ),
            tooltip: entry.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
            onPressed: onToggleFavorite,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
