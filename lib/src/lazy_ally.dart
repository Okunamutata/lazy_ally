import 'package:flutter/material.dart';

import 'lazy_ally_controller.dart';
import 'lazy_ally_scope.dart';
import 'okabe_ito.dart';

/// Wraps an app (typically above [MaterialApp]) to provide light/dark/
/// extra-dark theming, an orthogonal Okabe-Ito color-blind flag, and
/// text-scale limits — built entirely on stock Flutter primitives (plain
/// [ThemeData], a [ChangeNotifier] controller, an [InheritedNotifier] scope).
/// No [MaterialApp] replacement, no bundled fonts, no state-management
/// package dependency.
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
/// the [LazyAllyScope] that `LazyAlly` installs above it. If you construct
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
    this.extraDark,
    this.colorBlindPalette = kOkabeItoPalette,
    this.textScaleMin = 0.85,
    this.textScaleMax = 1.6,
    this.textScaleDefault,
    this.initialMode,
    this.initialColorBlind = false,
    required this.child,
  });

  /// Required light theme. Plain [ThemeData] — assign it exactly like you
  /// would `MaterialApp.theme`.
  final ThemeData light;

  /// Required dark theme.
  final ThemeData dark;

  /// Optional "extra dark" / true-black theme. Falls back to [dark] when a
  /// consumer selects [kLazyAllyExtraDark] and this is unset.
  final ThemeData? extraDark;

  /// Color-blind-safe palette used by `context.lazyAlly.cvdSafeColor(...)`.
  /// Defaults to Okabe-Ito ([kOkabeItoPalette]).
  final List<Color> colorBlindPalette;

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
  /// [kLazyAllyExtraDark]). If omitted, defaults to the platform's brightness
  /// the first time this widget builds.
  final String? initialMode;

  /// Initial color-blind flag. Defaults to off.
  final bool initialColorBlind;

  final Widget child;

  @override
  State<LazyAlly> createState() => _LazyAllyState();
}

class _LazyAllyState extends State<LazyAlly> {
  late final LazyAllyController _controller = LazyAllyController(
    light: widget.light,
    dark: widget.dark,
    extraDark: widget.extraDark,
    colorBlindPalette: widget.colorBlindPalette,
    textScaleMin: widget.textScaleMin,
    textScaleMax: widget.textScaleMax,
    textScaleDefault: widget.textScaleDefault,
    initialMode: widget.initialMode,
    initialColorBlind: widget.initialColorBlind,
  );

  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final mq = MediaQuery.of(context);
    _controller.seedFromSystemTextScale(mq.textScaler.scale(1.0));
    if (widget.initialMode == null) {
      _controller.setMode(
        mq.platformBrightness == Brightness.dark
            ? kLazyAllyDark
            : kLazyAllyLight,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return LazyAllyScope(
          controller: _controller,
          child: MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(_controller.textScaleFactor),
            ),
            child: child!,
          ),
        );
      },
      child: widget.child,
    );
  }
}
