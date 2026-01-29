import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for handling authentication logic.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;

  AuthBloc({required AuthRepositoryImpl authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthCheckVaultSetup>(_onCheckVaultSetup);
    on<AuthSetupVault>(_onSetupVault);
    on<AuthUnlockWithPassword>(_onUnlockWithPassword);
    on<AuthUnlockWithBiometric>(_onUnlockWithBiometric);
    on<AuthLockVault>(_onLockVault);
    on<AuthEnableBiometric>(_onEnableBiometric);
    on<AuthDisableBiometric>(_onDisableBiometric);
  }

  Future<void> _onCheckVaultSetup(
    AuthCheckVaultSetup event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isSetUp = await _authRepository.isVaultSetUp();

    if (!isSetUp) {
      emit(const AuthNeedsSetup());
    } else {
      final biometricAvailable = await _authRepository.isBiometricAvailable();
      final biometricEnabled = await _authRepository.isBiometricEnabled();

      emit(
        AuthLocked(
          biometricAvailable: biometricAvailable,
          biometricEnabled: biometricEnabled,
        ),
      );
    }
  }

  Future<void> _onSetupVault(
    AuthSetupVault event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.setupVault(event.masterPassword);
      emit(const AuthUnlocked());
    } catch (e) {
      emit(AuthError('Failed to set up vault: $e'));
    }
  }

  Future<void> _onUnlockWithPassword(
    AuthUnlockWithPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final key = await _authRepository.unlockVault(event.masterPassword);

      if (key == null) {
        final biometricAvailable = await _authRepository.isBiometricAvailable();
        final biometricEnabled = await _authRepository.isBiometricEnabled();

        emit(const AuthError('Invalid master password'));
        emit(
          AuthLocked(
            biometricAvailable: biometricAvailable,
            biometricEnabled: biometricEnabled,
          ),
        );
      } else {
        emit(const AuthUnlocked());
      }
    } catch (e) {
      emit(AuthError('Failed to unlock: $e'));
    }
  }

  Future<void> _onUnlockWithBiometric(
    AuthUnlockWithBiometric event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final key = await _authRepository.unlockWithBiometric();

      if (key == null) {
        final biometricAvailable = await _authRepository.isBiometricAvailable();
        final biometricEnabled = await _authRepository.isBiometricEnabled();

        emit(
          AuthLocked(
            biometricAvailable: biometricAvailable,
            biometricEnabled: biometricEnabled,
          ),
        );
      } else {
        emit(const AuthUnlocked());
      }
    } catch (e) {
      emit(AuthError('Biometric authentication failed: $e'));
    }
  }

  Future<void> _onLockVault(
    AuthLockVault event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.lockVault();

    final biometricAvailable = await _authRepository.isBiometricAvailable();
    final biometricEnabled = await _authRepository.isBiometricEnabled();

    emit(
      AuthLocked(
        biometricAvailable: biometricAvailable,
        biometricEnabled: biometricEnabled,
      ),
    );
  }

  Future<void> _onEnableBiometric(
    AuthEnableBiometric event,
    Emitter<AuthState> emit,
  ) async {
    final key = _authRepository.currentKey;
    if (key == null) {
      emit(const AuthError('Vault must be unlocked to enable biometric'));
      return;
    }

    await _authRepository.enableBiometric(key);
    emit(const AuthUnlocked());
  }

  Future<void> _onDisableBiometric(
    AuthDisableBiometric event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.disableBiometric();
    emit(const AuthUnlocked());
  }
}
