import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

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
            Text('Word Checker', style: textTheme.headlineMedium),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.field,
                borderRadius: BorderRadius.circular(27),
              ),
              child: SizedBox(
                height: 54,
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    Icon(Icons.search, color: colors.muted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Check a word',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
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
                              border: Border.all(
                                color: colors.line,
                                width: 1.5,
                              ),
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
            ),
          ],
        ),
      ),
    );
  }
}
