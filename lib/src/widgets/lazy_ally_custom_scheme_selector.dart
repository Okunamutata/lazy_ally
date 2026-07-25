import 'package:flutter/material.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_registry_selector.dart';

/// Builds the widget for one entry: [name] is the key from
/// [LazyAllyController.customColorSchemes], or `null` for "no selection".
/// [selected] is whether it's the current
/// [LazyAllyController.selectedCustomScheme]. Call [onSelect] on tap.
typedef LazyAllyCustomSchemeItemBuilder = LazyAllyRegistryItemBuilder;

/// Lists [LazyAllyController.customColorSchemes] (plus a leading `null`
/// "none" slot), each rendered via [itemBuilder] in a [Wrap].
///
/// Copy and styling are [itemBuilder]'s job, not this widget's. Omit it for
/// a default [ChoiceChip] per entry (swapped for a plain button under
/// reduce-motion). Selecting an entry always announces via
/// `lazyAllyAnnounce`, regardless of builder.
///
/// Not included in [LazyAllyPanel] — copy here is a product decision.
class LazyAllyCustomSchemeSelector extends StatelessWidget {
  const LazyAllyCustomSchemeSelector({
    super.key,
    this.itemBuilder,
    this.labels = const LazyAllyLabels(),
  });

  final LazyAllyCustomSchemeItemBuilder? itemBuilder;
  final LazyAllyLabels labels;

  @override
  Widget build(BuildContext context) {
    final LazyAllyController controller = context.lazyAlly;
    return LazyAllyRegistrySelector(
      debugWidgetName: 'LazyAllyCustomSchemeSelector',
      debugRegistryName: 'customColorSchemes',
      names: controller.customColorSchemes.keys,
      selectedName: controller.selectedCustomScheme,
      noSelectionLabel: labels.noSchemeSelected,
      onSelected: controller.setCustomScheme,
      announce: labels.announceScheme,
      itemBuilder: itemBuilder,
    );
  }
}
