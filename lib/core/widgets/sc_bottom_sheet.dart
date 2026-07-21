import 'package:flutter/material.dart';

import '../design/design.dart';

/// Modal bottom sheet chrome matching the prototype (grabber + card surface).
Future<T?> showScBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  final colors = context.appColors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: colors.card,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18),
            Container(
              width: 38,
              height: 5,
              decoration: BoxDecoration(
                color: colors.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(child: builder(context)),
          ],
        ),
      );
    },
  );
}

/// Content wrapper for sheets that already include the grabber via
/// [showScBottomSheet].
class ScBottomSheetBody extends StatelessWidget {
  const ScBottomSheetBody({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 30),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}
