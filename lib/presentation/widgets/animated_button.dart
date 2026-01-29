import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

/// Animated primary button with Golden Fizz background and micro-interactions.
///
/// Features scale animation on press, loading state with spinner,
/// and optional haptic feedback.
class AnimatedButton extends StatefulWidget {
  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether button is in loading state.
  final bool isLoading;

  /// Whether to provide haptic feedback on press.
  final bool enableHaptics;

  /// Optional icon to show before label.
  final IconData? icon;

  /// Button variant: primary (Golden Fizz) or secondary (outlined).
  final AnimatedButtonVariant variant;

  /// Whether button takes full width.
  final bool expanded;

  const AnimatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.enableHaptics = true,
    this.icon,
    this.variant = AnimatedButtonVariant.primary,
    this.expanded = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

enum AnimatedButtonVariant { primary, secondary, danger }

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderColor) = _getColors();

    Widget buttonContent = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fgColor),
            ),
          ),
        ] else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: fgColor),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: AppTypography.button.copyWith(color: fgColor),
          ),
        ],
      ],
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? bgColor : bgColor.withAlpha(100),
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 2)
                : null,
            boxShadow: widget.onPressed != null && !widget.isLoading
                ? [
                    BoxShadow(
                      color: bgColor.withAlpha(40),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: buttonContent,
        ),
      ),
    );
  }

  (Color bg, Color fg, Color? border) _getColors() {
    switch (widget.variant) {
      case AnimatedButtonVariant.primary:
        return (AppColors.accent, AppColors.primary, null);
      case AnimatedButtonVariant.secondary:
        return (Colors.transparent, AppColors.primary, AppColors.primary);
      case AnimatedButtonVariant.danger:
        return (AppColors.error, Colors.white, null);
    }
  }
}

/// Small icon button with bounce animation.
class AnimatedIconButton extends StatelessWidget {
  /// Icon to display.
  final IconData icon;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Tooltip text.
  final String? tooltip;

  /// Icon color override.
  final Color? color;

  /// Whether to use filled style.
  final bool filled;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.onSurface;

    Widget button = filled
        ? IconButton.filled(
            icon: Icon(icon, color: iconColor),
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
            ),
          )
        : IconButton(
            icon: Icon(icon, color: iconColor),
            onPressed: onPressed,
          );

    if (onPressed != null) {
      button = button
          .animate(target: 1)
          .scaleXY(end: 1, duration: 100.ms)
          .then()
          .scaleXY(end: 1, duration: 100.ms);
    }

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
