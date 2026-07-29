import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../features/timer/application/timer_notifier.dart';

/// Keeps the screen awake while the turn timer is running.
final timerWakeLockProvider = Provider<void>((ref) {
  ref
    ..listen<TurnTimerState>(timerProvider, (previous, next) {
      final shouldLock = next.isRunning;
      final wasLocked = previous?.isRunning ?? false;
      if (shouldLock == wasLocked) {
        return;
      }
      if (shouldLock) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    })
    ..onDispose(WakelockPlus.disable);
});
