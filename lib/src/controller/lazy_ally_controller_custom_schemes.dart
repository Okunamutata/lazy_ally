part of '../lazy_ally_controller.dart';

// region Custom color schemes
mixin _CustomSchemesMixin on ChangeNotifier {
  /// [LazyAllyController] supplies this value. The controller needs this
  /// value to pick the light or dark member of the selected scheme.
  ThemeData get _baseTheme;

  late final Map<String, LazyAllyColorSchemePair> _customColorSchemes;
  late String? _selectedCustomScheme;

  /// Named [LazyAllyColorSchemePair]s. When you select one (see
  /// [setCustomScheme]), the selection overrides [colorBlind] at
  /// [activeTheme] resolution.
  Map<String, LazyAllyColorSchemePair> get customColorSchemes =>
      _customColorSchemes;

  /// The selected entry in [customColorSchemes]. The value is `null` if
  /// nothing is selected.
  String? get selectedCustomScheme => _selectedCustomScheme;

  void setCustomScheme(String? name) {
    if (name == _selectedCustomScheme) return;
    _selectedCustomScheme = name;
    notifyListeners();
  }

  /// The resolved [ColorScheme] for [selectedCustomScheme]. The value is
  /// `null` if nothing is selected, or if the name is no longer registered.
  /// This getter resolves live against the brightness of [_baseTheme].
  ColorScheme? get resolvedCustomScheme {
    final LazyAllyColorSchemePair? pair = _selectedCustomScheme == null
        ? null
        : _customColorSchemes[_selectedCustomScheme];
    if (pair == null) return null;
    return _baseTheme.brightness == Brightness.dark ? pair.dark : pair.light;
  }
}
// endregion
