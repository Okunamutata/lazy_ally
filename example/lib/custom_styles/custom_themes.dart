import 'package:material_ui/material_ui.dart';
import 'package:lazy_ally/lazy_ally.dart';

/// Full theme pairs registered through `LazyAlly.customThemes` in
/// `main.dart`. A selected [LazyAllyThemePair] replaces the *entire* base
/// [ThemeData], not just its [ColorScheme] (see `custom_schemes.dart` for
/// that narrower version). Each fruit varies both hue and corner shape here
/// so the difference reads as more than a recolor.
final Map<String, LazyAllyThemePair>
exampleCustomThemes = <String, LazyAllyThemePair>{
  'mango': _fruitTheme(seedColor: const Color(0xFFFFA726), cornerRadius: 20),
  'blueberry': _fruitTheme(seedColor: const Color(0xFF3F51B5), cornerRadius: 6),
  'dragonfruit': _fruitTheme(
    seedColor: const Color(0xFFE91E8C),
    cornerRadius: 2,
  ),
  'kiwi': _fruitTheme(seedColor: const Color(0xFF7CB342), cornerRadius: 28),
};

/// Builds a light+dark [LazyAllyThemePair] from one seed color and one
/// corner radius, applied to cards/buttons/chips — a stand-in for the kind
/// of full brand identity (typography, shapes, component themes) a real app
/// would vary here.
LazyAllyThemePair _fruitTheme({
  required Color seedColor,
  required double cornerRadius,
}) {
  ThemeData build(Brightness brightness) {
    final ThemeData base = ThemeData(
      colorSchemeSeed: seedColor,
      brightness: brightness,
      useMaterial3: true,
    );
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cornerRadius),
    );
    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(shape: shape),
      chipTheme: base.chipTheme.copyWith(shape: shape),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: shape),
      ),
    );
  }

  return (light: build(Brightness.light), dark: build(Brightness.dark));
}
