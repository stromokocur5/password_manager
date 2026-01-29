import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/password_generator.dart';

/// Page for generating secure passwords.
class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final _generator = PasswordGenerator();
  String _generatedPassword = '';

  // Options
  double _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _digits = true;
  bool _special = true;
  bool _excludeAmbiguous = false;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    final options = PasswordGeneratorOptions(
      length: _length.round(),
      includeUppercase: _uppercase,
      includeLowercase: _lowercase,
      includeDigits: _digits,
      includeSpecial: _special,
      excludeAmbiguous: _excludeAmbiguous,
    );

    try {
      setState(() {
        _generatedPassword = _generator.generate(options);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _copyToClipboard() {
    if (_generatedPassword.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.yellow.shade700;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  String _getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _generator.evaluateStrength(_generatedPassword);
    final strengthColor = _getStrengthColor(strength);

    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Generated password display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SelectableText(
                      _generatedPassword,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontFamily: 'monospace', letterSpacing: 1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: strengthColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStrengthLabel(strength),
                            style: TextStyle(
                              color: strengthColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          icon: const Icon(Icons.refresh),
                          onPressed: _generatePassword,
                          tooltip: 'Generate new password',
                        ),
                        const SizedBox(width: 16),
                        IconButton.filled(
                          icon: const Icon(Icons.copy),
                          onPressed: _copyToClipboard,
                          tooltip: 'Copy to clipboard',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Length slider
            Text(
              'Length: ${_length.round()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _length,
              min: 8,
              max: 64,
              divisions: 56,
              label: _length.round().toString(),
              onChanged: (value) {
                setState(() => _length = value);
                _generatePassword();
              },
            ),
            const SizedBox(height: 16),

            // Character options
            Text(
              'Include Characters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Uppercase (A-Z)'),
              value: _uppercase,
              onChanged: (value) {
                setState(() => _uppercase = value);
                _generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Lowercase (a-z)'),
              value: _lowercase,
              onChanged: (value) {
                setState(() => _lowercase = value);
                _generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Digits (0-9)'),
              value: _digits,
              onChanged: (value) {
                setState(() => _digits = value);
                _generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Special (!@#\$%...)'),
              value: _special,
              onChanged: (value) {
                setState(() => _special = value);
                _generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Exclude Ambiguous (0, O, l, 1, I)'),
              value: _excludeAmbiguous,
              onChanged: (value) {
                setState(() => _excludeAmbiguous = value);
                _generatePassword();
              },
            ),
          ],
        ),
      ),
    );
  }
}
