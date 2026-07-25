import 'package:flutter/material.dart';
import 'package:lazy_ally/lazy_ally.dart';

/// Four demos of gating a custom animation on `reduceMotionListenable` /
/// `LazyAllyReducedMotionBuilder`, swapping to a still-communicative static
/// representation instead of deleting the animation outright.
///
/// The first three own an [AnimationController] directly (need the
/// `reduceMotion` value to start/stop it, and actually stop it when
/// reduced — not just hide it behind a static widget, since some users
/// reduce motion for battery/performance, not just preference). The fourth
/// needs no controller — [LazyAllyReducedMotionBuilder] alone is enough
/// when you're just swapping two already-built widgets.
class MotionExamplesSection extends StatelessWidget {
  const MotionExamplesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Reduce-motion-aware widgets', style: textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          "Toggle 'Reduce motion' in the accessibility panel (the FAB) to "
          'see each of these switch representations — every one keeps '
          'communicating the same thing, just without motion.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _Demo(label: 'Loading', child: ReduceMotionAwareSpinner()),
            _Demo(label: 'Like button', child: ReduceMotionAwareLikeButton()),
            _Demo(label: 'New badge', child: ReduceMotionAwareNewBadge()),
            _Demo(
              label: 'Uploading',
              child: ReduceMotionAwareUploadIndicator(),
            ),
          ],
        ),
      ],
    );
  }
}

class _Demo extends StatelessWidget {
  const _Demo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        children: <Widget>[
          SizedBox(height: 40, child: Center(child: child)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class ReduceMotionAwareSpinner extends StatefulWidget {
  const ReduceMotionAwareSpinner({super.key});

  @override
  State<ReduceMotionAwareSpinner> createState() =>
      _ReduceMotionAwareSpinnerState();
}

class _ReduceMotionAwareSpinnerState extends State<ReduceMotionAwareSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.lazyAlly.reduceMotionListenable,
      builder: (BuildContext context, bool reduceMotion, _) {
        if (reduceMotion) {
          if (_controller.isAnimating) _controller.stop();
          // FittedBox, not a bare Row: this cell has a fixed width (see
          // _Demo), and text scale — the very thing this package lets users
          // crank up — can easily make "Saving…" + icon wider than that.
          // Shrink to fit rather than overflow.
          return const FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.sync, size: 18),
                SizedBox(width: 6),
                Text('Saving…'),
              ],
            ),
          );
        }
        if (!_controller.isAnimating) _controller.repeat();
        return RotationTransition(
          turns: _controller,
          child: const Icon(Icons.sync),
        );
      },
    );
  }
}

/// Intent: "this is now liked / not liked." Animated: the heart icon scales
/// up and back down on tap (a "bounce"). Reduced: the icon still swaps
/// instantly between outline and filled+red — the state change itself,
/// not the bounce, is what actually communicates "liked."
class ReduceMotionAwareLikeButton extends StatefulWidget {
  const ReduceMotionAwareLikeButton({super.key});

  @override
  State<ReduceMotionAwareLikeButton> createState() =>
      _ReduceMotionAwareLikeButtonState();
}

class _ReduceMotionAwareLikeButtonState
    extends State<ReduceMotionAwareLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.4),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.4, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.lazyAlly.reduceMotionListenable,
      builder: (BuildContext context, bool reduceMotion, _) {
        final Widget icon = Icon(
          _liked ? Icons.favorite : Icons.favorite_border,
          color: _liked ? Colors.red : null,
        );
        return IconButton(
          tooltip: _liked ? 'Unlike' : 'Like',
          onPressed: () {
            setState(() => _liked = !_liked);
            if (!reduceMotion && _liked) _controller.forward(from: 0);
          },
          icon: reduceMotion
              ? icon
              : ScaleTransition(scale: _scale, child: icon),
        );
      },
    );
  }
}

class ReduceMotionAwareNewBadge extends StatefulWidget {
  const ReduceMotionAwareNewBadge({super.key});

  @override
  State<ReduceMotionAwareNewBadge> createState() =>
      _ReduceMotionAwareNewBadgeState();
}

class _ReduceMotionAwareNewBadgeState extends State<ReduceMotionAwareNewBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.lazyAlly.reduceMotionListenable,
      builder: (BuildContext context, bool reduceMotion, _) {
        const Widget dot = DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 10, height: 10),
        );
        if (reduceMotion) {
          if (_controller.isAnimating) _controller.stop();
          return Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent),
            ),
            child: dot,
          );
        }
        if (!_controller.isAnimating) _controller.repeat(reverse: true);
        return ScaleTransition(scale: _pulse, child: dot);
      },
    );
  }
}

class ReduceMotionAwareUploadIndicator extends StatelessWidget {
  const ReduceMotionAwareUploadIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const LazyAllyReducedMotionBuilder(
      motionChild: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      // Same reasoning as ReduceMotionAwareSpinner's "Saving…" row: this
      // cell has a fixed width, and text scale can widen this past it.
      reducedMotionChild: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.cloud_upload_outlined, size: 18),
            SizedBox(width: 6),
            Text('Uploading'),
          ],
        ),
      ),
    );
  }
}
