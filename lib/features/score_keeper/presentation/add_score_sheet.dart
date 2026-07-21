import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/widgets/sc_bottom_sheet.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../domain/game_models.dart';

Future<({int points, String? word})?> showAddScoreSheet({
  required BuildContext context,
  required GamePlayer player,
  required int round,
  int? initialPoints,
  String? initialWord,
  String submitLabel = 'Add Score',
  String? titleOverride,
}) {
  return showScBottomSheet(
    context: context,
    builder: (context) => _AddScoreSheet(
      player: player,
      round: round,
      initialPoints: initialPoints,
      initialWord: initialWord,
      submitLabel: submitLabel,
      titleOverride: titleOverride,
    ),
  );
}

class _AddScoreSheet extends ConsumerStatefulWidget {
  const _AddScoreSheet({
    required this.player,
    required this.round,
    required this.submitLabel,
    this.initialPoints,
    this.initialWord,
    this.titleOverride,
  });

  final GamePlayer player;
  final int round;
  final int? initialPoints;
  final String? initialWord;
  final String submitLabel;
  final String? titleOverride;

  @override
  ConsumerState<_AddScoreSheet> createState() => _AddScoreSheetState();
}

class _AddScoreSheetState extends ConsumerState<_AddScoreSheet> {
  late String _digits;
  late final TextEditingController _word;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPoints;
    _digits = (initial == null || initial == 0) ? '' : '$initial';
    _word = TextEditingController(text: widget.initialWord ?? '');
  }

  @override
  void dispose() {
    _word.dispose();
    super.dispose();
  }

  int get _points {
    if (_digits.isEmpty) {
      return 0;
    }
    return int.tryParse(_digits) ?? 0;
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _tapKey(String key) {
    _dismissKeyboard();
    ref.read(hapticsServiceProvider).selection();
    setState(() {
      if (key == 'del') {
        if (_digits.isNotEmpty) {
          _digits = _digits.substring(0, _digits.length - 1);
        }
        return;
      }
      if (key == 'clear') {
        _digits = '';
        return;
      }
      if (_digits.length >= 3) {
        return;
      }
      if (_digits.isEmpty && key == '0') {
        _digits = '0';
        return;
      }
      if (_digits == '0') {
        _digits = key;
        return;
      }
      _digits += key;
    });
  }

  void _submit() {
    _dismissKeyboard();
    ref.read(hapticsServiceProvider).medium();
    final word = _word.text.trim().toUpperCase();
    Navigator.of(
      context,
    ).pop((points: _points, word: word.isEmpty ? null : word));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final title = widget.titleOverride ?? "${widget.player.name}'s turn";

    return ScBottomSheetBody(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: textTheme.headlineSmall),
          Text(
            'Round ${widget.round}',
            style: textTheme.bodySmall?.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _dismissKeyboard,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '$_points',
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _word,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                        LengthLimitingTextInputFormatter(15),
                        _UpperCaseFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Optional word',
                        filled: true,
                        fillColor: colors.field,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Keypad(onKey: _tapKey),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          ScPrimaryButton(
            label: widget.submitLabel,
            expanded: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['clear', '0', 'del'],
    ];
    return Column(
      children: [
        for (final row in keys)
          Row(
            children: [
              for (final key in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _Key(label: key, onTap: () => onKey(key)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final display = switch (label) {
      'del' => '⌫',
      'clear' => 'C',
      _ => label,
    };
    return Material(
      color: colors.field,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              display,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
