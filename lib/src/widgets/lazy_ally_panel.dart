import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_brightness_selector.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_color_blind_switch.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_reduce_motion_switch.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_text_scale_slider.dart';

/// A ready-made column of LazyAlly's core controls: brightness, text
/// scale, color blind, and reduce motion. You drop this column into a
/// container that you build and manage, such as a `showModalBottomSheet`
/// builder, a `Dialog`, or a settings page section. This widget does not
/// open, size, or manage any container itself.
///
/// This panel deliberately excludes `LazyAllyCustomSchemeSelector` and
/// `LazyAllyCustomThemeSelector`. Their copy is a product decision, not a
/// decision for this panel to make. Place either widget yourself if you
/// need it.
///
/// This widget re-asserts a live `Theme` from `context.lazyAlly.activeTheme`,
/// instead of trusting the ambient `Theme.of(context)`. It does this
/// because `showModalBottomSheet` and `showDialog` capture `Theme` as a
/// static snapshot at push time. Routes reparent into the root `Overlay`,
/// outside the calling context's tree. Without this re-assertion, state
/// changes would not repaint the panel while it is open in a pushed route.
/// Apply the same `Theme(data: context.lazyAlly.activeTheme, child: ...)`
/// pattern if you build your own settings surface instead.
class LazyAllyPanel extends StatelessWidget {
  const LazyAllyPanel({
    super.key,
    this.showReduceMotion = true,
    this.labels = const LazyAllyLabels(),
  });

  /// Whether to include the "Reduce motion" row. The default value is
  /// `true`. Set this to `false` if you are not ready to expose that
  /// option yet.
  final bool showReduceMotion;

  /// Copy for this panel's own headings. The panel forwards this copy as-is
  /// to every control it renders. The default language is English. See
  /// [LazyAllyLabels] to override the copy for a non-English app. You only
  /// need to build one instance and pass it here, not one instance per
  /// control.
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
