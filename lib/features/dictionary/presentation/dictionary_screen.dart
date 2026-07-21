import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/providers.dart';
import '../../../core/settings/settings_notifier.dart';
import '../../../core/widgets/sc_search_field.dart';
import '../application/dictionary_controller.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(dictionaryControllerProvider);
    final lexiconAsync = ref.watch(lexiconProvider);
    final notifier = ref.read(dictionaryControllerProvider.notifier);

    if (_controller.text != ui.query) {
      _controller.value = TextEditingValue(
        text: ui.query,
        selection: TextSelection.collapsed(offset: ui.query.length),
      );
    }

    final showSuggest = ui.query.isNotEmpty && ui.result?.word != ui.query;
    final showResult = ui.result != null && ui.result!.word == ui.query;
    final showEmpty = !showSuggest && !showResult;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageX,
              14,
              AppSpacing.pageX,
              AppSpacing.scrollBottomClearance,
            ),
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const SizedBox(height: 12),
              Text('Word Checker', style: textTheme.headlineMedium),
              const SizedBox(height: 18),
              ScSearchField(
                controller: _controller,
                onChanged: notifier.setQuery,
                onSubmitted: (_) => notifier.check(),
                onClear: () {
                  notifier.clearQuery();
                  _controller.clear();
                },
              ),
              const SizedBox(height: 8),
              lexiconAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Loading word list…',
                    style: textTheme.bodySmall?.copyWith(color: colors.muted),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Could not load dictionary.',
                    style: textTheme.bodySmall?.copyWith(color: colors.invalid),
                  ),
                ),
                data: (lexicon) {
                  final locale = ref.watch(
                    settingsProvider.select((s) => s.dictionaryLocale),
                  );
                  final label = locale.name == 'british' ? 'CSW21' : 'NWL2023';
                  return Text(
                    '${lexicon.wordCount} words · $label',
                    style: textTheme.bodySmall?.copyWith(color: colors.faint),
                  );
                },
              ),
              if (showSuggest) ...[
                const SizedBox(height: 8),
                _SuggestionTile(
                  word: ui.query,
                  hint: 'Check ↵',
                  accent: true,
                  onTap: () => notifier.check(ui.query),
                ),
                for (final word in ui.suggestions)
                  _SuggestionTile(
                    word: word,
                    onTap: () => notifier.check(word),
                  ),
              ],
              if (showResult) ...[
                const SizedBox(height: 12),
                _ResultCard(
                  result: ui.result!,
                  isFavorite: ui.favorites.contains(ui.result!.word),
                  onFavorite: notifier.toggleFavorite,
                ),
              ],
              if (showEmpty) ...[
                if (ui.recent.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'RECENT',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.faint,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: notifier.clearRecent,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  for (final recent in ui.recent)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        recent.word,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.02 * 17,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: recent.valid
                                  ? colors.valid
                                  : colors.invalid,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: colors.faint),
                        ],
                      ),
                      onTap: () => notifier.check(recent.word),
                    ),
                ] else
                  const _EmptyDictionary(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.word,
    required this.onTap,
    this.hint,
    this.accent = false,
  });

  final String word;
  final String? hint;
  final bool accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 17,
              color: accent ? colors.accent : colors.faint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                word,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.02 * 17,
                ),
              ),
            ),
            if (hint != null)
              Text(
                hint!,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colors.accent),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.isFavorite,
    required this.onFavorite,
  });

  final WordLookupResult result;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final valid = result.valid;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadii.result),
        border: Border.all(color: colors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: valid ? colors.validSoft : colors.invalidSoft,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: valid ? colors.valid : colors.invalid,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          valid ? 'Valid' : 'Invalid',
                          style: textTheme.labelLarge?.copyWith(
                            color: valid ? colors.valid : colors.invalid,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: isFavorite ? 'Remove favorite' : 'Favorite',
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? colors.accent : colors.muted,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy word',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: result.word));
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Copied')));
                    }
                  },
                  icon: Icon(Icons.ios_share_outlined, color: colors.muted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(result.word, style: textTheme.displaySmall),
            if (valid) ...[
              const SizedBox(height: 2),
              Text(
                '${result.points} points'
                '${result.partOfSpeech.isNotEmpty ? ' · ${result.partOfSpeech}' : ''}',
                style: textTheme.bodyMedium?.copyWith(color: colors.muted),
              ),
              if (result.definition.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(result.definition, style: textTheme.bodyLarge),
              ],
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Not found in the tournament word list. Double-check the spelling before you play it.',
                style: textTheme.bodyLarge?.copyWith(color: colors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyDictionary extends StatelessWidget {
  const _EmptyDictionary();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 30),
      child: Column(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              children: [
                Transform.rotate(
                  angle: -0.14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.field,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                Transform.rotate(
                  angle: 0.09,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.line, width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'Q',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: colors.accent,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 5,
                          child: Text(
                            '10',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.faint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Look up any word', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Check if a word is valid, see its meaning, and settle the table.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}
