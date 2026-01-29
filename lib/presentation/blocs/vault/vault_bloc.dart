import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/vault_repository.dart';
import 'vault_event.dart';
import 'vault_state.dart';

/// BLoC for handling vault operations.
class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final VaultRepository _vaultRepository;

  VaultBloc({required VaultRepository vaultRepository})
    : _vaultRepository = vaultRepository,
      super(const VaultInitial()) {
    on<VaultLoadEntries>(_onLoadEntries);
    on<VaultSearchEntries>(_onSearchEntries);
    on<VaultFilterByCategory>(_onFilterByCategory);
    on<VaultShowFavorites>(_onShowFavorites);
    on<VaultCreateEntry>(_onCreateEntry);
    on<VaultUpdateEntry>(_onUpdateEntry);
    on<VaultDeleteEntry>(_onDeleteEntry);
    on<VaultToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadEntries(
    VaultLoadEntries event,
    Emitter<VaultState> emit,
  ) async {
    emit(const VaultLoading());

    try {
      final entries = await _vaultRepository.getAllEntries();
      emit(VaultLoaded(entries: entries, filteredEntries: entries));
    } catch (e) {
      emit(VaultError('Failed to load entries: $e'));
    }
  }

  Future<void> _onSearchEntries(
    VaultSearchEntries event,
    Emitter<VaultState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VaultLoaded) return;

    final query = event.query.toLowerCase();
    final filtered = currentState.entries.where((entry) {
      return entry.name.toLowerCase().contains(query) ||
          (entry.username?.toLowerCase().contains(query) ?? false) ||
          (entry.uri?.toLowerCase().contains(query) ?? false);
    }).toList();

    emit(
      currentState.copyWith(
        filteredEntries: filtered,
        searchQuery: event.query,
      ),
    );
  }

  Future<void> _onFilterByCategory(
    VaultFilterByCategory event,
    Emitter<VaultState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VaultLoaded) return;

    final filtered = event.categoryId == null
        ? currentState.entries
        : currentState.entries
              .where((e) => e.categoryId == event.categoryId)
              .toList();

    emit(
      currentState.copyWith(
        filteredEntries: filtered,
        categoryFilter: event.categoryId,
      ),
    );
  }

  Future<void> _onShowFavorites(
    VaultShowFavorites event,
    Emitter<VaultState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VaultLoaded) return;

    final filtered = event.showOnlyFavorites
        ? currentState.entries.where((e) => e.isFavorite).toList()
        : currentState.entries;

    emit(
      currentState.copyWith(
        filteredEntries: filtered,
        showOnlyFavorites: event.showOnlyFavorites,
      ),
    );
  }

  Future<void> _onCreateEntry(
    VaultCreateEntry event,
    Emitter<VaultState> emit,
  ) async {
    try {
      await _vaultRepository.createEntry(event.entry);
      add(const VaultLoadEntries());
    } catch (e) {
      emit(VaultError('Failed to create entry: $e'));
    }
  }

  Future<void> _onUpdateEntry(
    VaultUpdateEntry event,
    Emitter<VaultState> emit,
  ) async {
    try {
      await _vaultRepository.updateEntry(event.entry);
      add(const VaultLoadEntries());
    } catch (e) {
      emit(VaultError('Failed to update entry: $e'));
    }
  }

  Future<void> _onDeleteEntry(
    VaultDeleteEntry event,
    Emitter<VaultState> emit,
  ) async {
    try {
      await _vaultRepository.deleteEntry(event.id);
      add(const VaultLoadEntries());
    } catch (e) {
      emit(VaultError('Failed to delete entry: $e'));
    }
  }

  Future<void> _onToggleFavorite(
    VaultToggleFavorite event,
    Emitter<VaultState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VaultLoaded) return;

    try {
      final entry = currentState.entries.firstWhere((e) => e.id == event.id);
      final updated = entry.copyWith(isFavorite: !entry.isFavorite);
      await _vaultRepository.updateEntry(updated);
      add(const VaultLoadEntries());
    } catch (e) {
      emit(VaultError('Failed to toggle favorite: $e'));
    }
  }
}
