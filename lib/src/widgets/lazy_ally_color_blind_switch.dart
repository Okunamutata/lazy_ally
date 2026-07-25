import 'package:flutter/material.dart';

import 'package:lazy_ally/src/utilities/lazy_ally_announce.dart';
import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';

/// A standard [SwitchListTile] bound to the nearest [LazyAllyProvider]'s
/// [LazyAllyController.colorBlind] flag.
///
/// Place it anywhere below a `LazyAlly` widget. [SwitchListTile] already
/// merges its `title`/`subtitle` and toggled state into one semantics node
/// with no extra work needed; this additionally announces the change via
/// [lazyAllyAnnounce], since flipping a switch doesn't itself generate a
/// spoken confirmation the way a focus change does.
///
/// Title, subtitle, and the announcement all come from [labels] (English by
/// default) — see [LazyAllyLabels] to override any of them for a
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
