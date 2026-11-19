import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/utilities/lazy_ally_announce.dart';
import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_reduced_motion_builder.dart';

/// A brightness picker (System, Light, Dark) bound to the nearest
/// [LazyAllyProvider].
///
/// Place this widget anywhere below a `LazyAlly` widget. It reads and writes
/// [LazyAllyController.mode] directly, and it rebuilds on change through
/// [LazyAllyProvider]'s `InheritedNotifier`. It does not manage navigation,
/// paging, or its own container, such as a dialog, sheet, or page. That is
/// the job of the calling app.
///
/// This widget always offers exactly three options: [kLazyAllySystem]
/// ("System"), [kLazyAllyLight], and [kLazyAllyDark]. Do not add a custom
/// "extra dark" segment or similar option here. Register variants like that
/// as a named `LazyAllyController.customThemes` entry, and offer them
/// through `LazyAllyCustomThemeSelector`.
///
/// This widget renders a [Wrap] of [ChoiceChip]s in the normal case. Under
/// `reduceMotion`, it switches to a plain row of toggle buttons through
/// [LazyAllyReducedMotionBuilder], because you cannot suppress
/// `ChoiceChip`'s own select animation in place. Build your own alternative
/// with `reduceMotionListenable` and [LazyAllyReducedMotionBuilder] if you
/// need something more specific.
///
/// Text and announcements come from [labels]. See [LazyAllyLabels] for
/// non-English apps.
class LazyAllyBrightnessSelector extends StatelessWidget {
  const LazyAllyBrightnessSelector({
    super.key,
    this.labels = const LazyAllyLabels(),
  });

  final LazyAllyLabels labels;

  static const List<(String value, IconData icon)> _options =
      <(String, IconData)>[
        (kLazyAllySystem, Icons.brightness_auto_outlined),
        (kLazyAllyLight, Icons.light_mode_outlined),
        (kLazyAllyDark, Icons.dark_mode_outlined),
      ];

  void _select(
    BuildContext context,
    LazyAllyController controller,
    String value,
  ) {
    controller.setMode(value);
    lazyAllyAnnounce(
      context,
      labels.announceBrightness(labels.brightnessLabelFor(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LazyAllyController controller = context.lazyAlly;
    return LazyAllyReducedMotionBuilder(
      motionChild: _ChipRow(
        controller: controller,
        labels: labels,
        onSelect: (String value) => _select(context, controller, value),
      ),
      reducedMotionChild: _ButtonRow(
        controller: controller,
        labels: labels,
        onSelect: (String value) => _select(context, controller, value),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.controller,
    required this.labels,
    required this.onSelect,
  });

  final LazyAllyController controller;
  final LazyAllyLabels labels;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelSmall;
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final (String value, IconData icon)
            in LazyAllyBrightnessSelector._options)
          ChoiceChip(
            selected: controller.mode == value,
            onSelected: (bool _) => onSelect(value),
            label: Semantics(
              label: '${labels.brightnessLabelFor(value)} brightness',
              excludeSemantics: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 20),
                  const SizedBox(height: 2),
                  Text(labels.brightnessLabelFor(value), style: labelStyle),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Non-animated stand-in for [_ChipRow]. The button type for each option
/// changes instantly with [controller]'s state, with no transition.
class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    required this.controller,
    required this.labels,
    required this.onSelect,
  });

  final LazyAllyController controller;
  final LazyAllyLabels labels;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final (String value, IconData icon)
            in LazyAllyBrightnessSelector._options)
          Semantics(
            selected: controller.mode == value,
            child: controller.mode == value
                ? FilledButton.tonalIcon(
                    onPressed: () => onSelect(value),
                    icon: Icon(icon, size: 18),
                    label: Text(labels.brightnessLabelFor(value)),
                  )
                : OutlinedButton.icon(
                    onPressed: () => onSelect(value),
                    icon: Icon(icon, size: 18),
                    label: Text(labels.brightnessLabelFor(value)),
                  ),
          ),
      ],
    );
  }
}
