import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/lazy_ally_provider.dart';

/// This widget shows [motionChild] in the normal case. It shows
/// [reducedMotionChild] when the nearest [LazyAllyProvider]'s
/// `LazyAllyController.reduceMotion` is on. The widget rebuilds live
/// through `reduceMotionListenable`.
///
/// Use this widget for the common case: you swap to a static alternative
/// that still communicates its meaning, with no extra state to manage. For
/// example, you might swap a built-in animated widget like
/// [CircularProgressIndicator] for a static equivalent, with no
/// [AnimationController] to start or stop. This widget is simpler than
/// building your own `ValueListenableBuilder<bool>`:
///
/// ```dart
/// LazyAllyReducedMotionBuilder(
///   motionChild: const CircularProgressIndicator(),
///   reducedMotionChild: const Text('Loading…'),
/// )
/// ```
///
/// If you need the current `reduceMotion` value itself, use a
/// `ValueListenableBuilder<bool>` on
/// `context.lazyAlly.reduceMotionListenable` directly instead. You most
/// commonly need this to start or stop an [AnimationController] that you
/// own, so it does not keep running invisibly behind whichever child is not
/// shown. See `example/lib/widgets/motion_examples.dart` for worked
/// examples of both approaches.
class LazyAllyReducedMotionBuilder extends StatelessWidget {
  const LazyAllyReducedMotionBuilder({
    super.key,
    required this.motionChild,
    required this.reducedMotionChild,
  });

  /// Shown when motion is not reduced.
  final Widget motionChild;

  /// Shown when motion is reduced.
  final Widget reducedMotionChild;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.lazyAlly.reduceMotionListenable,
      builder: (BuildContext context, bool reduceMotion, Widget? _) =>
          reduceMotion ? reducedMotionChild : motionChild,
    );
  }
}
