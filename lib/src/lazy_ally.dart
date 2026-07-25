import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lazy_ally/src/domain/lazy_ally_preferences.dart';
import 'package:lazy_ally/src/lazy_ally_controller.dart';
import 'package:lazy_ally/src/lazy_ally_provider.dart';

/// Wraps an app (typically above [MaterialApp]) to provide system/light/dark
/// theming (plus an open registry of your own named [customThemes]), an
/// orthogonal IBM color-blind-safe flag, and text-scale limits — built
/// entirely on stock Flutter primitives (plain [ThemeData], a
/// [ChangeNotifier] controller, an [InheritedNotifier] scope). No
/// [MaterialApp] replacement, no bundled fonts, no state-management package
/// dependency.
///
/// Read the resolved theme and controls from a descendant via
/// `context.lazyAllyTheme` / `context.lazyAlly`:
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
/// This works because `MyApp.build`'s `context` is already a descendant of
/// the [LazyAllyProvider] that `LazyAlly` installs above it. If you construct
/// `MaterialApp` directly inline (not from its own widget's `build`), wrap it
/// in a [Builder] first so you have a context below `LazyAlly` to read from.
///
/// If your app already uses `MaterialApp(builder: ...)` for its own
/// [MediaQuery] overrides, read `context.lazyAlly.textScaleFactor` inside
/// that builder and compose it yourself — an inner [MediaQuery] takes
/// precedence over the one `LazyAlly` applies here, so the two won't combine
/// automatically.
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

  /// Required light theme. Plain [ThemeData] — assign it exactly like you
  /// would `MaterialApp.theme`.
  final ThemeData light;

  /// Required dark theme.
  final ThemeData dark;

  /// The light/dark pair swapped into [ThemeData.colorScheme] whenever
  /// color-blind mode is on — [LazyAllyController] always picks whichever
  /// member matches the active theme's current brightness. If omitted,
  /// defaults to an IBM color-blind-safe pair. Supplying a complete, correctly
  /// readable [ColorScheme] for each brightness is the caller's
  /// responsibility; LazyAlly picks between them, it doesn't inspect or
  /// correct either one.
  final LazyAllyColorSchemePair? colorBlindScheme;

  /// Dev-registered named color scheme pairs — e.g. `{'flutter': (light:
  /// ..., dark: ...), 'pride': (light: ..., dark: ...), 'halloween':
  /// (light: ..., dark: ...)}` — completely separate from
  /// [colorBlindScheme]/[initialColorBlind]. Selecting one (via
  /// `context.lazyAlly.setCustomScheme(name)`, or `LazyAllyCustomSchemeSelector`)
  /// **overrides color-blind mode**, not combines with it — see
  /// `LazyAllyController.activeTheme` for the exact resolution order. An
  /// open, expandable field: register as many as you like.
  final Map<String, LazyAllyColorSchemePair> customColorSchemes;

  /// The name of the initially-selected entry in [customColorSchemes], if
  /// any. Defaults to none (normal [colorBlind]/brightness resolution).
  final String? initialCustomScheme;

  /// Dev-registered named full-[ThemeData] pairs — e.g. `{'mango': (light:
  /// ..., dark: ...), 'blueberry': (light: ..., dark: ...)}`. Unlike
  /// [customColorSchemes] (which swaps only the [ColorScheme]), selecting
  /// one of these (via `context.lazyAlly.setCustomTheme(name)`, or
  /// `LazyAllyCustomThemeSelector`) **replaces [light]/[dark] entirely** —
  /// typography, shapes, component themes, everything. This is also where a
  /// variant like "extra dark" belongs: LazyAlly has no bespoke mode for
  /// that, register it as a named entry here instead. An open, expandable
  /// field: register as many as you like.
  final Map<String, LazyAllyThemePair> customThemes;

  /// The name of the initially-selected entry in [customThemes], if any.
  /// Defaults to none (plain [light]/[dark] resolution).
  final String? initialCustomTheme;

  /// Minimum allowed text scale factor.
  final double textScaleMin;

  /// Maximum allowed text scale factor.
  final double textScaleMax;

  /// Initial text scale factor. If omitted, the initial value is seeded from
  /// the OS's own text scaler (`MediaQuery.textScalerOf`) the first time this
  /// widget builds, so LazyAlly composes with the system accessibility
  /// setting instead of silently overriding it.
  final double? textScaleDefault;

  /// Initial brightness mode ([kLazyAllyLight], [kLazyAllyDark], or
  /// [kLazyAllySystem]). If omitted, defaults to [kLazyAllySystem] —
  /// following the OS's own brightness live, not just matching it once at
  /// startup.
  final String? initialMode;

  /// Initial color-blind flag. Defaults to off.
  final bool initialColorBlind;

  /// If true, disables the initial theme transition animation on first build.
  /// Defaults to false.
  final bool? initiallyDisableAnimation;

  /// Reads a previously-saved [LazyAllyPreferences], if any. Called once in
  /// `initState`. If it returns a `Future`, LazyAlly applies the result once
  /// it resolves — the first frame or two may briefly show constructor
  /// defaults first, and LazyAlly shows no splash to hide that gap. Return a
  /// plain (non-`async`) value instead — e.g. pre-fetch your storage before
  /// `runApp()` and have this just return the already-known value — and
  /// LazyAlly applies it in `initState`, before the first frame: no flash.
  /// Omit if you don't need persistence.
  final LazyAllyPreferencesReader? loadLazyAllyPreferences;

  /// Called with a fresh [LazyAllyPreferences] snapshot on every cache-worthy
  /// change (including a [loadLazyAllyPreferences] restore at startup). Not debounced —
  /// handle that yourself if your storage is expensive to hit often. Omit
  /// if you don't need persistence.
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
    // A genuinely synchronous loadLazyAllyPreferences (not declared `async` — an `async`
    // function always returns a Future, even if nothing inside it ever
    // really awaits) can be applied here in initState, before the first
    // build: no flash of constructor defaults. See LazyAllyPreferencesReader.
    if (result is Future<LazyAllyPreferences?>) {
      _awaitCache(result);
    } else if (result != null) {
      _controller.applyCache(result);
    }
  }

  @override
  void didUpdateWidget(covariant LazyAlly oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only the null <-> non-null transition matters here: _notifyCacheChanged
    // always reads widget.onLazyAllyPreferencesChanged fresh, so swapping one
    // non-null callback for another non-null callback needs no listener
    // change.
    _syncPersistenceListening();
  }

  /// Keeps [_controller]'s cache-change listeners attached exactly when
  /// [LazyAlly.onLazyAllyPreferencesChanged] is non-null — called from both
  /// [initState] and [didUpdateWidget] so a callback supplied (or removed)
  /// after the first build still takes effect.
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
    // May have unmounted while awaiting a real read.
    if (!mounted || cache == null) return;
    _controller.applyCache(cache);
  }

  void _notifyCacheChanged() =>
      widget.onLazyAllyPreferencesChanged?.call(_controller.toCache());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final MediaQueryData mq = MediaQuery.of(context);
    // Every dependency change, not just the first — this is what makes
    // kLazyAllySystem mode live rather than a startup snapshot.
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
            // Sourced from the controller (OS-seeded in
            // didChangeDependencies) so in-app setReduceMotion actually
            // reaches MediaQuery.disableAnimationsOf(context).
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
