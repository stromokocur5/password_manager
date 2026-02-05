import 'dart:typed_data';

import 'package:local_auth/local_auth.dart';

import '../../core/encryption/encryption.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/secure_datasource.dart';

/// Implementation of [AuthRepository] using secure storage and local_auth.
class AuthRepositoryImpl implements AuthRepository {
  final SecureDataSource _secureDataSource;
  final LocalDataSource _localDataSource;
  final KeyDerivationService _keyDerivation;
  final LocalAuthentication _localAuth;

  /// The current encryption key (in memory only when unlocked).
  Uint8List? _currentKey;

  AuthRepositoryImpl({
    required SecureDataSource secureDataSource,
    required LocalDataSource localDataSource,
    required KeyDerivationService keyDerivation,
    LocalAuthentication? localAuth,
  }) : _secureDataSource = secureDataSource,
       _localDataSource = localDataSource,
       _keyDerivation = keyDerivation,
       _localAuth = localAuth ?? LocalAuthentication();

  /// Gets the current encryption key (null if locked).
  Uint8List? get currentKey => _currentKey;

  /// Checks if the vault is currently unlocked.
  bool get isUnlocked => _currentKey != null;

  @override
  Future<bool> isVaultSetUp() async {
    return _secureDataSource.isVaultSetUp();
  }

  @override
  Future<Uint8List> setupVault(String masterPassword) async {
    // Generate salt
    final salt = _keyDerivation.generateSalt();

    // Derive key from password
    final key = _keyDerivation.deriveKey(masterPassword, salt);

    // Generate password verification hash
    final passwordHash = _keyDerivation.computePasswordHash(key, salt);

    // Store salt and hash
    await _secureDataSource.storeSalt(salt);
    await _secureDataSource.storePasswordHash(passwordHash);
    await _secureDataSource.markVaultSetUp();

    // Keep key in memory
    _currentKey = key;

    return key;
  }

  @override
  Future<Uint8List?> unlockVault(String masterPassword) async {
    // Get stored salt
    final salt = await _secureDataSource.getSalt();
    if (salt == null) return null;

    // Derive key from provided password
    final key = _keyDerivation.deriveKey(masterPassword, salt);

    // Compute hash and compare
    final computedHash = _keyDerivation.computePasswordHash(key, salt);
    final storedHash = await _secureDataSource.getPasswordHash();

    if (storedHash == null) return null;

    // Constant-time comparison to prevent timing attacks
    if (!_constantTimeEquals(computedHash, storedHash)) {
      return null;
    }

    // Password verified, store key in memory
    _currentKey = key;
    return key;
  }

  @override
  Future<void> lockVault() async {
    // Clear key from memory
    if (_currentKey != null) {
      // Overwrite with zeros before clearing
      _currentKey!.fillRange(0, _currentKey!.length, 0);
      _currentKey = null;
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return _secureDataSource.hasBiometricKey();
  }

  @override
  Future<void> enableBiometric(Uint8List encryptionKey) async {
    await _secureDataSource.storeBiometricKey(encryptionKey);
  }

  @override
  Future<void> disableBiometric() async {
    await _secureDataSource.deleteBiometricKey();
  }

  @override
  Future<Uint8List?> unlockWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock your vault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) return null;

      // Get the stored key
      final key = await _secureDataSource.getBiometricKey();
      if (key == null) return null;

      _currentKey = key;
      return key;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> changeMasterPassword(
    String currentPassword,
    String newPassword,
  ) async {
    // Verify current password
    final key = await unlockVault(currentPassword);
    if (key == null) return false;

    // Lock vault (clears old key)
    await lockVault();

    // Setup with new password
    await setupVault(newPassword);

    return true;
  }

  /// Constant-time byte comparison to prevent timing attacks.
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Resets the entire vault by clearing all data.
  /// This is a destructive operation used when the user forgets their master password.
  Future<void> resetVault() async {
    // Clear encryption key from memory
    await lockVault();

    // Clear secure storage (salt, password hash, biometric key)
    await _secureDataSource.clearAll();

    // Clear all password entries from local database
    await _localDataSource.clearAllEntries();
  }
}
