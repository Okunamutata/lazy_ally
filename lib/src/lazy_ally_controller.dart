import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/domain/lazy_ally_preferences.dart';
import 'package:lazy_ally/src/colors/ibm_color_blind.dart';

part 'controller/lazy_ally_controller_brightness.dart';
part 'controller/lazy_ally_controller_color_blind.dart';
part 'controller/lazy_ally_controller_custom_schemes.dart';
part 'controller/lazy_ally_controller_custom_themes.dart';
part 'controller/lazy_ally_controller_reduce_motion.dart';
part 'controller/lazy_ally_controller_text_scale.dart';

// region Modes
/// [LazyAllyController.mode] values. LazyAlly supports only these three
/// modes. For a variant such as "extra dark", register a named
/// [LazyAllyController.customThemes] entry instead.
const String kLazyAllyLight = 'light';
const String kLazyAllyDark = 'dark';

/// This mode follows the OS's own brightness live. It is the default
/// [LazyAllyController.mode].
const String kLazyAllySystem = 'system';
// endregion

// region Theme pair typedefs
/// A light/dark [ColorScheme] pair. [LazyAllyController] always resolves to
/// the member that matches the active brightness. You are responsible for
/// supplying a correct pair for each brightness.
typedef LazyAllyColorSchemePair = ({ColorScheme light, ColorScheme dark});

/// A light/dark full [ThemeData] pair. Unlike [LazyAllyColorSchemePair],
/// which swaps only [ThemeData.colorScheme], a selected pair *is* the base
/// theme.
typedef LazyAllyThemePair = ({ThemeData light, ThemeData dark});
// endregion

double _clampD(double value, double lo, double hi) {
  if (value < lo) return lo;
  if (value > hi) return hi;
  return value;
}

// region LazyAllyController
/// Holds LazyAlly's theme selection, color-blind flag, and text-scale
/// state. This class notifies listeners on every change.
///
/// The implementation is split across `lazy_ally_controller_*.dart` part
/// files by concern: brightness, color-blind, custom schemes and themes,
/// text scale, and reduce motion. It is still one class, one library, and
/// one set of instance state.
class LazyAllyController extends ChangeNotifier
    with
        _BrightnessMixin,
        _ColorBlindMixin,
        _CustomSchemesMixin,
        _CustomThemesMixin,
        _TextScaleMixin,
        _ReduceMotionMixin {
  LazyAllyController({
    required this.light,
    required this.dark,
    LazyAllyColorSchemePair? colorBlindScheme,
    Map<String, LazyAllyColorSchemePair> customColorSchemes =
        const <String, LazyAllyColorSchemePair>{},
    String? initialCustomScheme,
    Map<String, LazyAllyThemePair> customThemes =
        const <String, LazyAllyThemePair>{},
    String? initialCustomTheme,
    double textScaleMin = 0.85,
    double textScaleMax = 1.6,
    double? textScaleDefault,
    String? initialMode,
    bool initialColorBlind = false,
  }) : assert(
         textScaleMin <= textScaleMax,
         'textScaleMin ($textScaleMin) must be <= textScaleMax ($textScaleMax)',
       ) {
    _colorBlindScheme = colorBlindScheme;
    _customColorSchemes = Map<String, LazyAllyColorSchemePair>.unmodifiable(
      customColorSchemes,
    );
    _selectedCustomScheme = initialCustomScheme;
    _customThemes = Map<String, LazyAllyThemePair>.unmodifiable(customThemes);
    _selectedCustomTheme = initialCustomTheme;
    _textScaleMin = textScaleMin;
    _textScaleMax = textScaleMax;
    _hadExplicitTextScaleDefault = textScaleDefault != null;
    _mode = initialMode ?? kLazyAllySystem;
    _colorBlind = initialColorBlind;
    _textScaleFactor = _clampD(
      textScaleDefault ?? 1.0,
      textScaleMin,
      textScaleMax,
    );
    _reduceMotionNotifier = ValueNotifier<bool>(false);
  }

  /// A plain [ThemeData]. Assign it exactly as you would assign
  /// `MaterialApp.theme`.
  final ThemeData light;

  /// Required dark theme.
  final ThemeData dark;

  /// Resolution order: if selected, [resolvedCustomScheme] overrides
  /// [colorBlind] entirely. Otherwise, [colorBlind] applies
  /// [colorBlindScheme]. Either way, LazyAlly updates
  /// `scaffoldBackgroundColor` to match, because [ThemeData] otherwise
  /// bakes that color in from the original scheme.
  ThemeData get activeTheme {
    final ThemeData base = _baseTheme;
    final ColorScheme? custom = resolvedCustomScheme;
    if (custom != null) return _withScheme(base, custom);
    if (!_colorBlind) return base;
    return _withScheme(base, colorBlindScheme);
  }

  static ThemeData _withScheme(ThemeData base, ColorScheme scheme) => base
      .copyWith(colorScheme: scheme, scaffoldBackgroundColor: scheme.surface);

  ThemeData get _baseTheme {
    final bool isDark = _resolvedBrightness == Brightness.dark;
    final LazyAllyThemePair? custom = _selectedCustomTheme == null
        ? null
        : _customThemes[_selectedCustomTheme];
    if (custom != null) return isDark ? custom.dark : custom.light;
    return isDark ? dark : light;
  }

  /// A snapshot of cache-worthy state for `LazyAlly.onCacheChanged`.
  LazyAllyPreferences toCache() => LazyAllyPreferences(
    mode: _mode,
    colorBlind: _colorBlind,
    textScaleFactor: _textScaleFactor,
    selectedCustomScheme: _selectedCustomScheme,
    selectedCustomTheme: _selectedCustomTheme,
    reduceMotion: reduceMotion,
  );

  /// Restores every cache-worthy field in one notification. Unregistered
  /// scheme or theme names fall through instead of throwing an error. This
  /// method clamps the text scale. It also marks text scale and reduce
  /// motion as seeded, so a later OS seed (see `LazyAlly`'s
  /// `didChangeDependencies`) does not overwrite either restored value.
  void applyCache(LazyAllyPreferences cache) {
    _mode = cache.mode;
    _colorBlind = cache.colorBlind;
    _textScaleFactor = _clampD(
      cache.textScaleFactor,
      _textScaleMin,
      _textScaleMax,
    );
    _selectedCustomScheme = cache.selectedCustomScheme;
    _selectedCustomTheme = cache.selectedCustomTheme;
    _seededFromSystem = true;
    _reduceMotionSeeded = true;
    _reduceMotionNotifier.value = cache.reduceMotion;
    notifyListeners();
  }

  @override
  void dispose() {
    _reduceMotionNotifier.dispose();
    super.dispose();
  }
}

// endregion
