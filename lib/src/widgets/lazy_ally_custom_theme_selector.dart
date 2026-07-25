import 'package:flutter/material.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_registry_selector.dart';

/// Builds the widget for one entry: [name] is the key from
/// [LazyAllyController.customThemes], or `null` for "no selection".
/// [selected] is whether it's the current
/// [LazyAllyController.selectedCustomTheme]. Call [onSelect] on tap.
typedef LazyAllyCustomThemeItemBuilder = LazyAllyRegistryItemBuilder;

/// [LazyAllyCustomSchemeSelector]'s counterpart for
/// [LazyAllyController.customThemes] — a full [ThemeData] pair instead of
/// just a [ColorScheme]. Same shape: [itemBuilder] owns copy/styling, omit
/// it for a default [ChoiceChip] per entry (swapped for a plain button
/// under reduce-motion).
///
/// Not included in [LazyAllyPanel] — copy here is a product decision.
class LazyAllyCustomThemeSelector extends StatelessWidget {
  const LazyAllyCustomThemeSelector({
    super.key,
    this.itemBuilder,
    this.labels = const LazyAllyLabels(),
  });

  final LazyAllyCustomThemeItemBuilder? itemBuilder;
  final LazyAllyLabels labels;

  @override
  Widget build(BuildContext context) {
    final LazyAllyController controller = context.lazyAlly;
    return LazyAllyRegistrySelector(
      debugWidgetName: 'LazyAllyCustomThemeSelector',
      debugRegistryName: 'customThemes',
      names: controller.customThemes.keys,
      selectedName: controller.selectedCustomTheme,
      noSelectionLabel: labels.noThemeSelected,
      onSelected: controller.setCustomTheme,
      announce: labels.announceTheme,
      itemBuilder: itemBuilder,
    );
  }
}
