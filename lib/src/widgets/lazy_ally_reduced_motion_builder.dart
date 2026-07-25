import 'package:flutter/material.dart';

import 'package:lazy_ally/src/lazy_ally_provider.dart';

/// Shows [motionChild] normally, or [reducedMotionChild] when the nearest
/// [LazyAllyProvider]'s `LazyAllyController.reduceMotion` is on — rebuilding
/// live via `reduceMotionListenable`.
///
/// For the common case of swapping to a static-but-still-communicative
/// alternative with no extra state to manage (no [AnimationController] to
/// start or stop — e.g. a built-in animated widget like
/// [CircularProgressIndicator] versus a static equivalent), this is simpler
/// than wiring up your own `ValueListenableBuilder<bool>`:
///
/// ```dart
/// LazyAllyReducedMotionBuilder(
///   motionChild: const CircularProgressIndicator(),
///   reducedMotionChild: const Text('Loading…'),
/// )
/// ```
///
/// If you need the current `reduceMotion` value itself — most commonly to
/// start/stop an [AnimationController] you own, so it doesn't keep ticking
/// invisibly behind whichever child isn't shown — use a
/// `ValueListenableBuilder<bool>` on `context.lazyAlly.reduceMotionListenable`
/// directly instead. See `example/lib/widgets/motion_examples.dart` for
/// worked examples of both.
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
