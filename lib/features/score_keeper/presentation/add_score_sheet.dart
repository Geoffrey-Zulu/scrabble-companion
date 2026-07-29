import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/providers.dart';
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
  late bool _negative;
  late final TextEditingController _word;
  bool? _wordValid;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPoints;
    if (initial == null || initial == 0) {
      _digits = '';
      _negative = false;
    } else {
      _negative = initial < 0;
      _digits = '${initial.abs()}';
    }
    _word = TextEditingController(text: widget.initialWord ?? '')
      ..addListener(_onWordChanged);
  }

  @override
  void dispose() {
    _word
      ..removeListener(_onWordChanged)
      ..dispose();
    super.dispose();
  }

  void _onWordChanged() {
    setState(() => _wordValid = null);
  }

  int get _magnitude {
    if (_digits.isEmpty) {
      return 0;
    }
    return int.tryParse(_digits) ?? 0;
  }

  int get _signedPoints {
    final mag = _magnitude.clamp(0, 999);
    return _negative ? -mag : mag;
  }

  String get _displayPoints {
    if (_magnitude == 0) {
      return _negative ? '-0' : '0';
    }
    return _negative ? '-$_magnitude' : '$_magnitude';
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Keyboard open → collapse it. Otherwise dismiss the sheet.
  void _tapEmpty() {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _setSign({required bool negative}) {
    _dismissKeyboard();
    ref.read(hapticsServiceProvider).selection();
    setState(() => _negative = negative);
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

  Future<void> _checkWord() async {
    _dismissKeyboard();
    final word = _word.text.trim().toUpperCase();
    if (word.isEmpty) {
      return;
    }
    final lexicon = ref.read(lexiconProvider).asData?.value;
    if (lexicon == null) {
      return;
    }
    final valid = lexicon.isValid(word);
    if (valid) {
      await ref.read(hapticsServiceProvider).light();
    } else {
      await ref.read(hapticsServiceProvider).medium();
    }
    if (!mounted) {
      return;
    }
    setState(() => _wordValid = valid);
  }

  void _submit() {
    _dismissKeyboard();
    ref.read(hapticsServiceProvider).medium();
    final word = _word.text.trim().toUpperCase();
    Navigator.of(
      context,
    ).pop((points: _signedPoints, word: word.isEmpty ? null : word));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final title = widget.titleOverride ?? "${widget.player.name}'s turn";
    final lexiconReady = ref.watch(lexiconProvider).hasValue;

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
              onTap: _tapEmpty,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _displayPoints,
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                        color: _negative && _magnitude > 0
                            ? colors.invalid
                            : colors.ink,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _SignChip(
                            label: '+ Add',
                            selected: !_negative,
                            onTap: () => _setSign(negative: false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SignChip(
                            label: '− Subtract',
                            selected: _negative,
                            onTap: () => _setSign(negative: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                        suffixIcon: IconButton(
                          tooltip: 'Check word',
                          onPressed:
                              lexiconReady && _word.text.trim().isNotEmpty
                              ? _checkWord
                              : null,
                          icon: Icon(
                            Icons.spellcheck_rounded,
                            color: _wordValid == null
                                ? colors.muted
                                : (_wordValid! ? colors.valid : colors.invalid),
                          ),
                        ),
                      ),
                    ),
                    if (_wordValid != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _wordValid!
                            ? '${_word.text.trim().toUpperCase()} is valid'
                            : '${_word.text.trim().toUpperCase()} is not valid',
                        style: textTheme.bodySmall?.copyWith(
                          color: _wordValid! ? colors.valid : colors.invalid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _SignChip extends StatelessWidget {
  const _SignChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
          height: 40,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? colors.accent : colors.ink,
              ),
            ),
          ),
        ),
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
