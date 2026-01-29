import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsLoad extends SettingsEvent {
  const SettingsLoad();
}

class SettingsUpdateTheme extends SettingsEvent {
  final String themeMode;

  const SettingsUpdateTheme(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
