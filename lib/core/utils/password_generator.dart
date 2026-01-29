/// Secure random password generator with configurable options.
library;

import 'dart:math';

/// Configuration options for password generation.
class PasswordGeneratorOptions {
  /// Length of the generated password.
  final int length;

  /// Include uppercase letters (A-Z).
  final bool includeUppercase;

  /// Include lowercase letters (a-z).
  final bool includeLowercase;

  /// Include digits (0-9).
  final bool includeDigits;

  /// Include special characters (!@#$%^&*...).
  final bool includeSpecial;

  /// Exclude ambiguous characters (0, O, l, 1, I).
  final bool excludeAmbiguous;

  /// Minimum number of digits required.
  final int minimumDigits;

  /// Minimum number of special characters required.
  final int minimumSpecial;

  const PasswordGeneratorOptions({
    this.length = 16,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeDigits = true,
    this.includeSpecial = true,
    this.excludeAmbiguous = false,
    this.minimumDigits = 1,
    this.minimumSpecial = 1,
  });

  /// Strong password preset.
  static const strong = PasswordGeneratorOptions(
    length: 20,
    includeUppercase: true,
    includeLowercase: true,
    includeDigits: true,
    includeSpecial: true,
    minimumDigits: 2,
    minimumSpecial: 2,
  );

  /// PIN preset (digits only).
  static const pin = PasswordGeneratorOptions(
    length: 6,
    includeUppercase: false,
    includeLowercase: false,
    includeDigits: true,
    includeSpecial: false,
    minimumDigits: 0,
    minimumSpecial: 0,
  );
}

/// Result of password strength analysis.
enum PasswordStrength { weak, fair, good, strong, veryStrong }

/// Service for generating secure random passwords.
class PasswordGenerator {
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _digits = '0123456789';
  static const String _special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const String _ambiguous = '0OlI1';

  final Random _random;

  PasswordGenerator() : _random = Random.secure();

  /// Generates a random password based on the given options.
  String generate([
    PasswordGeneratorOptions options = const PasswordGeneratorOptions(),
  ]) {
    final characterPool = _buildCharacterPool(options);

    if (characterPool.isEmpty) {
      throw ArgumentError('At least one character type must be enabled');
    }

    if (options.length < 4) {
      throw ArgumentError('Password length must be at least 4 characters');
    }

    // Generate password ensuring minimum requirements are met
    final password = _generateWithRequirements(characterPool, options);

    return password;
  }

  /// Generates a passphrase using random words.
  String generatePassphrase({
    int wordCount = 4,
    String separator = '-',
    bool capitalize = true,
  }) {
    // Simple word list for passphrase generation
    final words = [
      'apple',
      'banana',
      'cherry',
      'dragon',
      'eagle',
      'falcon',
      'grape',
      'harbor',
      'island',
      'jungle',
      'knight',
      'lemon',
      'marble',
      'nectar',
      'ocean',
      'planet',
      'quartz',
      'rocket',
      'silver',
      'temple',
      'umbrella',
      'valley',
      'winter',
      'xenon',
      'yellow',
      'zenith',
      'anchor',
      'bridge',
      'castle',
      'desert',
      'empire',
      'forest',
      'garden',
      'horizon',
      'igloo',
      'jasmine',
      'kingdom',
      'lantern',
      'meadow',
      'nebula',
      'oasis',
      'phoenix',
      'quantum',
      'rainbow',
      'sunset',
      'thunder',
      'unicorn',
      'volcano',
      'whisper',
    ];

    final selectedWords = <String>[];
    for (var i = 0; i < wordCount; i++) {
      var word = words[_random.nextInt(words.length)];
      if (capitalize) {
        word = word[0].toUpperCase() + word.substring(1);
      }
      selectedWords.add(word);
    }

    return selectedWords.join(separator);
  }

  /// Evaluates the strength of a password.
  PasswordStrength evaluateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    var score = 0;

    // Length scoring
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (password.length >= 20) score++;

    // Character variety scoring
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) score++;

    // Penalize common patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score--; // Repeated chars
    if (RegExp(r'(012|123|234|345|456|567|678|789|890)').hasMatch(password))
      score--;
    if (RegExp(
      r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
      caseSensitive: false,
    ).hasMatch(password))
      score--;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 6) return PasswordStrength.good;
    if (score <= 8) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  String _buildCharacterPool(PasswordGeneratorOptions options) {
    final buffer = StringBuffer();

    if (options.includeUppercase) buffer.write(_uppercase);
    if (options.includeLowercase) buffer.write(_lowercase);
    if (options.includeDigits) buffer.write(_digits);
    if (options.includeSpecial) buffer.write(_special);

    var pool = buffer.toString();

    if (options.excludeAmbiguous) {
      pool = pool.split('').where((c) => !_ambiguous.contains(c)).join();
    }

    return pool;
  }

  String _generateWithRequirements(
    String pool,
    PasswordGeneratorOptions options,
  ) {
    final chars = <String>[];
    final poolChars = pool.split('');

    // Add minimum required characters first
    if (options.includeDigits && options.minimumDigits > 0) {
      final digitPool = _digits
          .split('')
          .where((c) => !options.excludeAmbiguous || !_ambiguous.contains(c))
          .toList();
      for (var i = 0; i < options.minimumDigits && i < options.length; i++) {
        chars.add(digitPool[_random.nextInt(digitPool.length)]);
      }
    }

    if (options.includeSpecial && options.minimumSpecial > 0) {
      final specialPool = _special.split('');
      for (
        var i = 0;
        i < options.minimumSpecial && chars.length < options.length;
        i++
      ) {
        chars.add(specialPool[_random.nextInt(specialPool.length)]);
      }
    }

    // Fill remaining length with random characters from pool
    while (chars.length < options.length) {
      chars.add(poolChars[_random.nextInt(poolChars.length)]);
    }

    // Shuffle to avoid predictable positions
    chars.shuffle(_random);

    return chars.join();
  }
}
