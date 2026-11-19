import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/domain/lazy_ally_preferences.dart';
import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';

/// This widget wraps an app, typically above [MaterialApp], and provides
/// system, light, and dark theming. It also supports an open registry of
/// your own named [customThemes], an independent IBM color-blind-safe
/// flag, and text-scale limits. LazyAlly builds entirely on the official
/// Flutter `material_ui` library: a plain [ThemeData], a [ChangeNotifier]
/// controller, and an [InheritedNotifier] scope. LazyAlly does not replace
/// [MaterialApp], bundle fonts, or depend on a state-management package.
///
/// Read the resolved theme and controls from a descendant widget through
/// `context.lazyAllyTheme` and `context.lazyAlly`:
///
/// ```dart
/// void main() => runApp(LazyAlly(
///       light: myLightTheme,
///       dark: myDarkTheme,
///       child: const MyApp(),
///     ));
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       theme: context.lazyAllyTheme,
///       home: const HomePage(),
///     );
///   }
/// }
/// ```
///
/// This method works because the `context` in `MyApp.build` is already a
/// descendant of the [LazyAllyProvider] that `LazyAlly` installs above it.
/// If you construct `MaterialApp` directly inline, and not from its own
/// widget's `build` method, wrap it in a [Builder] first. This gives you a
/// context below `LazyAlly` to read from.
///
/// If your app already uses `MaterialApp(builder: ...)` for its own
/// [MediaQuery] overrides, read `context.lazyAlly.textScaleFactor` inside
/// that builder and combine it yourself. An inner [MediaQuery] takes
/// precedence over the one that `LazyAlly` applies here, so the two do not
/// combine automatically.
class LazyAlly extends StatefulWidget {
  const LazyAlly({
    super.key,
    required this.light,
    required this.dark,
    this.colorBlindScheme,
    this.customColorSchemes = const <String, LazyAllyColorSchemePair>{},
    this.initialCustomScheme,
    this.customThemes = const <String, LazyAllyThemePair>{},
    this.initialCustomTheme,
    this.textScaleMin = 0.85,
    this.textScaleMax = 1.6,
    this.textScaleDefault,
    this.initialMode,
    this.initialColorBlind = false,
    this.initiallyDisableAnimation,
    this.loadLazyAllyPreferences,
    this.onLazyAllyPreferencesChanged,
    required this.child,
  });

  /// Required light theme. This is a plain [ThemeData]. Assign it exactly
  /// as you would assign `MaterialApp.theme`.
  final ThemeData light;

  /// Required dark theme.
  final ThemeData dark;

  /// This is the light/dark pair that replaces [ThemeData.colorScheme]
  /// whenever color-blind mode is on. [LazyAllyController] always picks the
  /// member that matches the active theme's current brightness. If you
  /// omit this, LazyAlly uses a default IBM color-blind-safe pair. You are
  /// responsible for supplying a complete, readable [ColorScheme] for each
  /// brightness. LazyAlly only picks between the two schemes. It does not
  /// inspect or correct either one.
  final LazyAllyColorSchemePair? colorBlindScheme;

  /// Named color scheme pairs that you register, for example `{'flutter':
  /// (light: ..., dark: ...), 'pride': (light: ..., dark: ...),
  /// 'halloween': (light: ..., dark: ...)}`. This field is completely
  /// separate from [colorBlindScheme] and [initialColorBlind]. If you
  /// select one, through `context.lazyAlly.setCustomScheme(name)` or
  /// `LazyAllyCustomSchemeSelector`, it **overrides color-blind mode**
  /// instead of combining with it. See `LazyAllyController.activeTheme`
  /// for the exact resolution order. This is an open, expandable field.
  /// Register as many entries as you need.
  final Map<String, LazyAllyColorSchemePair> customColorSchemes;

  /// The name of the initially selected entry in [customColorSchemes], if
  /// any. The default is none, so LazyAlly uses normal [colorBlind] and
  /// brightness resolution.
  final String? initialCustomScheme;

  /// Named full-[ThemeData] pairs that you register, for example
  /// `{'mango': (light: ..., dark: ...), 'blueberry': (light: ...,
  /// dark: ...)}`. Unlike [customColorSchemes], which swaps only the
  /// [ColorScheme], selecting one of these entries (through
  /// `context.lazyAlly.setCustomTheme(name)` or
  /// `LazyAllyCustomThemeSelector`) **replaces [light] and [dark]
  /// entirely**: typography, shapes, component themes, and everything
  /// else. This is also where a variant such as "extra dark" belongs.
  /// LazyAlly has no dedicated mode for that, so register it as a named
  /// entry here instead. This is an open, expandable field. Register as
  /// many entries as you need.
  final Map<String, LazyAllyThemePair> customThemes;

  /// The name of the initially selected entry in [customThemes], if any.
  /// The default is none, so LazyAlly uses plain [light] and [dark]
  /// resolution.
  final String? initialCustomTheme;

  /// Minimum allowed text scale factor.
  final double textScaleMin;

  /// Maximum allowed text scale factor.
  final double textScaleMax;

  /// Initial text scale factor. If you omit this, LazyAlly seeds the
  /// initial value from the OS's own text scaler
  /// (`MediaQuery.textScalerOf`) the first time this widget builds. This
  /// way LazyAlly combines with the system accessibility setting instead
  /// of silently overriding it.
  final double? textScaleDefault;

  /// Initial brightness mode: [kLazyAllyLight], [kLazyAllyDark], or
  /// [kLazyAllySystem]. If you omit this, the default is [kLazyAllySystem].
  /// This mode follows the OS's own brightness live, rather than matching
  /// it only once at startup.
  final String? initialMode;

