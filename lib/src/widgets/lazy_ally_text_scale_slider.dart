import 'package:flutter/material.dart';

import 'package:lazy_ally/src/utilities/lazy_ally_announce.dart';
import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_reduced_motion_builder.dart';

/// A text scale control bound to the nearest [LazyAllyProvider]'s
/// [LazyAllyController.textScaleFactor]. This widget clamps the value to
/// that controller's configured `textScaleMin` and `textScaleMax`.
///
/// Place this widget anywhere below a `LazyAlly` widget. It renders a
/// [Slider] in the normal case. Under `reduceMotion`, it switches to a
/// "-"/"+" [IconButton] pair through [LazyAllyReducedMotionBuilder].
/// Dragging a thumb is itself a continuous-motion interaction, so a
/// discrete step control is the direct fix. Suppressing [Slider]'s own
/// motion in place would not solve this.
///
/// [Slider.semanticFormatterCallback], sourced from
/// [LazyAllyLabels.announceTextScale], gives the slider's built-in live
/// spoken value a fuller "1.20 times text size" phrasing. This widget does
/// not call [lazyAllyAnnounce] on every drag tick, because the built-in
/// semantics already cover that case. It calls [lazyAllyAnnounce] only
/// once, through [Slider.onChangeEnd], or once per tap for the step
/// buttons.
class LazyAllyTextScaleSlider extends StatelessWidget {
  const LazyAllyTextScaleSlider({
    super.key,
    this.divisions,
    this.step = 0.1,
    this.labels = const LazyAllyLabels(),
  });

  /// Snap points for the [Slider] shown when motion is not reduced. This
  /// value has no effect on the step-button fallback, which always uses
  /// [step].
  final int? divisions;

  /// The amount that each tap of the step-button fallback's "-"/"+"
  /// buttons changes [LazyAllyController.textScaleFactor] by. This value
  /// has no effect on the [Slider] shown when motion is not reduced.
  final double step;

  final LazyAllyLabels labels;

  @override
  Widget build(BuildContext context) {
    final LazyAllyController controller = context.lazyAlly;
    return LazyAllyReducedMotionBuilder(
      motionChild: Slider(
        value: controller.textScaleFactor,
        min: controller.textScaleMin,
        max: controller.textScaleMax,
        divisions: divisions,
        label: '${controller.textScaleFactor.toStringAsFixed(2)}x',
        semanticFormatterCallback: labels.announceTextScale,
        onChanged: controller.setTextScaleFactor,
        onChangeEnd: (double value) =>
            lazyAllyAnnounce(context, labels.announceTextScale(value)),
      ),
      reducedMotionChild: _StepButtons(
        controller: controller,
        labels: labels,
        step: step,
      ),
    );
  }
}

class _StepButtons extends StatelessWidget {
  const _StepButtons({
    required this.controller,
    required this.labels,
    required this.step,
  });

  final LazyAllyController controller;
  final LazyAllyLabels labels;
  final double step;

  void _adjust(BuildContext context, double delta) {
    controller.setTextScaleFactor(controller.textScaleFactor + delta);
    lazyAllyAnnounce(
      context,
      labels.announceTextScale(controller.textScaleFactor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove),
          tooltip: labels.decreaseTextSizeTooltip,
          onPressed: controller.textScaleFactor <= controller.textScaleMin
              ? null
              : () => _adjust(context, -step),
        ),
        Text('${controller.textScaleFactor.toStringAsFixed(2)}x'),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: labels.increaseTextSizeTooltip,
          onPressed: controller.textScaleFactor >= controller.textScaleMax
              ? null
              : () => _adjust(context, step),
        ),
      ],
    );
  }
}
