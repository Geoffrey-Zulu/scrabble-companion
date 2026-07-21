import 'package:flutter/material.dart';

import '../../../core/content/scrabble_rules.dart';
import '../../../core/design/design.dart';
import '../../../core/widgets/sc_bottom_sheet.dart';

/// Opens a scrollable, styled rules sheet.
Future<void> showScrabbleRulesSheet(BuildContext context) {
  return showScBottomSheet<void>(
    context: context,
    builder: (context) => const ScrabbleRulesSheet(),
  );
}

class ScrabbleRulesSheet extends StatelessWidget {
  const ScrabbleRulesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SizedBox(
      height: maxHeight,
      child: ScBottomSheetBody(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ScrabbleRules.title, style: textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        ScrabbleRules.subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.faint,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.close, color: colors.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 28),
                itemCount: ScrabbleRules.sections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final section = ScrabbleRules.sections[index];
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.field,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: colors.line),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: textTheme.titleMedium?.copyWith(
                              color: colors.accent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            section.body,
                            style: textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              color: colors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
