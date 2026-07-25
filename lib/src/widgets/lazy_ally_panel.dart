import 'package:flutter/material.dart';

import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_brightness_selector.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_color_blind_switch.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_reduce_motion_switch.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_text_scale_slider.dart';

/// A ready-made column of LazyAlly's core controls — brightness, text
/// scale, color-blind, reduce-motion — meant to be dropped into a container
/// **you** build and manage: a `showModalBottomSheet` builder, a `Dialog`,
/// a settings page section. Opens/sizes/manages nothing itself.
///
/// Deliberately excludes `LazyAllyCustomSchemeSelector`/
/// `LazyAllyCustomThemeSelector` — their copy is a product decision, not
/// this panel's to make. Place either yourself.
///
/// Re-asserts a live `Theme` from `context.lazyAlly.activeTheme` rather
/// than trusting ambient `Theme.of(context)`, because
/// `showModalBottomSheet`/`showDialog` capture `Theme` as a static snapshot
/// at push time (routes reparent into the root `Overlay`, outside the
/// calling context's tree) — without this, state changes while the panel
/// is open in a pushed route wouldn't repaint. Apply the same
/// `Theme(data: context.lazyAlly.activeTheme, child: ...)` pattern if you
/// build your own settings surface instead.
class LazyAllyPanel extends StatelessWidget {
  const LazyAllyPanel({
    super.key,
    this.showReduceMotion = true,
    this.labels = const LazyAllyLabels(),
  });

  /// Whether to include the "Reduce motion" row at all. Defaults to `true`.
  /// Set `false` if you're not ready to expose that option yet.
  final bool showReduceMotion;

  /// Copy for this panel's own headings, forwarded as-is to every control
  /// it renders. English by default — see [LazyAllyLabels] to override it
  /// for a non-English app; you only need to build one instance and pass it
  /// here, not one per control.
  final LazyAllyLabels labels;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.lazyAlly.activeTheme;

    return Theme(
      data: theme,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                labels.appearanceHeading,
                style: theme.textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            LazyAllyBrightnessSelector(labels: labels),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                labels.textSizeHeading,
                style: theme.textTheme.labelLarge,
              ),
            ),
            LazyAllyTextScaleSlider(labels: labels),
            const SizedBox(height: 12),
            LazyAllyColorBlindSwitch(labels: labels),
            if (showReduceMotion) LazyAllyReduceMotionSwitch(labels: labels),
          ],
        ),
      ),
    );
  }
}
