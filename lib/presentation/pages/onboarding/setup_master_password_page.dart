import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

/// Page for setting up the master password on first launch.
class SetupMasterPasswordPage extends StatefulWidget {
  const SetupMasterPasswordPage({super.key});

  @override
  State<SetupMasterPasswordPage> createState() =>
      _SetupMasterPasswordPageState();
}

class _SetupMasterPasswordPageState extends State<SetupMasterPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSetup() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      context.read<AuthBloc>().add(AuthSetupVault(_passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.woodyBrown,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Step indicator
                _StepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 2,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 32),

                // Animated logo
                Center(child: const AnimatedLogo(size: 100, showShimmer: true))
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 32),

                // Title
                Text(
                      'Create Master Password',
                      style: AppTypography.headline1.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms),

                const SizedBox(height: 12),

                Text(
                  'Your master password is the only key to your vault. Make it strong and memorable.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : Colors.white.withAlpha(200),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 40),

                // Form container
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 60 : 30),
                            offset: const Offset(0, 8),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTypography.bodyMedium,
                            decoration: InputDecoration(
                              labelText: 'Master Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            onChanged: (_) {
                              if (_currentStep == 0) {
                                setState(() => _currentStep = 1);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length <
                                  AppConstants.minMasterPasswordLength) {
                                return 'Password must be at least ${AppConstants.minMasterPasswordLength} characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm password field
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            style: AppTypography.bodyMedium,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Create button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return AnimatedButton(
                                label: 'Create Vault',
                                icon: Icons.shield,
                                isLoading: state is AuthLoading,
                                onPressed: state is AuthLoading
                                    ? null
                                    : _onSetup,
                              );
                            },
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms),

                const SizedBox(height: 24),

                // Warning banner
                _WarningBanner().animate().fadeIn(
                  delay: 600.ms,
                  duration: 400.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isLast = index == totalSteps - 1;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTypography.button.copyWith(
                    color: isActive ? AppColors.woodyBrown : Colors.white,
                  ),
                ),
              ),
            ),
            if (!isLast)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 3,
                color: isActive && currentStep > index
                    ? AppColors.accent
                    : Colors.white.withAlpha(50),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
          ],
        );
      }),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withAlpha(20)
            : Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDark
              ? AppColors.warning.withAlpha(50)
              : Colors.white.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Icon(
                Icons.warning_amber,
                color: isDark ? AppColors.warning : Colors.white,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'There is no way to recover your master password if you forget it.',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.warning : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
