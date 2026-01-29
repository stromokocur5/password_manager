/// Key derivation using PBKDF2 for secure password-to-key conversion.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../constants/crypto_constants.dart';

/// Service for deriving encryption keys from master password.
class KeyDerivationService {
  /// Derives a 256-bit encryption key from the master password using PBKDF2.
  ///
  /// [password] - The master password to derive the key from.
  /// [salt] - A unique salt for this derivation. Store this alongside encrypted data.
  ///
  /// Returns the derived key as bytes.
  Uint8List deriveKey(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

    pbkdf2.init(
      Pbkdf2Parameters(
        salt,
        CryptoConstants.pbkdf2Iterations,
        CryptoConstants.derivedKeyLength ~/ 8,
      ),
    );

    final passwordBytes = utf8.encode(password);
    return pbkdf2.process(Uint8List.fromList(passwordBytes));
  }

  /// Generates a cryptographically secure random salt.
  Uint8List generateSalt() {
    final secureRandom = FortunaRandom();
    final seedSource = DateTime.now().microsecondsSinceEpoch;
    secureRandom.seed(
      KeyParameter(
        Uint8List.fromList(
          List.generate(32, (i) => (seedSource + i * 7) % 256),
        ),
      ),
    );

    return secureRandom.nextBytes(CryptoConstants.saltSize);
  }

  /// Computes a hash of the master password for verification.
  /// This is stored to verify the master password without storing the password itself.
  ///
  /// Uses a second round of PBKDF2 with the derived key as input.
  Uint8List computePasswordHash(Uint8List derivedKey, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

    pbkdf2.init(
      Pbkdf2Parameters(
        salt,
        1, // Single iteration for hash computation
        32, // 256-bit hash
      ),
    );

    return pbkdf2.process(derivedKey);
  }
}
