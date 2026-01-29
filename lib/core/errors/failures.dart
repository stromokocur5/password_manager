/// Domain failure types for error handling.
library;

import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure related to encryption/decryption operations.
class EncryptionFailure extends Failure {
  const EncryptionFailure(super.message);
}

/// Failure related to storage operations.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Failure related to authentication.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Failure related to biometric authentication.
class BiometricFailure extends Failure {
  const BiometricFailure(super.message);
}

/// Failure when vault is locked.
class VaultLockedFailure extends Failure {
  const VaultLockedFailure() : super('Vault is locked');
}

/// Failure for invalid master password.
class InvalidMasterPasswordFailure extends Failure {
  const InvalidMasterPasswordFailure() : super('Invalid master password');
}

/// Failure for entry not found.
class EntryNotFoundFailure extends Failure {
  const EntryNotFoundFailure() : super('Entry not found');
}
