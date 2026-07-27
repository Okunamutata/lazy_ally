part of '../lazy_ally_controller.dart';

// region Color-blind
mixin _ColorBlindMixin on ChangeNotifier {
  /// [LazyAllyController] supplies this value. [colorBlindScheme] needs the
  /// brightness of the active theme to pick the right member of a pair.
  ThemeData get _baseTheme;

  late final LazyAllyColorSchemePair? _colorBlindScheme;
  late bool _colorBlind;

  bool get colorBlind => _colorBlind;

  void setColorBlind(bool value) {
    if (value == _colorBlind) return;
    _colorBlind = value;
    notifyListeners();
  }

  /// The [ColorScheme] that [activeTheme] swaps in while [colorBlind] is on
  /// and no custom scheme overrides it. The default value is the IBM
  /// color-blind-safe palette.
  ColorScheme get colorBlindScheme {
    final LazyAllyColorSchemePair pair =
        _colorBlindScheme ??
        (light: kIbmColorBlindSchemeLight, dark: kIbmColorBlindSchemeDark);
    return _baseTheme.brightness == Brightness.dark ? pair.dark : pair.light;
  }
}
// endregion