  /// Initial color-blind flag. Defaults to off.
  final bool initialColorBlind;

  /// If true, LazyAlly disables the initial theme transition animation on
  /// first build. The default is false.
  final bool? initiallyDisableAnimation;

  /// Reads a previously saved [LazyAllyPreferences], if any. LazyAlly calls
  /// this once, in `initState`. If it returns a `Future`, LazyAlly applies
  /// the result once the future resolves. In that case the first frame or
  /// two may briefly show the constructor defaults, because LazyAlly shows
  /// no splash screen to hide that gap. Instead, return a plain, non-`async`
  /// value: for example, pre-fetch your storage before `runApp()` and have
  /// this callback return the already known value. LazyAlly then applies
  /// the value in `initState`, before the first frame, so there is no
  /// flash. Omit this if you do not need persistence.
  final LazyAllyPreferencesReader? loadLazyAllyPreferences;

  /// LazyAlly calls this with a fresh [LazyAllyPreferences] snapshot on
  /// every cache-worthy change, including a [loadLazyAllyPreferences]
  /// restore at startup. This callback is not debounced. Handle debouncing
  /// yourself if writing to your storage is expensive. Omit this if you do
  /// not need persistence.
  final LazyAllyPreferencesWriter? onLazyAllyPreferencesChanged;

  final Widget child;

  @override
  State<LazyAlly> createState() => _LazyAllyState();
}

class _LazyAllyState extends State<LazyAlly> {
  late final LazyAllyController _controller = LazyAllyController(
    light: widget.light,
    dark: widget.dark,
    colorBlindScheme: widget.colorBlindScheme,
    customColorSchemes: widget.customColorSchemes,
    initialCustomScheme: widget.initialCustomScheme,
    customThemes: widget.customThemes,
    initialCustomTheme: widget.initialCustomTheme,
    textScaleMin: widget.textScaleMin,
    textScaleMax: widget.textScaleMax,
    textScaleDefault: widget.textScaleDefault,
    initialMode: widget.initialMode,
    initialColorBlind: widget.initialColorBlind,
  );

  bool _seeded = false;
  bool _listeningForCacheChanges = false;

  @override
  void initState() {
    super.initState();
    _syncPersistenceListening();
    final LazyAllyPreferencesReader? loadLazyAllyPreferences =
        widget.loadLazyAllyPreferences;
    if (loadLazyAllyPreferences == null) return;
    final FutureOr<LazyAllyPreferences?> result = loadLazyAllyPreferences();
    // A genuinely synchronous loadLazyAllyPreferences, one not declared
    // `async`, can apply here in initState, before the first build. This
    // avoids a flash of constructor defaults. Note that an `async`
    // function always returns a Future, even if nothing inside it ever
    // really awaits. See LazyAllyPreferencesReader.
    if (result is Future<LazyAllyPreferences?>) {
      _awaitCache(result);
    } else if (result != null) {
      _controller.applyCache(result);
    }
  }

  @override
  void didUpdateWidget(covariant LazyAlly oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only the null-to-non-null transition matters here.
    // _notifyCacheChanged always reads widget.onLazyAllyPreferencesChanged
    // fresh, so swapping one non-null callback for another non-null
    // callback needs no listener change.
    _syncPersistenceListening();
  }

  /// Keeps [_controller]'s cache-change listeners attached exactly when
  /// [LazyAlly.onLazyAllyPreferencesChanged] is non-null. This method is
  /// called from both [initState] and [didUpdateWidget], so a callback
  /// supplied or removed after the first build still takes effect.
  void _syncPersistenceListening() {
    final bool shouldListen = widget.onLazyAllyPreferencesChanged != null;
    if (shouldListen == _listeningForCacheChanges) return;
    _listeningForCacheChanges = shouldListen;
    if (shouldListen) {
      _controller
        ..addListener(_notifyCacheChanged)
        ..reduceMotionListenable.addListener(_notifyCacheChanged);
    } else {
      _controller
        ..removeListener(_notifyCacheChanged)
        ..reduceMotionListenable.removeListener(_notifyCacheChanged);
    }
  }

  Future<void> _awaitCache(Future<LazyAllyPreferences?> pending) async {
    final LazyAllyPreferences? cache = await pending;
    // The widget may have unmounted while awaiting a real read.
    if (!mounted || cache == null) return;
    _controller.applyCache(cache);
  }

  void _notifyCacheChanged() =>
      widget.onLazyAllyPreferencesChanged?.call(_controller.toCache());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final MediaQueryData mq = MediaQuery.of(context);
    // This runs on every dependency change, not just the first. This is
    // what makes kLazyAllySystem mode live, rather than a startup
    // snapshot.
    _controller.setSystemBrightness(mq.platformBrightness);

    if (_seeded) return;
    _seeded = true;
    _controller.seedFromSystemTextScale(mq.textScaler.scale(1.0));
    _controller.seedReduceMotion(
      widget.initiallyDisableAnimation ?? mq.disableAnimations,
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_notifyCacheChanged)
      ..reduceMotionListenable.removeListener(_notifyCacheChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mq = MediaQuery.of(context);
        return LazyAllyProvider(
          controller: _controller,
          child: MediaQuery(
            // This value comes from the controller, seeded from the OS in
            // didChangeDependencies, so an in-app call to setReduceMotion
            // actually reaches MediaQuery.disableAnimationsOf(context).
            data: mq.copyWith(
              textScaler: TextScaler.linear(_controller.textScaleFactor),
              disableAnimations: _controller.reduceMotion,
            ),
            child: child!,
          ),
        );
      },
      child: widget.child,
    );
  }
}
