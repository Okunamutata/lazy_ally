import 'package:flutter/material.dart';
import 'package:lazy_ally/lazy_ally.dart';

/// Custom color scheme pairs registered through `LazyAlly.customColorSchemes`
/// in `main.dart`. This demonstrates the "arbitrary named theme" feature.
/// Selecting any of these **overrides color-blind mode**, per the resolution
/// order of `LazyAllyController.activeTheme`. See the panel's "Custom theme"
/// section for that in the UI.
///
/// Each entry is a [LazyAllyColorSchemePair]: the same brand/thematic hues,
/// built once for [Brightness.light] and once for [Brightness.dark] through
/// [_pairFrom]. LazyAlly always picks the member that matches the active
/// theme's current brightness, so there is never a mismatch to correct.
final Map<String, LazyAllyColorSchemePair> exampleCustomColorSchemes =
    <String, LazyAllyColorSchemePair>{
      'flutter': _pairFrom(primary: _flutterBlue, secondary: _flutterSkyBlue),
      'pride': _pairFrom(
        primary: _prideRed,
        secondary: _prideYellow,
        tertiary: _prideBlue,
        error: _prideViolet,
      ),
      'solidarity': _pairFrom(
        primary: _solidarityGreen,
        secondary: _solidarityRed,
        tertiary: _solidarityBlack,
      ),
      'halloween': _pairFrom(
        primary: _halloweenOrange,
        secondary: _halloweenPurple,
        tertiary: _halloweenBlack,
      ),
    };

/// Builds a light+dark [LazyAllyColorSchemePair] from the same pinned hues.
/// Only `brightness` differs between the two, so the brand/thematic accent
/// colors stay recognizable in both modes, while [ColorScheme.fromSeed]
/// still generates surfaces and on-colors correctly for each brightness.
LazyAllyColorSchemePair _pairFrom({
  required Color primary,
  Color? secondary,
  Color? tertiary,
  Color? error,
}) {
  ColorScheme build(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    primary: primary,
    onPrimary: lazyAllyOnColorFor(primary),
    secondary: secondary,
    onSecondary: secondary == null ? null : lazyAllyOnColorFor(secondary),
    tertiary: tertiary,
    onTertiary: tertiary == null ? null : lazyAllyOnColorFor(tertiary),
    error: error,
    onError: error == null ? null : lazyAllyOnColorFor(error),
  );
  return (light: build(Brightness.light), dark: build(Brightness.dark));
}

// --- flutter: Flutter's own brand blues ---
const Color _flutterBlue = Color(0xFF02569B);
const Color _flutterSkyBlue = Color(0xFF13B9FD);

// --- pride: the modern 6-stripe Pride flag palette ---
const Color _prideRed = Color(0xFFE40303);
const Color _prideYellow = Color(0xFFFFED00);
const Color _prideBlue = Color(0xFF004DFF);
const Color _prideViolet = Color(0xFF750787);

// --- solidarity: Palestinian flag colors ---
const Color _solidarityGreen = Color(0xFF007A3D);
const Color _solidarityRed = Color(0xFFCE1126);
const Color _solidarityBlack = Color(0xFF000000);

// --- halloween: classic pumpkin/black/purple ---
const Color _halloweenOrange = Color(0xFFFF7518);
const Color _halloweenPurple = Color(0xFF6A0DAD);
const Color _halloweenBlack = Color(0xFF000000);
