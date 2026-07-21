import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// Brand splash with tile pop + delayed wordmark fade.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tileScale;
  late final Animation<double> _tileOpacity;
  late final Animation<double> _titleOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.splashHold,
    );
    _tileScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.55,
          end: 1,
        ).chain(CurveTween(curve: AppMotion.emphasized)),
        weight: 52,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 48),
    ]).animate(_controller);
    _tileOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 60),
    ]).animate(_controller);
    _titleOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 25),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 0.55,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 75,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (reduceMotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFinished();
        }
      });
      return ColoredBox(
        color: colors.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SplashTile(colors: colors),
              const SizedBox(height: 22),
              Opacity(
                opacity: 0.55,
                child: Text(
                  'Scrabble Companion',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.ink,
                    letterSpacing: 0.01 * 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: colors.bg,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: _tileOpacity.value,
                  child: Transform.scale(scale: _tileScale.value, child: child),
                ),
                const SizedBox(height: 22),
                Opacity(
                  opacity: _titleOpacity.value,
                  child: Text(
                    'Scrabble Companion',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.ink,
                      letterSpacing: 0.01 * 18,
                    ),
                  ),
                ),
              ],
            );
          },
          child: _SplashTile(colors: colors),
        ),
      ),
    );
  }
}

class _SplashTile extends StatelessWidget {
  const _SplashTile({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.45),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          children: [
            Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              right: 11,
              bottom: 8,
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
