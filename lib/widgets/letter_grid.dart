import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/puzzle.dart';

class LetterGrid extends StatefulWidget {
  const LetterGrid({
    super.key,
    required this.puzzle,
    required this.foundWordIds,
    required this.selectedStart,
    required this.onCellTap,
    required this.onDragSelection,
  });

  final Puzzle puzzle;
  final Set<String> foundWordIds;
  final CellPosition? selectedStart;
  final ValueChanged<CellPosition> onCellTap;
  final Future<void> Function(CellPosition, CellPosition) onDragSelection;

  @override
  State<LetterGrid> createState() => _LetterGridState();
}

class _LetterGridState extends State<LetterGrid> {
  CellPosition? _dragStart;
  CellPosition? _dragEnd;
  int? _activePointer;
  bool _dragMoved = false;

  static const double spacing = 1.5;

  CellPosition? _positionAt(Offset position, int size, double cellSize) {
    final step = cellSize + spacing;

    if (position.dx < 0 || position.dy < 0) return null;

    final column = (position.dx / step).floor();
    final row = (position.dy / step).floor();

    if (row >= size || column >= size) return null;

    final insideCellX = position.dx % step <= cellSize;
    final insideCellY = position.dy % step <= cellSize;

    if (!insideCellX || !insideCellY) return null;

    return CellPosition(row, column);
  }

  void _pointerDown(PointerDownEvent event, int size, double cellSize) {
    if (_activePointer != null) return;

    final position = _positionAt(event.localPosition, size, cellSize);
    if (position == null) return;

    setState(() {
      _activePointer = event.pointer;
      _dragStart = position;
      _dragEnd = position;
      _dragMoved = false;
    });
  }

  void _pointerMove(PointerMoveEvent event, int size, double cellSize) {
    if (event.pointer != _activePointer) return;

    final position = _positionAt(event.localPosition, size, cellSize);
    if (position == null) return;

    if (position != _dragStart) {
      _dragMoved = true;
    }

    setState(() {
      _dragEnd = position;
    });
  }

  void _pointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) return;

    final start = _dragStart;
    final end = _dragEnd;
    final moved = _dragMoved;

    setState(() {
      _activePointer = null;
      _dragStart = null;
      _dragEnd = null;
      _dragMoved = false;
    });

    if (moved && start != null && end != null && start != end) {
      widget.onDragSelection(start, end);
    }
  }

  void _pointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;

    setState(() {
      _activePointer = null;
      _dragStart = null;
      _dragEnd = null;
      _dragMoved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.puzzle.difficulty.gridSize;

    final cellSize = size <= 4
        ? 62.0
        : size <= 8
        ? 42.0
        : size <= 16
        ? 34.0
        : 30.0;

    final boardSize = cellSize * size + spacing * (size - 1);

    // Outlines for words that have already been found.
    final outlines = <List<CellPosition>>[];

    for (final id in widget.foundWordIds) {
      final placement = widget.puzzle.placements[id];

      if (placement != null) {
        outlines.add(placement);
      }
    }

    // Outline for the word currently being dragged or selected.
    final currentStart = _dragStart ?? widget.selectedStart;
    final currentEnd = _dragEnd ?? widget.selectedStart;

    if (currentStart != null && currentEnd != null) {
      outlines.add([currentStart, currentEnd]);
    }

    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Listener(
          onPointerDown: (event) => _pointerDown(event, size, cellSize),
          onPointerMove: (event) => _pointerMove(event, size, cellSize),
          onPointerUp: _pointerUp,
          onPointerCancel: _pointerCancel,
          child: Stack(
            children: [
              GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: size * size,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ size;
                  final column = index % size;
                  final position = CellPosition(row, column);

                  final isFound = widget.foundWordIds.any(
                    (id) =>
                        widget.puzzle.placements[id]?.contains(position) ??
                        false,
                  );

                  final scheme = Theme.of(context).colorScheme;

                  return Semantics(
                    button: true,
                    label:
                        'Row ${row + 1}, column ${column + 1}, '
                        'letter ${widget.puzzle.grid[row][column]}',
                    child: GestureDetector(
                      onTap: () => widget.onCellTap(position),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isFound
                              ? scheme.tertiaryContainer
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            size >= 16 ? 3 : 8,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.puzzle.grid[row][column],
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: isFound
                                  ? scheme.onTertiaryContainer
                                  : scheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: size >= 16 ? 15 : 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Draw the continuous outlines above the letters.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _WordOutlinePainter(
                      outlines: outlines,
                      cellSize: cellSize,
                      spacing: spacing,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordOutlinePainter extends CustomPainter {
  _WordOutlinePainter({
    required this.outlines,
    required this.cellSize,
    required this.spacing,
  });

  final List<List<CellPosition>> outlines;
  final double cellSize;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..isAntiAlias = true;

    for (final word in outlines) {
      if (word.isEmpty) continue;

      final first = word.first;
      final last = word.last;

      final step = cellSize + spacing;

      final start = Offset(
        first.column * step + cellSize / 2,
        first.row * step + cellSize / 2,
      );

      final end = Offset(
        last.column * step + cellSize / 2,
        last.row * step + cellSize / 2,
      );

      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;

      final length = Offset(dx, dy).distance + cellSize;
      final angle = length == 0 ? 0.0 : 0.0;

      final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(dx == 0 && dy == 0 ? angle : _angle(dx, dy));

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: length + 8,
        height: cellSize + 8,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular((cellSize + 8) / 2)),
        paint,
      );

      canvas.restore();
    }
  }

  double _angle(double dx, double dy) {
    return math.atan2(dy, dx);
  }

  @override
  bool shouldRepaint(covariant _WordOutlinePainter oldDelegate) {
    return true;
  }
}
