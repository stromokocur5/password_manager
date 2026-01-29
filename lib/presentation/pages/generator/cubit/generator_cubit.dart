import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/core/utils/password_generator.dart';
import 'generator_state.dart';

class GeneratorCubit extends Cubit<GeneratorState> {
  final PasswordGenerator _generator;

  GeneratorCubit(this._generator) : super(const GeneratorState()) {
    generatePassword();
  }

  void generatePassword() {
    final options = PasswordGeneratorOptions(
      length: state.length.round(),
      includeUppercase: state.includeUppercase,
      includeLowercase: state.includeLowercase,
      includeDigits: state.includeDigits,
      includeSpecial: state.includeSpecial,
      excludeAmbiguous: state.excludeAmbiguous,
    );

    try {
      final password = _generator.generate(options);
      final strength = _generator.evaluateStrength(password);
      emit(state.copyWith(password: password, strength: strength));
    } catch (_) {
      // Handle error or just keep previous password
    }
  }

  Future<void> copyToClipboard() async {
    if (state.password.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: state.password));
    await HapticFeedback.lightImpact();
  }

  void updateLength(double length) {
    emit(state.copyWith(length: length));
    generatePassword();
  }

  void toggleUppercase(bool value) {
    emit(state.copyWith(includeUppercase: value));
    generatePassword();
  }

  void toggleLowercase(bool value) {
    emit(state.copyWith(includeLowercase: value));
    generatePassword();
  }

  void toggleDigits(bool value) {
    emit(state.copyWith(includeDigits: value));
    generatePassword();
  }

  void toggleSpecial(bool value) {
    emit(state.copyWith(includeSpecial: value));
    generatePassword();
  }

  void toggleExcludeAmbiguous(bool value) {
    emit(state.copyWith(excludeAmbiguous: value));
    generatePassword();
  }
}
