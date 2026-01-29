import 'dart:typed_data';

/// Abstract repository for authentication operations.
abstract class AuthRepository {
  /// Checks if the vault has been set up (master password created).
  Future<bool> isVaultSetUp();

  /// Sets up a new vault with the given master password.
  /// Returns the derived encryption key.
  Future<Uint8List> setupVault(String masterPassword);

  /// Unlocks the vault with the master password.
  /// Returns the derived encryption key if successful, null otherwise.
  Future<Uint8List?> unlockVault(String masterPassword);

  /// Locks the vault (clears the encryption key from memory).
  Future<void> lockVault();

  /// Checks if biometric authentication is available.
  Future<bool> isBiometricAvailable();

  /// Checks if biometric authentication is enabled.
  Future<bool> isBiometricEnabled();

  /// Enables biometric authentication (stores key securely).
  Future<void> enableBiometric(Uint8List encryptionKey);

  /// Disables biometric authentication.
  Future<void> disableBiometric();

  /// Unlocks vault using biometric authentication.
  /// Returns the encryption key if successful, null otherwise.
  Future<Uint8List?> unlockWithBiometric();

  /// Changes the master password.
  /// Requires current password for verification.
  Future<bool> changeMasterPassword(String currentPassword, String newPassword);
}
