import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth.dart';
import '../../../presentation/widgets/widgets.dart';
import '../../../presentation/theme/app_theme.dart';

/// Page for unlocking the vault with master password or biometric.
class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onUnlock() {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your master password');
      return;
    }
    setState(() => _errorMessage = null);
    HapticFeedback.mediumImpact();
    context.read<AuthBloc>().add(
      AuthUnlockWithPassword(_passwordController.text),
    );
  }

  void _onBiometricUnlock() {
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(const AuthUnlockWithBiometric());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.woodyBrown,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              setState(() => _errorMessage = state.message);
              HapticFeedback.heavyImpact();
            }
            if (state is AuthUnlocked) {
              HapticFeedback.mediumImpact();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Animated logo
                Center(child: const AnimatedLogo(size: 100, showShimmer: true))
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0, duration: 500.ms),

                const SizedBox(height: 32),

                // App title
                Text(
                      'SecureVault',
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

                const SizedBox(height: 8),

                Text(
                  'Enter your master password to unlock',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : Colors.white.withAlpha(200),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 48),

                // Password field container
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
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTypography.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Master Password',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.woodyBrown,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              errorText: _errorMessage,
                              errorStyle: TextStyle(color: AppColors.error),
                            ),
                            onSubmitted: (_) => _onUnlock(),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return AnimatedButton(
                                label: 'Unlock',
                                onPressed: state is AuthLoading
                                    ? null
                                    : _onUnlock,
                                isLoading: state is AuthLoading,
                                icon: Icons.lock_open,
                              );
                            },
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, duration: 500.ms),

                const SizedBox(height: 24),

                // Biometric option
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLocked &&
                        state.biometricAvailable &&
                        state.biometricEnabled) {
                      return Column(
                        children: [
                          Text(
                            'or',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : Colors.white.withAlpha(150),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _onBiometricUnlock,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.accent
                                      : Colors.white.withAlpha(100),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    color: isDark
                                        ? AppColors.accent
                                        : Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Biometric Unlock',
                                    style: AppTypography.button.copyWith(
                                      color: isDark
                                          ? AppColors.accent
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
