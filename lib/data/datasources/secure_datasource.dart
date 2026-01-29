import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Data source for secure storage of sensitive data (encryption keys, etc).
class SecureDataSource {
  static const String _saltKey = 'vault_salt';
  static const String _passwordHashKey = 'password_hash';
  static const String _biometricKeyKey = 'biometric_key';
  static const String _vaultSetupKey = 'vault_setup';

  final FlutterSecureStorage _storage;

  SecureDataSource()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  // ===== Vault Setup =====

  /// Checks if the vault has been set up.
  Future<bool> isVaultSetUp() async {
    final value = await _storage.read(key: _vaultSetupKey);
    return value == 'true';
  }

  /// Marks the vault as set up.
  Future<void> markVaultSetUp() async {
    await _storage.write(key: _vaultSetupKey, value: 'true');
  }

  // ===== Salt Storage =====

  /// Stores the salt for key derivation.
  Future<void> storeSalt(Uint8List salt) async {
    await _storage.write(key: _saltKey, value: base64Encode(salt));
  }

  /// Retrieves the stored salt.
  Future<Uint8List?> getSalt() async {
    final encoded = await _storage.read(key: _saltKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  // ===== Password Hash Storage =====

  /// Stores the password verification hash.
  Future<void> storePasswordHash(Uint8List hash) async {
    await _storage.write(key: _passwordHashKey, value: base64Encode(hash));
  }

  /// Retrieves the stored password hash.
  Future<Uint8List?> getPasswordHash() async {
    final encoded = await _storage.read(key: _passwordHashKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  // ===== Biometric Key Storage =====

  /// Stores the encryption key for biometric unlock.
  Future<void> storeBiometricKey(Uint8List key) async {
    await _storage.write(key: _biometricKeyKey, value: base64Encode(key));
  }

  /// Retrieves the biometric encryption key.
  Future<Uint8List?> getBiometricKey() async {
    final encoded = await _storage.read(key: _biometricKeyKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  /// Deletes the biometric key.
  Future<void> deleteBiometricKey() async {
    await _storage.delete(key: _biometricKeyKey);
  }

  /// Checks if biometric key is stored.
  Future<bool> hasBiometricKey() async {
    final key = await _storage.read(key: _biometricKeyKey);
    return key != null;
  }

  // ===== Utility =====

  /// Clears all secure storage (for vault reset).
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
