import 'package:flutter/material.dart';

/// Design-system colors from the Claude Design handoff.
///
/// Access via `Theme.of(context).extension<AppColors>()!` or
/// `context.appColors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.desk,
    required this.bg,
    required this.card,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.valid,
    required this.validSoft,
    required this.invalid,
    required this.invalidSoft,
    required this.field,
    required this.onAccent,
  });

  final Color desk;
  final Color bg;
  final Color card;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color line;
  final Color accent;
  final Color accentSoft;
  final Color valid;
  final Color validSoft;
  final Color invalid;
  final Color invalidSoft;
  final Color field;
  final Color onAccent;

  static const AppColors light = AppColors(
    desk: Color(0xFFE7E4DB),
    bg: Color(0xFFFAF9F5),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF141413),
    muted: Color(0xFF8C8A80),
    faint: Color(0xFFB0AEA5),
    line: Color(0xFFE8E6DC),
    accent: Color(0xFFD97757),
    accentSoft: Color(0xFFF5E4DB),
    valid: Color(0xFF4F8A6D),
    validSoft: Color(0xFFE6EFE9),
    invalid: Color(0xFFB4534B),
    invalidSoft: Color(0xFFF3E4E2),
    field: Color(0xFFF1EFE8),
    onAccent: Color(0xFFFFFFFF),
  );

  static const AppColors dark = AppColors(
    desk: Color(0xFF0E0D0B),
    bg: Color(0xFF181713),
    card: Color(0xFF221F1B),
    ink: Color(0xFFF4F2EB),
    muted: Color(0xFF918E84),
    faint: Color(0xFF605D55),
    line: Color(0xFF2E2B26),
    accent: Color(0xFFE28A6C),
    accentSoft: Color(0xFF3A2A22),
    valid: Color(0xFF7BB093),
    validSoft: Color(0xFF22302A),
    invalid: Color(0xFFD07E74),
    invalidSoft: Color(0xFF332320),
    field: Color(0xFF2A2723),
    onAccent: Color(0xFFFFFFFF),
  );

  @override
  AppColors copyWith({
    Color? desk,
    Color? bg,
    Color? card,
    Color? ink,
    Color? muted,
    Color? faint,
    Color? line,
    Color? accent,
    Color? accentSoft,
    Color? valid,
    Color? validSoft,
    Color? invalid,
    Color? invalidSoft,
    Color? field,
    Color? onAccent,
  }) {
    return AppColors(
      desk: desk ?? this.desk,
      bg: bg ?? this.bg,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      valid: valid ?? this.valid,
      validSoft: validSoft ?? this.validSoft,
      invalid: invalid ?? this.invalid,
      invalidSoft: invalidSoft ?? this.invalidSoft,
      field: field ?? this.field,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      desk: Color.lerp(desk, other.desk, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      valid: Color.lerp(valid, other.valid, t)!,
      validSoft: Color.lerp(validSoft, other.validSoft, t)!,
      invalid: Color.lerp(invalid, other.invalid, t)!,
      invalidSoft: Color.lerp(invalidSoft, other.invalidSoft, t)!,
      field: Color.lerp(field, other.field, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
