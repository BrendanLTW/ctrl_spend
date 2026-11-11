import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Swipe left to reveal a red Delete button behind [child] (S16). Past
/// halfway it stays open; tapping Delete calls [onDelete], tapping the row
/// or dragging right closes it. Screen readers get a "Delete" action.
class SwipeToDelete extends StatefulWidget {
  const new({
    required this.child,
    required this.onDelete,
    required this.deleteLabel,
    this.radius = 24,
    super.key,
  });

  final Widget child;
  final VoidCallback onDelete;
  final String deleteLabel;

  /// The row's corner radius, matched by the button behind it.
  final double radius;

  static const revealWidth = 104.0;

  @override
  State<SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete>
    with SingleTickerProviderStateMixin {
  late final _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails details) =>
      _reveal.value -= details.primaryDelta! / SwipeToDelete.revealWidth;

  void _settle(DragEndDetails details) {
    final flungLeft = details.primaryVelocity! < -300;
    final flungRight = details.primaryVelocity! > 300;
    final stayOpen = !flungRight && (flungLeft || _reveal.value > 0.5);
    _reveal.animateTo(stayOpen ? 1 : 0, curve: Curves.easeOut);
  }

  void _close() => _reveal.animateTo(0, curve: Curves.easeOut);

  void _delete() {
    _reveal.value = 0;
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    // The light theme's red in both themes, as for destructive buttons.
    final red = AppColors.light.negative;
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: widget.deleteLabel): widget.onDelete,
      },
      child: GestureDetector(
        onHorizontalDragUpdate: _drag,
        onHorizontalDragEnd: _settle,
        child: Stack(
          children: [
            Positioned.fill(
              // Drawn only while open, so no red shows at the corners.
              child: ValueListenableBuilder(
                valueListenable: _reveal,
                builder: (context, value, panel) =>
                    value > 0 ? panel! : const SizedBox(),
                child: ExcludeSemantics(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: red,
                      borderRadius: BorderRadius.circular(widget.radius),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _delete,
                        splashFactory: NoSplash.splashFactory,
                        child: SizedBox(
                          // Reaches under the row so the corners meet.
                          width: SwipeToDelete.revealWidth + widget.radius,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: SwipeToDelete.revealWidth,
                              child: Center(
                                child: Text(
                                  widget.deleteLabel,
                                  style: context.text.rowTitle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _reveal,
              builder: (context, child) => Transform.translate(
                offset: Offset(-_reveal.value * SwipeToDelete.revealWidth, 0),
                child: child,
              ),
              child: ValueListenableBuilder(
                valueListenable: _reveal,
                // While open, a tap on the row closes it instead.
                builder: (context, value, child) => value > 0
                    ? Stack(
                        children: [
                          child!,
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _close,
                            ),
                          ),
                        ],
                      )
                    : child!,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
