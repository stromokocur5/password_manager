import 'package:equatable/equatable.dart';

import '../../../domain/entities/password_entry.dart';

/// Events for vault BLoC.
abstract class VaultEvent extends Equatable {
  const VaultEvent();

  @override
  List<Object?> get props => [];
}

/// Load all entries.
class VaultLoadEntries extends VaultEvent {
  const VaultLoadEntries();
}

/// Search entries.
class VaultSearchEntries extends VaultEvent {
  final String query;

  const VaultSearchEntries(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by category.
class VaultFilterByCategory extends VaultEvent {
  final String? categoryId;

  const VaultFilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Show only favorites.
class VaultShowFavorites extends VaultEvent {
  final bool showOnlyFavorites;

  const VaultShowFavorites(this.showOnlyFavorites);

  @override
  List<Object?> get props => [showOnlyFavorites];
}

/// Create a new entry.
class VaultCreateEntry extends VaultEvent {
  final PasswordEntry entry;

  const VaultCreateEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Update an entry.
class VaultUpdateEntry extends VaultEvent {
  final PasswordEntry entry;

  const VaultUpdateEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Delete an entry.
class VaultDeleteEntry extends VaultEvent {
  final String id;

  const VaultDeleteEntry(this.id);

  @override
  List<Object?> get props => [id];
}

/// Toggle favorite status.
class VaultToggleFavorite extends VaultEvent {
  final String id;

  const VaultToggleFavorite(this.id);

  @override
  List<Object?> get props => [id];
}
