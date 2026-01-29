import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/password_generator.dart';

part 'generator_state.freezed.dart';

@freezed
class GeneratorState with _$GeneratorState {
  const factory GeneratorState({
    @Default('') String password,
    @Default(PasswordStrength.weak) PasswordStrength strength,
    @Default(16) double length,
    @Default(true) bool includeUppercase,
    @Default(true) bool includeLowercase,
    @Default(true) bool includeDigits,
    @Default(true) bool includeSpecial,
    @Default(false) bool excludeAmbiguous,
  }) = _GeneratorState;
}
