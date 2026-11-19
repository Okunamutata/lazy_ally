import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/utilities/lazy_ally_announce.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_reduced_motion_builder.dart';

/// Builds the widget for one entry in a [LazyAllyRegistrySelector]. [name]
/// is the registry key, or `null` for "no selection". [selected] shows
/// whether this entry is the current selection. This function calls
/// [onSelect] on tap.
///
/// This type is not part of the public API. [LazyAllyCustomSchemeItemBuilder]
/// and [LazyAllyCustomThemeItemBuilder] alias this same function type under
/// their own public, documented names.
typedef LazyAllyRegistryItemBuilder = Widget Function(
  BuildContext context,
  String? name,
  bool selected,
  VoidCallback onSelect,
);

/// The shared implementation behind `LazyAllyCustomSchemeSelector` and
/// `LazyAllyCustomThemeSelector`. Both widgets list a named registry, plus
/// a leading `null` "none" slot, through an [itemBuilder] in a [Wrap]. Both
/// default to a [ChoiceChip] for each entry, which this widget swaps for a
/// plain button under reduce motion. Both always announce the selection
/// through [lazyAllyAnnounce], regardless of the builder used.
///
/// This widget is internal, and not exported from
/// `package:lazy_ally/lazy_ally.dart`. The two public widgets differ only
/// in which registry and labels they read, and which setter they call, so
/// that part stays in each of them. This widget carries the identical
/// list-building, empty-registry, and default-chip logic that both widgets
/// used to duplicate verbatim.
class LazyAllyRegistrySelector extends StatelessWidget {
  const LazyAllyRegistrySelector({
    super.key,
    required this.debugWidgetName,
    required this.debugRegistryName,
    required this.names,
    required this.selectedName,
    required this.noSelectionLabel,
    required this.onSelected,
    required this.announce,
    this.itemBuilder,
  });

  /// The name of the public widget that calls this widget, used only in the
  /// empty-registry debug message.
  final String debugWidgetName;

  /// The name of the empty registry field, used only in the empty-registry
  /// debug message. For example, `'customColorSchemes'`.
  final String debugRegistryName;

  /// The registry's keys, in iteration order. This widget automatically
  /// adds a leading `null` "none" slot.
  final Iterable<String> names;

  /// The currently selected key, or `null`.
  final String? selectedName;

  /// The label, and the name used in [announce], for the leading `null`
  /// slot in the default [itemBuilder].
  final String noSelectionLabel;

  /// This callback receives the tapped entry's key, or `null`, when the
  /// user selects it.
  final ValueChanged<String?> onSelected;

  /// Builds the announcement message for a selected entry's key, or `null`.
  final String Function(String? name) announce;

  /// Renders one entry. Omit this to get a default [ChoiceChip] for each
  /// entry, which this widget swaps for a plain button under reduce motion.
  final LazyAllyRegistryItemBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      assert(() {
        debugPrint(
          '$debugWidgetName: no $debugRegistryName registered — '
          'rendering nothing.',
        );
        return true;
      }());
      return const SizedBox.shrink();
    }

    final LazyAllyRegistryItemBuilder build =
        itemBuilder ?? _defaultItemBuilder(noSelectionLabel);
    final List<String?> allNames = <String?>[null, ...names];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final String? name in allNames)
          build(context, name, selectedName == name, () {
            onSelected(name);
            lazyAllyAnnounce(context, announce(name));
          }),
      ],
    );
  }

  static LazyAllyRegistryItemBuilder _defaultItemBuilder(
    String noSelectionLabel,
  ) {
    return (
      BuildContext context,
      String? name,
      bool selected,
      VoidCallback onSelect,
    ) {
      final String label = name ?? noSelectionLabel;
      return LazyAllyReducedMotionBuilder(
        motionChild: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (bool _) => onSelect(),
        ),
        reducedMotionChild: selected
            ? FilledButton.tonal(onPressed: onSelect, child: Text(label))
            : OutlinedButton(onPressed: onSelect, child: Text(label)),
      );
    };
  }
}
