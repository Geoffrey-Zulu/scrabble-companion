import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_notifier.dart';

final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService(
    isEnabled: () => ref.read(settingsProvider).hapticsEnabled,
  );
});

/// Thin wrapper so features stay free of direct [HapticFeedback] calls.
class HapticsService {
  // ignore: prefer_initializing_formals
  HapticsService({required bool Function() isEnabled}) : _isEnabled = isEnabled;

  final bool Function() _isEnabled;

  Future<void> light() async {
    if (!_isEnabled()) {
      return;
    }
    await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (!_isEnabled()) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (!_isEnabled()) {
      return;
    }
    await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (!_isEnabled()) {
      return;
    }
    await HapticFeedback.selectionClick();
  }
}
