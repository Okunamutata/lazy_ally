import 'package:flutter/material.dart';

import 'okabe_ito.dart';

/// Well-known brightness-mode identifiers understood by [LazyAllyController]
/// out of the box. Modeled as [String]s (not a closed `enum`) so a future
/// custom-theme registry (planned) can add arbitrary named modes without a
/// breaking change to this API.
const String kLazyAllyLight = 'light';
const String kLazyAllyDark = 'dark';
const String kLazyAllyExtraDark = 'extraDark';

double _clampD(double value, double lo, double hi) {
  if (value < lo) return lo;
  if (value > hi) return hi;
  return value;
}

/// Holds the current LazyAlly theme selection, color-blind flag, and text
/// scale factor, and notifies listeners on change.
///
/// Color-blind mode is deliberately **orthogonal** to brightness mode (a
/// [bool], not a fourth mode) — a color-blind user still has a light/dark
/// preference. It's also scoped to *semantic/data colors only* via
/// [cvdSafeColor]; it does not remap [ThemeData]'s neutral surfaces, which
/// are already contrast- rather than hue-driven.
class LazyAllyController extends ChangeNotifier {
  LazyAllyController({
    required this.light,
    required this.dark,
    this.extraDark,
    // Kept as a plain parameter, not `this._colorBlindPalette` (see the
    // ignore below): a named initializing formal would rename the public
    // argument label itself to the private field name, making
    // `colorBlindPalette:` uncallable from outside this library.
    List<Color> colorBlindPalette = kOkabeItoPalette,
    double textScaleMin = 0.85,
    double textScaleMax = 1.6,
    double? textScaleDefault,
    String? initialMode,
    bool initialColorBlind = false,
  }) : assert(
         textScaleMin <= textScaleMax,
         'textScaleMin ($textScaleMin) must be <= textScaleMax ($textScaleMax)',
       ),
       // ignore: prefer_initializing_formals
       _colorBlindPalette = colorBlindPalette,
       _textScaleMin = textScaleMin,
       _textScaleMax = textScaleMax,
       _hadExplicitTextScaleDefault = textScaleDefault != null,
       _mode = initialMode ?? kLazyAllyLight,
       _colorBlind = initialColorBlind,
       _textScaleFactor = _clampD(
         textScaleDefault ?? 1.0,
         textScaleMin,
         textScaleMax,
       );

  /// Required light theme. Stock [ThemeData] — LazyAlly does not invent a
  /// parallel theme type; assign it exactly like `MaterialApp.theme`.
  final ThemeData light;

  /// Required dark theme.
  final ThemeData dark;

  /// Optional "extra dark" / true-black theme. Falls back to [dark] when a
  /// consumer selects [kLazyAllyExtraDark] and this is unset.
  final ThemeData? extraDark;

  final List<Color> _colorBlindPalette;
  final double _textScaleMin;
  final double _textScaleMax;
  final bool _hadExplicitTextScaleDefault;

  String _mode;
  bool _colorBlind;
  double _textScaleFactor;
  bool _seededFromSystem = false;

  /// The currently selected mode. One of [kLazyAllyLight], [kLazyAllyDark],
  /// [kLazyAllyExtraDark], or (from a planned custom-theme registry onward) a
  /// custom registered name.
  String get mode => _mode;

  /// Whether color-blind-safe semantic colors are active.
  bool get colorBlind => _colorBlind;

  /// The active text scale factor, always within [textScaleMin]..[textScaleMax].
  double get textScaleFactor => _textScaleFactor;

  double get textScaleMin => _textScaleMin;
  double get textScaleMax => _textScaleMax;

  /// The resolved [ThemeData] for the current [mode].
  ThemeData get activeTheme {
    if (_mode == kLazyAllyExtraDark) return extraDark ?? dark;
    if (_mode == kLazyAllyDark) return dark;
    return light;
  }

  void setMode(String mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }

  void setColorBlind(bool value) {
    if (value == _colorBlind) return;
    _colorBlind = value;
    notifyListeners();
  }

  void setTextScaleFactor(double value) {
    final clamped = _clampD(value, _textScaleMin, _textScaleMax);
    if (clamped == _textScaleFactor) return;
    _textScaleFactor = clamped;
    notifyListeners();
  }

  /// Seeds the initial text scale factor from the ambient OS text scaler
  /// (`MediaQuery.textScalerOf`), **composing with rather than discarding**
  /// the system's own accessibility setting. Called once by [LazyAlly] on
  /// first build; a no-op if the app already passed an explicit
  /// `textScaleDefault`, or if it's already been seeded once.
  void seedFromSystemTextScale(double systemFactor) {
    if (_seededFromSystem || _hadExplicitTextScaleDefault) return;
    _seededFromSystem = true;
    final clamped = _clampD(systemFactor, _textScaleMin, _textScaleMax);
    if (clamped != _textScaleFactor) {
      _textScaleFactor = clamped;
      notifyListeners();
    }
  }

  /// Resolves [original] to a color-blind-safe color from the Okabe-Ito (or
  /// custom) palette when [colorBlind] is on; returns [original] unchanged
  /// otherwise. Intended for **semantic/data colors** (chart series, status
  /// tags, category chips) — not for [ThemeData]'s neutral surfaces, which
  /// stay contrast-driven regardless of this flag.
  Color cvdSafeColor(Color original, int domainIndex) {
    if (!_colorBlind) return original;
    return _colorBlindPalette[domainIndex % _colorBlindPalette.length];
  }
}
