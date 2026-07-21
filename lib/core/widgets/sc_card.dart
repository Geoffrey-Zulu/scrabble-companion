import 'package:flutter/material.dart';

import '../design/design.dart';

/// Bordered surface card used on Home and elsewhere.
class ScCard extends StatelessWidget {
  const ScCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.card),
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Padding(padding: padding, child: child);

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadii.cardBorder,
        border: Border.all(color: colors.line),
      ),
      child: content,
    );

    if (onTap == null) {
      return decorated;
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.cardBorder,
          child: decorated,
        ),
      ),
    );
  }
}
