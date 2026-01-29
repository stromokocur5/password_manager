import 'package:hive/hive.dart';

part 'user_settings_model.g.dart';

/// Hive model for user settings.
@HiveType(typeId: 3)
class UserSettingsModel extends HiveObject {
  @HiveField(0)
  late int autoLockMinutes;

  @HiveField(1)
  late int clipboardClearSeconds;

  @HiveField(2)
  late bool biometricEnabled;

  @HiveField(3)
  late String themeMode;

  @HiveField(4)
  late int defaultPasswordLength;

  UserSettingsModel();

  UserSettingsModel.create({
    this.autoLockMinutes = 5,
    this.clipboardClearSeconds = 30,
    this.biometricEnabled = false,
    this.themeMode = 'system',
    this.defaultPasswordLength = 16,
  });

  /// Default settings instance.
  factory UserSettingsModel.defaults() => UserSettingsModel.create();
}
