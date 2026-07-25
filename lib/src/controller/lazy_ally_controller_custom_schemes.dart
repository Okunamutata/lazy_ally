part of '../lazy_ally_controller.dart';

// region Custom color schemes
mixin _CustomSchemesMixin on ChangeNotifier {
  /// Supplied by [LazyAllyController]; needed to pick the light/dark member
  /// of the selected scheme.
  ThemeData get _baseTheme;

  late final Map<String, LazyAllyColorSchemePair> _customColorSchemes;
  late String? _selectedCustomScheme;

  /// Named [LazyAllyColorSchemePair]s. Selecting one (see [setCustomScheme])
  /// overrides [colorBlind] at [activeTheme] resolution.
  Map<String, LazyAllyColorSchemePair> get customColorSchemes =>
      _customColorSchemes;

  /// The selected entry in [customColorSchemes], or `null`.
  String? get selectedCustomScheme => _selectedCustomScheme;

  void setCustomScheme(String? name) {
    if (name == _selectedCustomScheme) return;
    _selectedCustomScheme = name;
    notifyListeners();
  }

  /// The resolved [ColorScheme] for [selectedCustomScheme], or `null` if
  /// nothing is selected or the name is no longer registered. Re-resolves
  /// live against [_baseTheme]'s brightness.
  ColorScheme? get resolvedCustomScheme {
    final LazyAllyColorSchemePair? pair = _selectedCustomScheme == null
        ? null
        : _customColorSchemes[_selectedCustomScheme];
    if (pair == null) return null;
    return _baseTheme.brightness == Brightness.dark ? pair.dark : pair.light;
  }
}
// endregion
