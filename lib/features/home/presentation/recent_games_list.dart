import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// Summary row for a finished game on Home.
class RecentGameSummary {
  const RecentGameSummary({
    required this.id,
    required this.winner,
    required this.date,
    required this.durationLabel,
    required this.score,
  });

  final String id;
  final String winner;
  final String date;
  final String durationLabel;
  final int score;
}

/// Viewport that shows up to [visibleCount] recent games; scroll for the rest.
/// Swipe a row right to reveal delete and remove it.
class RecentGamesList extends StatefulWidget {
  const RecentGamesList({
    required this.games,
    this.onGameTap,
    this.onGameDeleted,
    this.visibleCount = 4,
    super.key,
  });

  final List<RecentGameSummary> games;
  final ValueChanged<RecentGameSummary>? onGameTap;
  final ValueChanged<RecentGameSummary>? onGameDeleted;

  /// How many rows fit in the home viewport before scrolling.
  final int visibleCount;

  static const double rowExtent = 64;
  static const double deleteReveal = 84;

  @override
  State<RecentGamesList> createState() => _RecentGamesListState();
}

class _RecentGamesListState extends State<RecentGamesList> {
  late List<RecentGameSummary> _games;

  @override
  void initState() {
    super.initState();
    _games = List<RecentGameSummary>.of(widget.games);
  }

  @override
  void didUpdateWidget(covariant RecentGamesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.games, widget.games)) {
      _games = List<RecentGameSummary>.of(widget.games);
    }
  }

  void _delete(RecentGameSummary game) {
    setState(() {
      _games.removeWhere((g) => g.id == game.id);
    });
    widget.onGameDeleted?.call(game);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    if (_games.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.line, width: 1.5),
              ),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.ssid_chart_outlined,
                  color: colors.faint,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No games yet',
              style: textTheme.bodyMedium?.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 2),
            Text(
              'Finished games will appear here.',
              style: textTheme.bodySmall?.copyWith(color: colors.faint),
            ),
          ],
        ),
      );
    }

    final visibleRows = math.min(widget.visibleCount, _games.length);
    final height = RecentGamesList.rowExtent * visibleRows;
    final canScroll = _games.length > widget.visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: AppRadii.cardBorder,
              border: Border.all(color: colors.line),
            ),
            child: ClipRRect(
              borderRadius: AppRadii.cardBorder,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemExtent: RecentGamesList.rowExtent,
                itemCount: _games.length,
                physics: canScroll
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final game = _games[index];
                  final isLast = index == _games.length - 1;
                  return _SwipeToDeleteRow(
                    key: ValueKey(game.id),
                    game: game,
                    showDivider: !isLast,
                    onTap: widget.onGameTap == null
                        ? null
                        : () => widget.onGameTap!(game),
                    onDeleted: () => _delete(game),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          canScroll
              ? 'Scroll for earlier games · swipe right to delete'
              : 'Swipe right to delete',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: colors.faint,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SwipeToDeleteRow extends StatefulWidget {
  const _SwipeToDeleteRow({
    required this.game,
    required this.onDeleted,
    this.onTap,
    this.showDivider = true,
    super.key,
  });

  final RecentGameSummary game;
  final VoidCallback onDeleted;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  State<_SwipeToDeleteRow> createState() => _SwipeToDeleteRowState();
}

class _SwipeToDeleteRowState extends State<_SwipeToDeleteRow> {
  double _dx = 0;
  var _dragging = false;

  static const _maxReveal = RecentGamesList.deleteReveal;

  void _onDragStart(DragStartDetails details) {
    _dragging = true;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging) {
      return;
    }
    setState(() {
      _dx = (_dx + details.delta.dx).clamp(0, _maxReveal + 16);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _dragging = false;
    final flingDelete =
        details.primaryVelocity != null && details.primaryVelocity! > 900;
    if (flingDelete || _dx > _maxReveal + 12) {
      widget.onDeleted();
      return;
    }
    final shouldOpen = _dx > _maxReveal * 0.45;
    setState(() {
      _dx = shouldOpen ? _maxReveal : 0;
    });
  }

  void _close() {
    setState(() => _dx = 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final open = _dx >= _maxReveal * 0.9;

    return SizedBox(
      height: RecentGamesList.rowExtent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: colors.invalid,
                child: InkWell(
                  onTap: open ? widget.onDeleted : null,
                  child: SizedBox(
                    width: _maxReveal,
                    height: RecentGamesList.rowExtent,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: colors.onAccent,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: _dragging
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dx, 0, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onTap: () {
                if (_dx > 0) {
                  _close();
                  return;
                }
                widget.onTap?.call();
              },
              child: RecentGameRow(
                game: widget.game,
                showDivider: widget.showDivider,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentGameRow extends StatelessWidget {
  const RecentGameRow({
    required this.game,
    this.showDivider = true,
    super.key,
  });

  final RecentGameSummary game;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: colors.card,
      child: Container(
        height: RecentGamesList.rowExtent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: colors.line))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.winner,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${game.date} · ${game.durationLabel}',
                    style: textTheme.bodySmall?.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            Text(
              '${game.score}',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 17,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
