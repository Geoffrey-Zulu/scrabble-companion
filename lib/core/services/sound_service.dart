import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import '../settings/settings_notifier.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = AudioSoundService();
  ref
    ..onDispose(service.dispose)
    ..listen<AppSettings>(settingsProvider, (previous, next) {
      service.configure(mode: next.soundMode, volume: next.soundVolume);
    });
  final settings = ref.read(settingsProvider);
  service.configure(mode: settings.soundMode, volume: settings.soundVolume);
  return service;
});

abstract class SoundService {
  void configure({required TimerSoundMode mode, required double volume});

  Future<void> playWarning();

  Future<void> playExpiry();

  Future<void> dispose();
}

/// Plays countdown warning / expiry assets from [assets/audio].
class AudioSoundService implements SoundService {
  AudioSoundService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  TimerSoundMode _mode = TimerSoundMode.soundA;
  double _volume = 0.8;

  @override
  void configure({required TimerSoundMode mode, required double volume}) {
    _mode = mode;
    _volume = volume.clamp(0, 1);
  }

  @override
  Future<void> playWarning() => _playCurrent();

  @override
  Future<void> playExpiry() => _playCurrent();

  Future<void> _playCurrent() async {
    if (_mode == TimerSoundMode.off) {
      return;
    }
    final asset = switch (_mode) {
      TimerSoundMode.soundA => 'audio/sound1.mp3',
      TimerSoundMode.soundB => 'audio/sound2.mp3',
      TimerSoundMode.off => null,
    };
    if (asset == null) {
      return;
    }
    await _player.stop();
    await _player.setVolume(_volume);
    await _player.play(AssetSource(asset));
  }

  @override
  Future<void> dispose() => _player.dispose();
}

/// Test double that never touches platform audio.
class SilentSoundService implements SoundService {
  @override
  void configure({required TimerSoundMode mode, required double volume}) {}

  @override
  Future<void> playWarning() async {}

  @override
  Future<void> playExpiry() async {}

  @override
  Future<void> dispose() async {}
}
