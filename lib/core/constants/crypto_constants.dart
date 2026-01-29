/// Cryptographic constants for secure encryption operations.
library;

/// Constants for encryption and key derivation
class CryptoConstants {
  CryptoConstants._();

  /// AES key size in bits (256-bit for AES-256)
  static const int aesKeySize = 256;

  /// AES block size in bytes
  static const int aesBlockSize = 16;

  /// IV (Initialization Vector) size in bytes for AES-GCM
  static const int ivSize = 12;

  /// Authentication tag size for GCM mode
  static const int tagSize = 16;

  /// Salt size for key derivation
  static const int saltSize = 32;

  /// PBKDF2 iteration count (OWASP recommends 600k+ for PBKDF2-SHA256)
  /// Using 100k as a balance between security and mobile performance
  static const int pbkdf2Iterations = 100000;

  /// Derived key length in bits
  static const int derivedKeyLength = 256;

  /// Hash algorithm for PBKDF2
  static const String hashAlgorithm = 'SHA-256';
}
