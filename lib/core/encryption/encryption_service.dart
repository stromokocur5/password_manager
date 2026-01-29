/// AES-256-GCM encryption service for secure data encryption.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../constants/crypto_constants.dart';

/// Result of an encryption operation containing ciphertext and IV.
class EncryptedData {
  /// The encrypted data including authentication tag.
  final Uint8List ciphertext;

  /// The initialization vector used for encryption.
  final Uint8List iv;

  const EncryptedData({required this.ciphertext, required this.iv});

  /// Serializes to a single byte array: [iv][ciphertext].
  Uint8List toBytes() {
    final result = Uint8List(iv.length + ciphertext.length);
    result.setAll(0, iv);
    result.setAll(iv.length, ciphertext);
    return result;
  }

  /// Reconstructs from serialized bytes.
  factory EncryptedData.fromBytes(Uint8List bytes) {
    if (bytes.length < CryptoConstants.ivSize + CryptoConstants.tagSize) {
      throw ArgumentError('Invalid encrypted data length');
    }

    return EncryptedData(
      iv: Uint8List.sublistView(bytes, 0, CryptoConstants.ivSize),
      ciphertext: Uint8List.sublistView(bytes, CryptoConstants.ivSize),
    );
  }

  /// Converts to base64 string for storage.
  String toBase64() => base64Encode(toBytes());

  /// Reconstructs from base64 string.
  factory EncryptedData.fromBase64(String encoded) {
    return EncryptedData.fromBytes(base64Decode(encoded));
  }
}

/// Service for AES-256-GCM encryption and decryption.
class EncryptionService {
  final FortunaRandom _secureRandom;

  EncryptionService() : _secureRandom = FortunaRandom() {
    // Seed the random number generator
    final seedSource = DateTime.now().microsecondsSinceEpoch;
    _secureRandom.seed(
      KeyParameter(
        Uint8List.fromList(
          List.generate(32, (i) => (seedSource + i * 11) % 256),
        ),
      ),
    );
  }

  /// Encrypts plaintext using AES-256-GCM.
  ///
  /// [plaintext] - The data to encrypt.
  /// [key] - 256-bit encryption key.
  ///
  /// Returns [EncryptedData] containing ciphertext and IV.
  EncryptedData encrypt(Uint8List plaintext, Uint8List key) {
    _validateKeyLength(key);

    final iv = _generateIv();
    final cipher = GCMBlockCipher(AESEngine());

    cipher.init(
      true, // encrypt
      AEADParameters(
        KeyParameter(key),
        CryptoConstants.tagSize * 8, // tag length in bits
        iv,
        Uint8List(0), // no additional authenticated data
      ),
    );

    final ciphertext = cipher.process(plaintext);

    return EncryptedData(ciphertext: ciphertext, iv: iv);
  }

  /// Encrypts a string and returns base64-encoded result.
  String encryptString(String plaintext, Uint8List key) {
    final plaintextBytes = utf8.encode(plaintext);
    final encrypted = encrypt(Uint8List.fromList(plaintextBytes), key);
    return encrypted.toBase64();
  }

  /// Decrypts ciphertext using AES-256-GCM.
  ///
  /// [encryptedData] - The encrypted data with IV.
  /// [key] - 256-bit encryption key (same key used for encryption).
  ///
  /// Returns the original plaintext.
  /// Throws [ArgumentError] if decryption fails (wrong key or tampered data).
  Uint8List decrypt(EncryptedData encryptedData, Uint8List key) {
    _validateKeyLength(key);

    final cipher = GCMBlockCipher(AESEngine());

    cipher.init(
      false, // decrypt
      AEADParameters(
        KeyParameter(key),
        CryptoConstants.tagSize * 8,
        encryptedData.iv,
        Uint8List(0),
      ),
    );

    try {
      return cipher.process(encryptedData.ciphertext);
    } catch (e) {
      throw ArgumentError('Decryption failed: invalid key or corrupted data');
    }
  }

  /// Decrypts a base64-encoded string.
  String decryptString(String encryptedBase64, Uint8List key) {
    final encryptedData = EncryptedData.fromBase64(encryptedBase64);
    final plaintext = decrypt(encryptedData, key);
    return utf8.decode(plaintext);
  }

  /// Generates a cryptographically secure random IV.
  Uint8List _generateIv() {
    return _secureRandom.nextBytes(CryptoConstants.ivSize);
  }

  /// Validates that the key is the correct length.
  void _validateKeyLength(Uint8List key) {
    final expectedLength = CryptoConstants.aesKeySize ~/ 8;
    if (key.length != expectedLength) {
      throw ArgumentError(
        'Key must be $expectedLength bytes (${CryptoConstants.aesKeySize} bits)',
      );
    }
  }
}
