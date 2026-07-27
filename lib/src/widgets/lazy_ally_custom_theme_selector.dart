import 'package:flutter/material.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_registry_selector.dart';

/// Builds the widget for one entry. [name] is the key from
/// [LazyAllyController.customThemes], or `null` for "no selection".
/// [selected] shows whether this entry is the current
/// [LazyAllyController.selectedCustomTheme]. This function calls [onSelect]
/// on tap.
typedef LazyAllyCustomThemeItemBuilder = LazyAllyRegistryItemBuilder;

/// The counterpart to [LazyAllyCustomSchemeSelector] for
/// [LazyAllyController.customThemes]. This widget uses a full [ThemeData]
/// pair instead of just a [ColorScheme]. It has the same shape:
/// [itemBuilder] owns the copy and styling. Omit [itemBuilder] to get a
/// default [ChoiceChip] for each entry, which this widget swaps for a plain
/// button under reduce motion.
///
/// This widget is not included in [LazyAllyPanel]. The copy here is a
/// product decision for the calling app.
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
