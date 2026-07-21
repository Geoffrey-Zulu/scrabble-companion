import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            20,
            AppSpacing.pageX,
            120,
          ),
          child: Column(
            children: [
              Text('Turn Timer', style: textTheme.headlineSmall),
              const SizedBox(height: 18),
              Text(
                'Standalone · start a game to track players by name',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: colors.faint),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 270,
                      height: 270,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 10,
                        backgroundColor: colors.line,
                        color: colors.ink,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '1:00',
                          style: textTheme.displayLarge?.copyWith(
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ready',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.faint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Full timer controls land in the next milestone.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: colors.muted),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
