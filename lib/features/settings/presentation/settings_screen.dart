import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_notifier.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../../../core/widgets/toast_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
            120,
          ),
          children: [
            const SizedBox(height: 12),
            Text('Settings', style: textTheme.headlineMedium),
            const SizedBox(height: 22),
            const _SectionLabel(label: 'Gameplay'),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  title: 'Warning at',
                  subtitle: 'Accent glows in the final seconds',
                  trailing: _ChipRow(
                    options: const [5, 10, 20, 30],
                    selected: settings.warnAtSeconds,
                    labelBuilder: (v) => '${v}s',
                    onSelected: notifier.setWarnAtSeconds,
                  ),
                ),
                _SettingsRow(
                  title: 'Timer sound',
                  trailing: _ChipRow(
                    options: TimerSoundMode.values,
                    selected: settings.soundMode,
                    labelBuilder: (mode) => switch (mode) {
                      TimerSoundMode.off => 'Off',
                      TimerSoundMode.soundA => 'A',
                      TimerSoundMode.soundB => 'B',
                    },
                    onSelected: notifier.setSoundMode,
                  ),
                ),
                _SettingsRow(
                  title: 'Haptics',
                  trailing: Switch.adaptive(
                    value: settings.hapticsEnabled,
                    onChanged: (value) {
                      notifier.setHapticsEnabled(enabled: value);
                    },
                  ),
                ),
                _SettingsRow(
                  title: 'Dictionary',
                  trailing: _ChipRow(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme', style: textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _ThemeSegment(
                        selected: settings.themeMode,
                        onSelected: notifier.setThemeMode,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Text size', style: textTheme.titleMedium),
                          const Spacer(),
                          Text(
                            settings.textScale.label,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
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
                              const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const _SectionLabel(label: 'About'),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  title: 'Version',
                  trailing: Text(
                    '0.1.0',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.muted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                _SettingsRow(
                  title: 'Privacy Policy',
                  trailing: Icon(Icons.chevron_right, color: colors.faint),
                  onTap: () {
                    ref
                        .read(toastProvider.notifier)
                        .show('Privacy policy coming soon');
                  },
                ),
                _SettingsRow(
                  title: 'Send Feedback',
                  trailing: Icon(Icons.chevron_right, color: colors.faint),
                  onTap: () {
                    ref
                        .read(toastProvider.notifier)
                        .show('Feedback link coming soon');
                  },
                ),
              ],
            ),
            const SizedBox(height: 26),
            const _SectionLabel(label: 'Developer'),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: colors.line),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.accentSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: Center(
                              child: Text(
                                'GZ',
                                style: TextStyle(
                                  color: colors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Geoffrey Zulu',
                                style: textTheme.titleMedium,
                              ),
                              Text(
                                'Mobile & web development',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Enjoying the app? I’m available for freelance work — let’s build something.',
                      style: textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            ScSecondaryButton(
              label: 'Reset all settings',
              expanded: true,
              onPressed: () {
                notifier.resetAll();
                ref.read(toastProvider.notifier).show('Settings reset');
              },
            ),
            const SizedBox(height: 22),
            Text(
              'Scrabble Companion · Made with care',
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.faint,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
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
      spacing: 6,
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
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
              'A',
              style: TextStyle(
                fontSize: 14 * option.factor,
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
