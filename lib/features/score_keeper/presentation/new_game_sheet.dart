import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/widgets/sc_bottom_sheet.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../application/game_notifier.dart';

Future<bool> showNewGameSheet(BuildContext context, WidgetRef ref) async {
  final started = await showScBottomSheet<bool>(
    context: context,
    builder: (context) => const NewGameSheet(),
  );
  return started ?? false;
}

/// New-game player setup (2–6 names). Public for widget tests.
class NewGameSheet extends ConsumerStatefulWidget {
  const NewGameSheet({super.key});

  @override
  ConsumerState<NewGameSheet> createState() => _NewGameSheetState();
}

class _NewGameSheetState extends ConsumerState<NewGameSheet> {
  final _controllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  final _focusNodes = <FocusNode>[FocusNode(), FocusNode()];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _addPlayer() async {
    if (_controllers.length >= 6) {
      return;
    }
    final controller = TextEditingController();
    final focus = FocusNode();
    setState(() {
      _controllers.add(controller);
      _focusNodes.add(focus);
    });
    await ref.read(hapticsServiceProvider).selection();
    // Focus the new field after the frame that inserts it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      focus.requestFocus();
    });
  }

  void _removeAt(int index) {
    if (_controllers.length <= 2) {
      return;
    }
    setState(() {
      _controllers.removeAt(index).dispose();
      _focusNodes.removeAt(index).dispose();
    });
    ref.read(hapticsServiceProvider).selection();
  }

  Future<void> _start() async {
    await ref.read(hapticsServiceProvider).medium();
    final names = _controllers.map((c) => c.text).toList();
    await ref.read(gameProvider.notifier).startGame(names);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _dismissKeyboard,
      child: SizedBox(
        height: maxHeight - viewInsets.clamp(0, maxHeight * 0.4),
        child: ScBottomSheetBody(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Game', style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${_controllers.length} players · 2–6',
                style: textTheme.bodySmall?.copyWith(color: colors.muted),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _controllers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: ValueKey('player-field-$i'),
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            textCapitalization: TextCapitalization.words,
                            textInputAction: i == _controllers.length - 1
                                ? TextInputAction.done
                                : TextInputAction.next,
                            onSubmitted: (_) {
                              if (i < _focusNodes.length - 1) {
                                _focusNodes[i + 1].requestFocus();
                              } else {
                                _dismissKeyboard();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Player ${i + 1}',
                              filled: true,
                              fillColor: colors.field,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(18),
                            ],
                          ),
                        ),
                        if (_controllers.length > 2) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Remove player',
                            onPressed: () => _removeAt(i),
                            icon: Icon(Icons.close, color: colors.muted),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (_controllers.length < 6)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('add-player'),
                    onPressed: _addPlayer,
                    icon: const Icon(Icons.add),
                    label: const Text('Add player'),
                  ),
                ),
              const SizedBox(height: 8),
              ScPrimaryButton(
                label: 'Start Game',
                expanded: true,
                onPressed: _start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
