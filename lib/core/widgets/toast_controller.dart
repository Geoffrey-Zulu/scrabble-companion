import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ephemeral toast messages shown above the bottom nav.
final toastProvider = NotifierProvider<ToastNotifier, String?>(
  ToastNotifier.new,
);

class ToastNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void show(String message) {
    state = message;
  }

  void clear() {
    state = null;
  }
}
