import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

/// Animated shield logo with SecureVault branding.
///
/// Features a pulse animation on load and optional continuous shimmer effect.
class AnimatedLogo extends StatelessWidget {
  /// Size of the logo container.
  final double size;

  /// Whether to show the continuous shimmer effect.
  final bool showShimmer;

  /// Whether to animate on first appearance.
  final bool animateOnLoad;

  const AnimatedLogo({
    super.key,
    this.size = 100,
    this.showShimmer = false,
    this.animateOnLoad = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.woodyBrown,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.woodyBrown.withAlpha(60),
            offset: Offset(0, size * 0.08),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield icon
          Icon(Icons.shield, size: size * 0.6, color: AppColors.goldenFizz),
          // Lock overlay
          Positioned(
            bottom: size * 0.28,
            child: Icon(
              Icons.lock,
              size: size * 0.24,
              color: AppColors.woodyBrown,
            ),
          ),
        ],
      ),
    );

    if (animateOnLoad) {
      logo = logo
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 500.ms,
            curve: Curves.elasticOut,
          );
    }

    if (showShimmer) {
      logo = logo
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2000.ms,
            color: AppColors.goldenFizz.withAlpha(50),
          );
    }

    return logo;
  }
}

/// Small logo variant for app bars and headers.
class AnimatedLogoSmall extends StatelessWidget {
  const AnimatedLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.goldenFizz,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.shield, size: 20, color: AppColors.woodyBrown),
    );
  }
}
