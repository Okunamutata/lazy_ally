import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/utilities/lazy_ally_announce.dart';
import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';

/// A standard [SwitchListTile] bound to the nearest [LazyAllyProvider]'s
/// [LazyAllyController.colorBlind] flag.
///
/// Place this widget anywhere below a `LazyAlly` widget. [SwitchListTile]
/// already merges its `title`, `subtitle`, and toggled state into one
/// semantics node, with no extra work needed. This widget also announces
/// the change through [lazyAllyAnnounce], because flipping a switch does not
/// itself generate a spoken confirmation the way a focus change does.
///
/// The title, subtitle, and announcement all come from [labels] (English by
/// default). See [LazyAllyLabels] to override any of these for a
/// non-English app.
class LazyAllyColorBlindSwitch extends StatelessWidget {
  const LazyAllyColorBlindSwitch({
    super.key,
    this.labels = const LazyAllyLabels(),
  });

  final LazyAllyLabels labels;

  @override
  Widget build(BuildContext context) {
    final LazyAllyController controller = context.lazyAlly;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(labels.colorBlindTitle),
      subtitle: Text(labels.colorBlindSubtitle),
      value: controller.colorBlind,
      onChanged: (bool value) {
        controller.setColorBlind(value);
        lazyAllyAnnounce(context, labels.announceColorBlind(value));
      },
    );
  }
}
