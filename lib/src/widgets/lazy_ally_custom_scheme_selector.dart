import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/domain/lazy_ally_labels.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_registry_selector.dart';

/// Builds the widget for one entry. [name] is the key from
/// [LazyAllyController.customColorSchemes], or `null` for "no selection".
/// [selected] shows whether this entry is the current
/// [LazyAllyController.selectedCustomScheme]. This function calls [onSelect]
/// on tap.
typedef LazyAllyCustomSchemeItemBuilder = LazyAllyRegistryItemBuilder;

/// Lists [LazyAllyController.customColorSchemes], plus a leading `null`
/// "none" slot. This widget renders each entry through [itemBuilder] in a
/// [Wrap].
///
/// Copy and styling are the job of [itemBuilder], not of this widget. Omit
/// [itemBuilder] to get a default [ChoiceChip] for each entry, which this
/// widget swaps for a plain button under reduce motion. Selecting an entry
/// always announces the change through `lazyAllyAnnounce`, regardless of
/// the builder used.
///
/// This widget is not included in [LazyAllyPanel]. The copy here is a
/// product decision for the calling app.
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
