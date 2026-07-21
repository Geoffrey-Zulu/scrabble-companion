import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_notifier.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../../../core/widgets/toast_controller.dart';
import '../../rules/presentation/rules_sheet.dart';
import 'privacy_policy_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static final _whatsAppUri = Uri.parse('https://wa.me/260962572925');
  static final _feedbackEmailUri = Uri(
    scheme: 'mailto',
    path: 'zulugeoffrey034@gmail.com',
    queryParameters: {'subject': 'Scrabble Companion Feedback'},
  );

  Future<void> _openWhatsApp(WidgetRef ref) async {
    await ref.read(hapticsServiceProvider).selection();
    final opened = await launchUrl(
      _whatsAppUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      ref.read(toastProvider.notifier).show('Couldn’t open WhatsApp');
    }
  }

  Future<void> _sendFeedback(WidgetRef ref) async {
    await ref.read(hapticsServiceProvider).selection();
    final opened = await launchUrl(
      _feedbackEmailUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      ref.read(toastProvider.notifier).show('Couldn’t open mail app');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            14,
            AppSpacing.pageX,
            AppSpacing.scrollBottomClearance,
          ),
          physics: const ClampingScrollPhysics(),
          children: [
            const SizedBox(height: 12),
            Text('Settings', style: textTheme.headlineMedium),
            const SizedBox(height: 22),
            const _SectionLabel(label: 'Gameplay'),
            _SettingsGroup(
              children: [
                _ToggleSetting(
                  title: 'Haptics',
                  value: settings.hapticsEnabled,
                  onChanged: (value) {
                    notifier.setHapticsEnabled(enabled: value);
                    if (value) {
                      ref.read(hapticsServiceProvider).medium();
                    }
                  },
                ),
                _StackedSetting(
                  title: 'Dictionary',
                  child: _ChipRow(
                    options: DictionaryLocale.values,
                    selected: settings.dictionaryLocale,
                    labelBuilder: (locale) => switch (locale) {
                      DictionaryLocale.northAmerican => 'NWL',
                      DictionaryLocale.british => 'CSW',
                    },
                    onSelected: notifier.setDictionaryLocale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const _SectionLabel(label: 'Appearance'),
            _SettingsGroup(
              children: [
                _StackedSetting(
                  title: 'Theme',
                  child: _ThemeSegment(
                    selected: settings.themeMode,
                    onSelected: notifier.setThemeMode,
                  ),
                ),
                _StackedSetting(
                  title: 'Text size',
                  child: Row(
                    children: [
                      for (final option in TextScaleOption.values) ...[
                        Expanded(
                          child: _TextSizeChip(
                            option: option,
                            selected: settings.textScale == option,
                            onTap: () => notifier.setTextScale(option),
                          ),
                        ),
                        if (option != TextScaleOption.large)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const _SectionLabel(label: 'About'),
            _SettingsGroup(
              children: [
                _AboutLine(
                  title: 'Scrabble rules',
                  showChevron: true,
                  onTap: () {
                    ref.read(hapticsServiceProvider).selection();
                    showScrabbleRulesSheet(context);
                  },
                ),
                const _AboutLine(title: 'Version', value: '0.1.0'),
                _AboutLine(
                  title: 'Privacy Policy',
                  showChevron: true,
                  onTap: () {
                    ref.read(hapticsServiceProvider).selection();
                    showPrivacyPolicySheet(context);
                  },
                ),
                _AboutLine(
                  title: 'Send Feedback',
                  showChevron: true,
                  onTap: () => _sendFeedback(ref),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const _SectionLabel(label: 'Developer'),
            Material(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.md),
                onTap: () => _openWhatsApp(ref),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: colors.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Geoffrey Zulu',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mobile & web development',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.muted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enjoying the app? I’m available for freelance work - let’s build something.',
                                style: textTheme.bodySmall?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.chevron_right,
                            color: colors.faint,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            ScSecondaryButton(
              label: 'Reset all settings',
              expanded: true,
              onPressed: () {
                ref.read(hapticsServiceProvider).medium();
                notifier.resetAll();
                ref.read(toastProvider.notifier).show('Settings reset');
              },
            ),
            const SizedBox(height: 22),
            Text(
              'Scrabble Companion · Made with love',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: colors.faint),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: context.appColors.faint),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, thickness: 1, color: colors.line),
          ],
        ],
      ),
    );
  }
}

/// Title (and optional subtitle) on top; control(s) full-width below.
class _StackedSetting extends StatelessWidget {
  const _StackedSetting({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  const _ToggleSetting({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: textTheme.titleMedium)),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Compact About / link row - title + value/chevron only (no empty third column).
class _AboutLine extends StatelessWidget {
  const _AboutLine({
    required this.title,
    this.value,
    this.showChevron = false,
    this.onTap,
  });

  final String title;
  final String? value;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Expanded(child: Text(title, style: textTheme.titleMedium)),
          if (value != null)
            Text(
              value!,
              style: textTheme.bodyMedium?.copyWith(color: colors.muted),
            ),
          if (showChevron)
            Icon(Icons.chevron_right, color: colors.faint, size: 22),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }
    return InkWell(onTap: onTap, child: row);
  }
}

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          Semantics(
            button: true,
            selected: option == selected,
            label: labelBuilder(option),
            child: Material(
              color: option == selected ? colors.accentSoft : colors.field,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.minTouchTarget,
                    minWidth: 52,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: Text(
                        labelBuilder(option),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: option == selected
                              ? colors.accent
                              : colors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({required this.selected, required this.onSelected});

  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final mode in AppThemeMode.values)
              Expanded(
                child: Material(
                  color: mode == selected ? colors.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  elevation: mode == selected ? 1 : 0,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    onTap: () => onSelected(mode),
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: Text(
                          switch (mode) {
                            AppThemeMode.light => 'Light',
                            AppThemeMode.dark => 'Dark',
                            AppThemeMode.system => 'System',
                          },
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mode == selected ? colors.ink : colors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextSizeChip extends StatelessWidget {
  const _TextSizeChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final TextScaleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.accentSoft : colors.field,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 38,
          child: Center(
            child: Text(
              option.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? colors.accent : colors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
