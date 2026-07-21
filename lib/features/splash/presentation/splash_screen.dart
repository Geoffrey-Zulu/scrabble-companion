import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// Brand splash - real logo asset + delayed wordmark fade.
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.splashHold,
    );
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.82,
          end: 1,
        ).chain(CurveTween(curve: AppMotion.emphasized)),
        weight: 52,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 48),
    ]).animate(_controller);
    _logoOpacity = TweenSequence<double>([
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
          end: 0.7,
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
              const _SplashLogo(),
              const SizedBox(height: 22),
              Opacity(
                opacity: 0.7,
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
                  opacity: _logoOpacity.value,
                  child: Transform.scale(scale: _logoScale.value, child: child),
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
          child: const _SplashLogo(),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo.png',
      width: 112,
      height: 112,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Scrabble Companion',
    );
  }
}
