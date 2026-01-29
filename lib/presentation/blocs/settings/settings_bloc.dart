import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/vault_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final VaultRepository _vaultRepository;

  SettingsBloc({required VaultRepository vaultRepository})
    : _vaultRepository = vaultRepository,
      super(SettingsInitial()) {
    on<SettingsLoad>(_onLoad);
    on<SettingsUpdateTheme>(_onUpdateTheme);
  }

  Future<void> _onLoad(SettingsLoad event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final settings = _vaultRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateTheme(
    SettingsUpdateTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        final newSettings = currentState.settings.copyWith(
          themeMode: event.themeMode,
        );
        await _vaultRepository.saveSettings(newSettings);
        emit(SettingsLoaded(newSettings));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }
}
