import 'package:equatable/equatable.dart';

/// Events for authentication BLoC.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if vault is set up.
class AuthCheckVaultSetup extends AuthEvent {
  const AuthCheckVaultSetup();
}

/// Set up a new vault with master password.
class AuthSetupVault extends AuthEvent {
  final String masterPassword;

  const AuthSetupVault(this.masterPassword);

  @override
  List<Object?> get props => [masterPassword];
}

/// Unlock vault with master password.
class AuthUnlockWithPassword extends AuthEvent {
  final String masterPassword;

  const AuthUnlockWithPassword(this.masterPassword);

  @override
  List<Object?> get props => [masterPassword];
}

/// Unlock vault with biometric.
class AuthUnlockWithBiometric extends AuthEvent {
  const AuthUnlockWithBiometric();
}

/// Lock the vault.
class AuthLockVault extends AuthEvent {
  const AuthLockVault();
}

/// Enable biometric authentication.
class AuthEnableBiometric extends AuthEvent {
  const AuthEnableBiometric();
}

/// Disable biometric authentication.
class AuthDisableBiometric extends AuthEvent {
  const AuthDisableBiometric();
}

/// Reset the vault (deletes all data).
class AuthResetVault extends AuthEvent {
  const AuthResetVault();
}
