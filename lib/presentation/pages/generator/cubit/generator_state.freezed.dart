// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GeneratorState {
  String get password => throw _privateConstructorUsedError;
  PasswordStrength get strength => throw _privateConstructorUsedError;
  double get length => throw _privateConstructorUsedError;
  bool get includeUppercase => throw _privateConstructorUsedError;
  bool get includeLowercase => throw _privateConstructorUsedError;
  bool get includeDigits => throw _privateConstructorUsedError;
  bool get includeSpecial => throw _privateConstructorUsedError;
  bool get excludeAmbiguous => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GeneratorStateCopyWith<GeneratorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratorStateCopyWith<$Res> {
  factory $GeneratorStateCopyWith(
          GeneratorState value, $Res Function(GeneratorState) then) =
      _$GeneratorStateCopyWithImpl<$Res, GeneratorState>;
  @useResult
  $Res call(
      {String password,
      PasswordStrength strength,
      double length,
      bool includeUppercase,
      bool includeLowercase,
      bool includeDigits,
      bool includeSpecial,
      bool excludeAmbiguous});
}

/// @nodoc
class _$GeneratorStateCopyWithImpl<$Res, $Val extends GeneratorState>
    implements $GeneratorStateCopyWith<$Res> {
  _$GeneratorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = null,
    Object? strength = null,
    Object? length = null,
    Object? includeUppercase = null,
    Object? includeLowercase = null,
    Object? includeDigits = null,
    Object? includeSpecial = null,
    Object? excludeAmbiguous = null,
  }) {
    return _then(_value.copyWith(
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as PasswordStrength,
      length: null == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as double,
      includeUppercase: null == includeUppercase
          ? _value.includeUppercase
          : includeUppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      includeLowercase: null == includeLowercase
          ? _value.includeLowercase
          : includeLowercase // ignore: cast_nullable_to_non_nullable
              as bool,
      includeDigits: null == includeDigits
          ? _value.includeDigits
          : includeDigits // ignore: cast_nullable_to_non_nullable
              as bool,
      includeSpecial: null == includeSpecial
          ? _value.includeSpecial
          : includeSpecial // ignore: cast_nullable_to_non_nullable
              as bool,
      excludeAmbiguous: null == excludeAmbiguous
          ? _value.excludeAmbiguous
          : excludeAmbiguous // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeneratorStateImplCopyWith<$Res>
    implements $GeneratorStateCopyWith<$Res> {
  factory _$$GeneratorStateImplCopyWith(_$GeneratorStateImpl value,
          $Res Function(_$GeneratorStateImpl) then) =
      __$$GeneratorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String password,
      PasswordStrength strength,
      double length,
      bool includeUppercase,
      bool includeLowercase,
      bool includeDigits,
      bool includeSpecial,
      bool excludeAmbiguous});
}

/// @nodoc
class __$$GeneratorStateImplCopyWithImpl<$Res>
    extends _$GeneratorStateCopyWithImpl<$Res, _$GeneratorStateImpl>
    implements _$$GeneratorStateImplCopyWith<$Res> {
  __$$GeneratorStateImplCopyWithImpl(
      _$GeneratorStateImpl _value, $Res Function(_$GeneratorStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? password = null,
    Object? strength = null,
    Object? length = null,
    Object? includeUppercase = null,
    Object? includeLowercase = null,
    Object? includeDigits = null,
    Object? includeSpecial = null,
    Object? excludeAmbiguous = null,
  }) {
    return _then(_$GeneratorStateImpl(
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as PasswordStrength,
      length: null == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as double,
      includeUppercase: null == includeUppercase
          ? _value.includeUppercase
          : includeUppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      includeLowercase: null == includeLowercase
          ? _value.includeLowercase
          : includeLowercase // ignore: cast_nullable_to_non_nullable
              as bool,
      includeDigits: null == includeDigits
          ? _value.includeDigits
          : includeDigits // ignore: cast_nullable_to_non_nullable
              as bool,
      includeSpecial: null == includeSpecial
          ? _value.includeSpecial
          : includeSpecial // ignore: cast_nullable_to_non_nullable
              as bool,
      excludeAmbiguous: null == excludeAmbiguous
          ? _value.excludeAmbiguous
          : excludeAmbiguous // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$GeneratorStateImpl implements _GeneratorState {
  const _$GeneratorStateImpl(
      {this.password = '',
      this.strength = PasswordStrength.weak,
      this.length = 16,
      this.includeUppercase = true,
      this.includeLowercase = true,
      this.includeDigits = true,
      this.includeSpecial = true,
      this.excludeAmbiguous = false});

  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final PasswordStrength strength;
  @override
  @JsonKey()
  final double length;
  @override
  @JsonKey()
  final bool includeUppercase;
  @override
  @JsonKey()
  final bool includeLowercase;
  @override
  @JsonKey()
  final bool includeDigits;
  @override
  @JsonKey()
  final bool includeSpecial;
  @override
  @JsonKey()
  final bool excludeAmbiguous;

  @override
  String toString() {
    return 'GeneratorState(password: $password, strength: $strength, length: $length, includeUppercase: $includeUppercase, includeLowercase: $includeLowercase, includeDigits: $includeDigits, includeSpecial: $includeSpecial, excludeAmbiguous: $excludeAmbiguous)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratorStateImpl &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.includeUppercase, includeUppercase) ||
                other.includeUppercase == includeUppercase) &&
            (identical(other.includeLowercase, includeLowercase) ||
                other.includeLowercase == includeLowercase) &&
            (identical(other.includeDigits, includeDigits) ||
                other.includeDigits == includeDigits) &&
            (identical(other.includeSpecial, includeSpecial) ||
                other.includeSpecial == includeSpecial) &&
            (identical(other.excludeAmbiguous, excludeAmbiguous) ||
                other.excludeAmbiguous == excludeAmbiguous));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      password,
      strength,
      length,
      includeUppercase,
      includeLowercase,
      includeDigits,
      includeSpecial,
      excludeAmbiguous);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratorStateImplCopyWith<_$GeneratorStateImpl> get copyWith =>
      __$$GeneratorStateImplCopyWithImpl<_$GeneratorStateImpl>(
          this, _$identity);
}

abstract class _GeneratorState implements GeneratorState {
  const factory _GeneratorState(
      {final String password,
      final PasswordStrength strength,
      final double length,
      final bool includeUppercase,
      final bool includeLowercase,
      final bool includeDigits,
      final bool includeSpecial,
      final bool excludeAmbiguous}) = _$GeneratorStateImpl;

  @override
  String get password;
  @override
  PasswordStrength get strength;
  @override
  double get length;
  @override
  bool get includeUppercase;
  @override
  bool get includeLowercase;
  @override
  bool get includeDigits;
  @override
  bool get includeSpecial;
  @override
  bool get excludeAmbiguous;
  @override
  @JsonKey(ignore: true)
  _$$GeneratorStateImplCopyWith<_$GeneratorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
