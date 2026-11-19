import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/utilities/lazy_ally_announce.dart';
import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';

/// A standard [SwitchListTile] bound to the nearest [LazyAllyProvider]'s
/// [LazyAllyController.reduceMotion] flag.
///
/// Place this widget anywhere below a `LazyAlly` widget. This widget also
/// announces the change through [lazyAllyAnnounce]. See
/// [LazyAllyColorBlindSwitch] for the reason.
///
/// The title, subtitle, and announcement all come from [labels] (English by
/// default). See [LazyAllyLabels] to override any of these for a
/// non-English app.
class LazyAllyReduceMotionSwitch extends StatelessWidget {
  const LazyAllyReduceMotionSwitch({
    super.key,
    this.labels = const LazyAllyLabels(),
  });

  final LazyAllyLabels labels;

  @override
  Widget build(BuildContext context) {
    final LazyAllyController controller = context.lazyAlly;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(labels.reduceMotionTitle),
      subtitle: Text(labels.reduceMotionSubtitle),
      value: controller.reduceMotion,
      onChanged: (bool value) {
        controller.setReduceMotion(value);
        lazyAllyAnnounce(context, labels.announceReduceMotion(value));
      },
    );
  }
}
