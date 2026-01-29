import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/password_generator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'cubit/generator_cubit.dart';
import 'cubit/generator_state.dart';
import 'options/generator_controls.dart';
import 'widgets/action_button.dart';
import 'widgets/strength_meter.dart';

/// Page for generating secure passwords.
class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneratorCubit(PasswordGenerator()),
      child: const _GeneratorView(),
    );
  }
}

class _GeneratorView extends StatelessWidget {
  const _GeneratorView();

  @override
  Widget build(BuildContext context) {
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
                      BlocBuilder<GeneratorCubit, GeneratorState>(
                        buildWhen: (previous, current) =>
                            previous.password != current.password,
                        builder: (context, state) {
                          return AnimatedSwitcher(
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
                              state.password,
                              key: ValueKey(state.password),
                              style: AppTypography.mono.copyWith(
                                fontSize: 18,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Strength meter
                      BlocBuilder<GeneratorCubit, GeneratorState>(
                        buildWhen: (previous, current) =>
                            previous.strength != current.strength,
                        builder: (context, state) {
                          return StrengthMeter(strength: state.strength);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BrandActionButton(
                            icon: Icons.refresh,
                            label: 'Generate',
                            onTap: () => context
                                .read<GeneratorCubit>()
                                .generatePassword(),
                          ),
                          const SizedBox(width: 16),
                          BrandActionButton(
                            icon: Icons.copy,
                            label: 'Copy',
                            onTap: () async {
                              await context
                                  .read<GeneratorCubit>()
                                  .copyToClipboard();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.accent,
                                          size: 18,
                                        ),
                                        SizedBox(width: 12),
                                        Text('Password copied'),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
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
            BlocBuilder<GeneratorCubit, GeneratorState>(
              buildWhen: (previous, current) =>
                  previous.length != current.length,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Length: ${state.length.round()}',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StyledSlider(
                      value: state.length,
                      min: 8,
                      max: 64,
                      onChanged: (value) =>
                          context.read<GeneratorCubit>().updateLength(value),
                    ),
                  ],
                );
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

            BlocBuilder<GeneratorCubit, GeneratorState>(
              builder: (context, state) {
                final cubit = context.read<GeneratorCubit>();
                return Column(
                  children: [
                    StyledSwitch(
                      title: 'Uppercase (A-Z)',
                      value: state.includeUppercase,
                      onChanged: cubit.toggleUppercase,
                    ),
                    StyledSwitch(
                      title: 'Lowercase (a-z)',
                      value: state.includeLowercase,
                      onChanged: cubit.toggleLowercase,
                    ),
                    StyledSwitch(
                      title: 'Digits (0-9)',
                      value: state.includeDigits,
                      onChanged: cubit.toggleDigits,
                    ),
                    StyledSwitch(
                      title: 'Special (!@#\$%...)',
                      value: state.includeSpecial,
                      onChanged: cubit.toggleSpecial,
                    ),
                    const Divider(height: 32),
                    StyledSwitch(
                      title: 'Exclude Ambiguous (0, O, l, 1, I)',
                      subtitle: 'Easier to read manually',
                      value: state.excludeAmbiguous,
                      onChanged: cubit.toggleExcludeAmbiguous,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
