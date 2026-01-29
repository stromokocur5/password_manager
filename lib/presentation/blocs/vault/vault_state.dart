import 'package:equatable/equatable.dart';

import '../../../domain/entities/password_entry.dart';

/// States for vault BLoC.
abstract class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class VaultInitial extends VaultState {
  const VaultInitial();
}

/// Loading entries.
class VaultLoading extends VaultState {
  const VaultLoading();
}

/// Entries loaded successfully.
class VaultLoaded extends VaultState {
  final List<PasswordEntry> entries;
  final List<PasswordEntry> filteredEntries;
  final String? searchQuery;
  final String? categoryFilter;
  final bool showOnlyFavorites;

  const VaultLoaded({
    required this.entries,
    required this.filteredEntries,
    this.searchQuery,
    this.categoryFilter,
    this.showOnlyFavorites = false,
  });

  @override
  List<Object?> get props => [
    entries,
    filteredEntries,
    searchQuery,
    categoryFilter,
    showOnlyFavorites,
  ];

  VaultLoaded copyWith({
    List<PasswordEntry>? entries,
    List<PasswordEntry>? filteredEntries,
    String? searchQuery,
    String? categoryFilter,
    bool? showOnlyFavorites,
  }) {
    return VaultLoaded(
      entries: entries ?? this.entries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}

/// Error loading or manipulating vault.
class VaultError extends VaultState {
  final String message;

  const VaultError(this.message);

  @override
  List<Object?> get props => [message];
}
