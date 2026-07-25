import 'package:flutter/material.dart';

import 'package:lazy_ally/src/utilities/lazy_ally_announce.dart';
import 'package:lazy_ally/src/widgets/lazy_ally_reduced_motion_builder.dart';

/// Builds the widget for one entry in a [LazyAllyRegistrySelector]: [name]
/// is the registry key, or `null` for "no selection". [selected] is whether
/// it's the current selection. Call [onSelect] on tap.
///
/// Not part of the public API — [LazyAllyCustomSchemeItemBuilder] and
/// [LazyAllyCustomThemeItemBuilder] alias this same function type for their
/// own public, documented names.
typedef LazyAllyRegistryItemBuilder =
    Widget Function(
      BuildContext context,
      String? name,
      bool selected,
      VoidCallback onSelect,
    );

/// Shared implementation behind `LazyAllyCustomSchemeSelector` and
/// `LazyAllyCustomThemeSelector` — both list a named registry (plus a
/// leading `null` "none" slot) via an [itemBuilder] in a [Wrap], defaulting
/// to a [ChoiceChip] per entry (swapped for a plain button under
/// reduce-motion), and always announcing the selection via
/// [lazyAllyAnnounce] regardless of builder.
///
/// Internal — not exported from `package:lazy_ally/lazy_ally.dart`. The two
/// public widgets differ only in which registry/labels they read and which
/// setter they call, so that part stays in each of them; this carries the
/// identical list-building, empty-registry, and default-chip logic both used
/// to duplicate verbatim.
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

  /// Name of the public widget calling this, used only in the
  /// empty-registry debug message.
  final String debugWidgetName;

  /// Name of the empty registry field, used only in the empty-registry
  /// debug message (e.g. `'customColorSchemes'`).
  final String debugRegistryName;

  /// The registry's keys, in iteration order. A leading `null` "none" slot
  /// is prepended automatically.
  final Iterable<String> names;

  /// The currently-selected key, or `null`.
  final String? selectedName;

  /// Label (and the name used in [announce]) for the leading `null` slot in
  /// the default [itemBuilder].
  final String noSelectionLabel;

  /// Called with the tapped entry's key (or `null`) when selected.
  final ValueChanged<String?> onSelected;

  /// Builds the announcement message for a selected entry's key (or `null`).
  final String Function(String? name) announce;

  /// Renders one entry. Omit for a default [ChoiceChip] per entry (swapped
  /// for a plain button under reduce-motion).
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
