import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:password_manager/core/utils/password_generator.dart';
import 'package:password_manager/presentation/pages/generator/cubit/generator_cubit.dart';
import 'package:password_manager/presentation/pages/generator/cubit/generator_state.dart';

class MockPasswordGenerator extends Mock implements PasswordGenerator {}

void main() {
  late PasswordGenerator generator;
  late GeneratorCubit cubit;

  setUp(() {
    registerFallbackValue(const PasswordGeneratorOptions());
    generator = MockPasswordGenerator();
    when(() => generator.generate(any())).thenReturn('mockPassword');
    when(
      () => generator.evaluateStrength(any()),
    ).thenReturn(PasswordStrength.strong);
    cubit = GeneratorCubit(generator);
  });

  group('GeneratorCubit', () {
    test('initial state is correct', () {
      expect(
        cubit.state,
        const GeneratorState(
          password: 'mockPassword',
          strength: PasswordStrength.strong,
        ),
      );
    });

    blocTest<GeneratorCubit, GeneratorState>(
      'updateLength updates length and regenerates password',
      build: () => cubit,
      act: (cubit) => cubit.updateLength(24),
      expect: () => [
        const GeneratorState(
          password: 'mockPassword',
          strength: PasswordStrength.strong,
          length: 24,
        ),
      ],
    );

    blocTest<GeneratorCubit, GeneratorState>(
      'toggleUppercase updates state and regenerates password',
      build: () => cubit,
      act: (cubit) => cubit.toggleUppercase(false),
      expect: () => [
        const GeneratorState(
          password: 'mockPassword',
          strength: PasswordStrength.strong,
          includeUppercase: false,
        ),
      ],
    );

    blocTest<GeneratorCubit, GeneratorState>(
      'toggleLowercase updates state and regenerates password',
      build: () => cubit,
      act: (cubit) => cubit.toggleLowercase(false),
      expect: () => [
        const GeneratorState(
          password: 'mockPassword',
          strength: PasswordStrength.strong,
          includeLowercase: false,
        ),
      ],
    );

    blocTest<GeneratorCubit, GeneratorState>(
      'toggleDigits updates state and regenerates password',
      build: () => cubit,
      act: (cubit) => cubit.toggleDigits(false),
      expect: () => [
        const GeneratorState(
          password: 'mockPassword',
          strength: PasswordStrength.strong,
          includeDigits: false,
        ),
      ],
    );

    blocTest<GeneratorCubit, GeneratorState>(
      'toggleSpecial updates state and regenerates password',
      build: () => cubit,
      act: (cubit) => cubit.toggleSpecial(false),
      expect: () => [
        const GeneratorState(
          password: 'mockPassword',
          strength: PasswordStrength.strong,
          includeSpecial: false,
        ),
      ],
    );

    blocTest<GeneratorCubit, GeneratorState>(
      'toggleExcludeAmbiguous updates state and regenerates password',
      build: () => cubit,
      act: (cubit) => cubit.toggleExcludeAmbiguous(true),
      expect: () => [
        const GeneratorState(
          password: 'mockPassword',
          strength: PasswordStrength.strong,
          excludeAmbiguous: true,
        ),
      ],
    );
  });
}
