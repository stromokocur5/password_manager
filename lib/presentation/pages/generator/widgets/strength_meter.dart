import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/password_generator.dart';
import '../../../theme/app_theme.dart';

class StrengthMeter extends StatefulWidget {
  final PasswordStrength strength;

  const StrengthMeter({super.key, required this.strength});

  @override
  State<StrengthMeter> createState() => _StrengthMeterState();
}

class _StrengthMeterState extends State<StrengthMeter> {
  int _changeCount = 0;

  @override
  void didUpdateWidget(StrengthMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strength != widget.strength) {
      _changeCount++;
    }
  }

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
            key: ValueKey('${widget.strength.name}_$_changeCount'),
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
    switch (widget.strength) {
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
