import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/design.dart';
import 'toast_controller.dart';

/// Floating toast above the bottom navigation.
class ScToastHost extends ConsumerStatefulWidget {
  const ScToastHost({super.key});

  @override
  ConsumerState<ScToastHost> createState() => _ScToastHostState();
}

class _ScToastHostState extends ConsumerState<ScToastHost> {
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(toastProvider, (previous, next) {
      _hideTimer?.cancel();
      if (next != null) {
        _hideTimer = Timer(AppMotion.toast, () {
          ref.read(toastProvider.notifier).clear();
        });
      }
    });

    final message = ref.watch(toastProvider);
    final colors = context.appColors;
    final bottom =
        MediaQuery.paddingOf(context).bottom + AppSpacing.navHeight + 20;

    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: AppMotion.fadeUp,
        switchInCurve: AppMotion.standard,
        child: message == null
            ? const SizedBox.shrink()
            : Align(
                key: ValueKey(message),
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottom),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.ink,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      child: Text(
                        message,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: colors.bg),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
