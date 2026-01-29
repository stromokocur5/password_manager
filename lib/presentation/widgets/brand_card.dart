import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Flat design card with bold geometric shadows and optional category accent.
///
/// Features press animations and configurable left border accent color.
class BrandCard extends StatefulWidget {
  /// Child widget to display inside the card.
  final Widget child;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Optional left border accent color (for category indication).
  final Color? accentColor;

  /// Padding inside the card.
  final EdgeInsetsGeometry padding;

  /// Margin around the card.
  final EdgeInsetsGeometry margin;

  const BrandCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  State<BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<BrandCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadows = isDark ? AppShadows.cardDark : AppShadows.cardLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isPressed ? [] : shadows,
            border: widget.accentColor != null
                ? Border(left: BorderSide(color: widget.accentColor!, width: 4))
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Helper to get category color based on category ID.
Color getCategoryColor(String? categoryId) {
  switch (categoryId) {
    case 'login':
      return AppColors.categoryLogin;
    case 'card':
      return AppColors.categoryCard;
    case 'secure_note':
      return AppColors.categoryNote;
    case 'identity':
      return AppColors.categoryIdentity;
    default:
      return AppColors.primary;
  }
}
