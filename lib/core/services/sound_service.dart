import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = JustAudioSoundService();
  // Warm the player as soon as anything watches this provider (Timer screen).
  service.warmUp();
  ref.onDispose(service.dispose);
  return service;
});

abstract class SoundService {
  Future<void> warmUp();

  Future<void> playWarning();

  Future<void> playExpiry();

  /// Pause mid-clip (timer pause) — [resumePlayback] continues from here.
  Future<void> pausePlayback();

  /// Continue a paused warning clip without restarting.
  Future<void> resumePlayback();

  /// Hard stop + rewind (reset / new duration / new turn).
  Future<void> stop();

  Future<void> dispose();
}

/// Always plays [assets/audio/sound1.mp3] (≈13s). Warning starts at the
/// hard-coded 10s window in [TimerNotifier] — clip may overrun past zero.
class JustAudioSoundService implements SoundService {
  JustAudioSoundService({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  static const assetPath = 'assets/audio/sound1.mp3';

  final AudioPlayer _player;
  Future<void> _chain = Future<void>.value();
  var _ready = false;
  var _generation = 0;

  @override
  Future<void> warmUp() => _enqueue(() => _ensureReady());

  Future<void> _ensureReady() async {
    if (_ready) {
      return;
    }
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ),
    );
    await session.setActive(true);
    await _player.setAudioSource(AudioSource.asset(assetPath));
    await _player.setVolume(1);
    _ready = true;
  }

  @override
  Future<void> playWarning() => _enqueuePlay();

  @override
  Future<void> playExpiry() async {}

  @override
  Future<void> pausePlayback() async {
    try {
      if (_player.playing) {
        await _player.pause();
      }
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService pause failed: $error\n$stackTrace');
    }
  }

  @override
  Future<void> resumePlayback() async {
    try {
      if (_player.playing) {
        return;
      }
      // Only continue a mid-clip pause — never restart a finished/stopped clip.
      if (_player.processingState == ProcessingState.completed ||
          _player.processingState == ProcessingState.idle ||
          _player.position <= Duration.zero) {
        return;
      }
      final session = await AudioSession.instance;
      await session.setActive(true);
      await _player.play();
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService resume failed: $error\n$stackTrace');
    }
  }

  @override
  Future<void> stop() async {
    _generation++;
    try {
      await _player.stop();
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService stop failed: $error\n$stackTrace');
    }
    _chain = Future<void>.value();
  }

  Future<void> _enqueuePlay() => _enqueue(_playBody);

  Future<void> _enqueue(Future<void> Function() work) {
    final result = _chain.then((_) => work());
    _chain = result.catchError((Object error, StackTrace stackTrace) {
      debugPrint('SoundService failed: $error\n$stackTrace');
    });
    return result;
  }

  Future<void> _playBody() async {
    final generation = _generation;
    try {
      await _ensureReady();
      if (generation != _generation) {
        return;
      }
      final session = await AudioSession.instance;
      await session.setActive(true);
      if (generation != _generation) {
        return;
      }
      await _player.stop();
      await _player.seek(Duration.zero);
      if (generation != _generation) {
        return;
      }
      unawaited(_player.play());
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService play failed: $error\n$stackTrace');
      _ready = false;
    }
  }

  @override
  Future<void> dispose() => _player.dispose();
}

class RecordingSoundService implements SoundService {
  final List<String> events = [];

  @override
  Future<void> warmUp() async {}

  @override
  Future<void> playWarning() async {
    events.add('warning');
  }

  @override
  Future<void> playExpiry() async {
    events.add('expiry');
  }

  @override
  Future<void> pausePlayback() async {
    events.add('pause');
  }

  @override
  Future<void> resumePlayback() async {
    events.add('resume');
  }

  @override
  Future<void> stop() async {
    events.add('stop');
  }

  @override
  Future<void> dispose() async {}
}

class SilentSoundService implements SoundService {
  @override
  Future<void> warmUp() async {}

  @override
  Future<void> playWarning() async {}

  @override
  Future<void> playExpiry() async {}

  @override
  Future<void> pausePlayback() async {}

  @override
  Future<void> resumePlayback() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
