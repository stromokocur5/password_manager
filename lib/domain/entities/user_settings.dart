import 'package:equatable/equatable.dart';

/// Domain entity for user settings.
class UserSettings extends Equatable {
  final int autoLockMinutes;
  final int clipboardClearSeconds;
  final bool biometricEnabled;
  final String themeMode; // 'system', 'light', 'dark'
  final int defaultPasswordLength;

  const UserSettings({
    required this.autoLockMinutes,
    required this.clipboardClearSeconds,
    required this.biometricEnabled,
    required this.themeMode,
    required this.defaultPasswordLength,
  });

  factory UserSettings.defaults() {
    return const UserSettings(
      autoLockMinutes: 5,
      clipboardClearSeconds: 30,
      biometricEnabled: false,
      themeMode: 'system',
      defaultPasswordLength: 16,
    );
  }

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
