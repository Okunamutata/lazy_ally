part of '../lazy_ally_controller.dart';

// region Color-blind
mixin _ColorBlindMixin on ChangeNotifier {
  /// Supplied by [LazyAllyController]; [colorBlindScheme] needs the active
  /// theme's brightness to pick the right member of a pair.
  ThemeData get _baseTheme;

  late final LazyAllyColorSchemePair? _colorBlindScheme;
  late bool _colorBlind;

  bool get colorBlind => _colorBlind;

  void setColorBlind(bool value) {
    if (value == _colorBlind) return;
    _colorBlind = value;
    notifyListeners();
  }

  /// The [ColorScheme] [activeTheme] swaps in while [colorBlind] is on and
  /// no custom scheme overrides it. Defaults to Okabe-Ito.
  ColorScheme get colorBlindScheme {
    final LazyAllyColorSchemePair pair =
        _colorBlindScheme ??
        (light: kOkabeItoColorSchemeLight, dark: kOkabeItoColorSchemeDark);
    return _baseTheme.brightness == Brightness.dark ? pair.dark : pair.light;
  }
}
// endregion
