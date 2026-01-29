/// Core constants for the Password Manager application.
library;

/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// Application name
  static const String appName = 'SecureVault';

  /// Version
  static const String version = '1.0.0';

  /// Auto-lock timeout in minutes
  static const int autoLockTimeoutMinutes = 5;

  /// Clipboard clear timeout in seconds
  static const int clipboardClearSeconds = 30;

  /// Minimum master password length
  static const int minMasterPasswordLength = 8;

  /// Maximum password history entries
  static const int maxPasswordHistory = 10;
}
