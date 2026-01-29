import 'package:equatable/equatable.dart';

/// States for authentication BLoC.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking vault status.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking if vault is set up.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Vault needs to be set up (first launch).
class AuthNeedsSetup extends AuthState {
  const AuthNeedsSetup();
}

/// Vault is locked, needs authentication.
class AuthLocked extends AuthState {
  final bool biometricAvailable;
  final bool biometricEnabled;

  const AuthLocked({
    this.biometricAvailable = false,
    this.biometricEnabled = false,
  });

  @override
  List<Object?> get props => [biometricAvailable, biometricEnabled];
}

/// Vault is unlocked.
class AuthUnlocked extends AuthState {
  const AuthUnlocked();
}

/// Authentication failed.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
