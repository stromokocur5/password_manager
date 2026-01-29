import 'package:equatable/equatable.dart';

/// User preferences and settings.
class UserSettings extends Equatable {
  /// Auto-lock timeout in minutes (0 = never).
  final int autoLockMinutes;

  /// Clear clipboard after copying (seconds, 0 = never).
  final int clipboardClearSeconds;

  /// Whether biometric authentication is enabled.
  final bool biometricEnabled;

  /// Theme mode: 'light', 'dark', or 'system'.
  final String themeMode;

  /// Default password generator length.
  final int defaultPasswordLength;

  const UserSettings({
    this.autoLockMinutes = 5,
    this.clipboardClearSeconds = 30,
    this.biometricEnabled = false,
    this.themeMode = 'system',
    this.defaultPasswordLength = 16,
  });

  UserSettings copyWith({
    int? autoLockMinutes,
    int? clipboardClearSeconds,
    bool? biometricEnabled,
    String? themeMode,
    int? defaultPasswordLength,
  }) {
    return UserSettings(
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      clipboardClearSeconds:
          clipboardClearSeconds ?? this.clipboardClearSeconds,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      themeMode: themeMode ?? this.themeMode,
      defaultPasswordLength:
          defaultPasswordLength ?? this.defaultPasswordLength,
    );
  }

  @override
  List<Object?> get props => [
    autoLockMinutes,
    clipboardClearSeconds,
    biometricEnabled,
    themeMode,
    defaultPasswordLength,
  ];
}
