import 'package:flutter/material.dart';

import '../design/design.dart';

class ScPrimaryButton extends StatelessWidget {
  const ScPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: colors.onAccent),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          disabledBackgroundColor: colors.field,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.cta),
          ),
          elevation: 0,
          shadowColor: colors.accent.withValues(alpha: 0.45),
        ),
        child: child,
      ),
    );
  }
}

class ScSecondaryButton extends StatelessWidget {
  const ScSecondaryButton({
    required this.label,
    required this.onPressed,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.field,
          foregroundColor: colors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.cta),
          ),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }
}

class ScIconButton extends StatelessWidget {
  const ScIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 64,
    this.iconSize = 24,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dimension = size < AppSpacing.minTouchTarget
        ? AppSpacing.minTouchTarget
        : size;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: backgroundColor ?? colors.field,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: dimension,
            height: dimension,
            child: Icon(
              icon,
              size: iconSize,
              color: foregroundColor ?? colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
