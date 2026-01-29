import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/utils/password_generator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

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
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
            const SizedBox(width: 12),
            const Text('Password copied'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _generator.evaluateStrength(_generatedPassword);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Password display card
            BrandCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Password text with animation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: SelectableText(
                          _generatedPassword,
                          key: ValueKey(_generatedPassword),
                          style: AppTypography.mono.copyWith(
                            fontSize: 18,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Strength meter
                      _StrengthMeter(strength: strength),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionButton(
                            icon: Icons.refresh,
                            label: 'Generate',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _generatePassword();
                            },
                          ),
                          const SizedBox(width: 16),
                          _ActionButton(
                            icon: Icons.copy,
                            label: 'Copy',
                            onTap: _copyToClipboard,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.1, duration: 400.ms),
            const SizedBox(height: 32),

            // Length slider
            Text(
              'Length: ${_length.round()}',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _StyledSlider(
              value: _length,
              min: 8,
              max: 64,
              onChanged: (value) {
                setState(() => _length = value);
                _generatePassword();
              },
            ),
            const SizedBox(height: 24),

            // Character options
            Text(
              'Include Characters',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _StyledSwitch(
              title: 'Uppercase (A-Z)',
              value: _uppercase,
              onChanged: (value) {
                setState(() => _uppercase = value);
                _generatePassword();
              },
            ),
            _StyledSwitch(
              title: 'Lowercase (a-z)',
              value: _lowercase,
              onChanged: (value) {
                setState(() => _lowercase = value);
                _generatePassword();
              },
            ),
            _StyledSwitch(
              title: 'Digits (0-9)',
              value: _digits,
              onChanged: (value) {
                setState(() => _digits = value);
                _generatePassword();
              },
            ),
            _StyledSwitch(
              title: 'Special (!@#\$%...)',
              value: _special,
              onChanged: (value) {
                setState(() => _special = value);
                _generatePassword();
              },
            ),
            const Divider(height: 32),
            _StyledSwitch(
              title: 'Exclude Ambiguous (0, O, l, 1, I)',
              subtitle: 'Easier to read manually',
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

class _StrengthMeter extends StatelessWidget {
  final PasswordStrength strength;

  const _StrengthMeter({required this.strength});

  @override
  Widget build(BuildContext context) {
    final (color, label, segments) = _getStrengthInfo();

    return Column(
      children: [
        // Segmented bar
        Row(
          children: List.generate(5, (index) {
            final isActive = index < segments;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isActive ? color : color.withAlpha(30),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        // Label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(strength),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: AppTypography.label.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ).animate(target: 1).fadeIn(duration: 200.ms);
  }

  (Color, String, int) _getStrengthInfo() {
    switch (strength) {
      case PasswordStrength.weak:
        return (AppColors.strengthWeak, 'Weak', 1);
      case PasswordStrength.fair:
        return (AppColors.strengthFair, 'Fair', 2);
      case PasswordStrength.good:
        return (AppColors.strengthGood, 'Good', 3);
      case PasswordStrength.strong:
        return (AppColors.strengthStrong, 'Strong', 4);
      case PasswordStrength.veryStrong:
        return (AppColors.strengthVeryStrong, 'Very Strong', 5);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withAlpha(60),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.woodyBrown),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: AppColors.woodyBrown,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(target: 1)
        .scale(begin: const Offset(1, 1), end: const Offset(1, 1));
  }
}

class _StyledSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _StyledSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).round(),
        onChanged: onChanged,
      ),
    );
  }
}

class _StyledSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StyledSwitch({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
