import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';

/// Reads a previously-saved [LazyAllyPreferences], or `null` if there isn't
/// one yet (e.g. first launch). Supplied as `LazyAlly.loadLazyAllyPreferences` — called
/// once, in `initState`.
///
/// You decide where this reads from (`SharedPreferences`, a file, a backend
/// sync call) — LazyAlly has no opinion and no storage dependency of its
/// own. Returning a plain value (not `async`) — i.e. you already fetched it
/// before `runApp()` — lets LazyAlly apply it before the first frame, with
/// no flash of constructor defaults; see `LazyAlly.loadLazyAllyPreferences`.
typedef LazyAllyPreferencesReader = FutureOr<LazyAllyPreferences?> Function();

/// Writes a [LazyAllyPreferences] snapshot. Supplied as
/// `LazyAlly.onLazyAllyPreferencesChanged` — called every time cache-worthy
/// state changes (mode, color-blind, text scale, selected custom
/// scheme/theme, or reduce-motion).
///
/// You decide where this writes to, and whether/how to debounce rapid
/// changes (e.g. dragging the text-scale slider fires this on every step)
/// — LazyAlly calls this as plainly as the state actually changes, it does
/// not coalesce calls for you.
typedef LazyAllyPreferencesWriter =
    FutureOr<void> Function(LazyAllyPreferences cache);

/// A serializable snapshot of the parts of [LazyAllyController] worth
/// persisting across app restarts: [mode], [colorBlind], [textScaleFactor],
/// [selectedCustomScheme], [selectedCustomTheme], and [reduceMotion].
///
/// LazyAlly persists nothing itself — [LazyAlly]'s `loadLazyAllyPreferences`/
/// `onLazyAllyPreferencesChanged` hooks (see
/// [LazyAllyPreferencesReader]/[LazyAllyPreferencesWriter]) let you
/// read/write this however you like. [toJson]/[fromJson] are a sane default
/// shape; read/write the fields directly if you need a different one.
///
/// ```dart
/// LazyAlly(
///   light: myLightTheme,
///   dark: myDarkTheme,
///   loadLazyAllyPreferences: () async {
///     final prefs = await SharedPreferences.getInstance();
///     final raw = prefs.getString('lazy_ally_cache');
///     if (raw == null) return null;
///     return LazyAllyPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
///   },
///   onLazyAllyPreferencesChanged: (cache) async {
///     final prefs = await SharedPreferences.getInstance();
///     await prefs.setString('lazy_ally_cache', jsonEncode(cache.toJson()));
///   },
///   child: const MyApp(),
/// )
/// ```
@immutable
class LazyAllyPreferences {
  const LazyAllyPreferences({
    required this.mode,
    required this.colorBlind,
    required this.textScaleFactor,
    this.selectedCustomScheme,
    this.selectedCustomTheme,
    required this.reduceMotion,
  });

  /// Builds a [LazyAllyPreferences] from a JSON-decoded map — the counterpart to
  /// [toJson]. Missing or malformed keys fall back to safe defaults instead
  /// of throwing, since this typically reads back data written by a
  /// possibly-older version of your app (or, before anything was ever
  /// saved, an empty map).
  factory LazyAllyPreferences.fromJson(Map<String, dynamic> json) {
    return LazyAllyPreferences(
      mode: json['mode'] as String? ?? kLazyAllySystem,
      colorBlind: json['colorBlind'] as bool? ?? false,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
      selectedCustomScheme: json['selectedCustomScheme'] as String?,
      selectedCustomTheme: json['selectedCustomTheme'] as String?,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
    );
  }

  /// See [LazyAllyController.mode].
  final String mode;

  /// See [LazyAllyController.colorBlind].
  final bool colorBlind;

  /// See [LazyAllyController.textScaleFactor].
  final double textScaleFactor;

  /// See [LazyAllyController.selectedCustomScheme].
  final String? selectedCustomScheme;

  /// See [LazyAllyController.selectedCustomTheme].
  final String? selectedCustomTheme;

  /// See [LazyAllyController.reduceMotion].
  final bool reduceMotion;

  /// A plain, `jsonEncode`-ready map — the default serialization shape.
  /// Write your own instead (reading the fields directly) if you need a
  /// different one.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'mode': mode,
    'colorBlind': colorBlind,
    'textScaleFactor': textScaleFactor,
    'selectedCustomScheme': selectedCustomScheme,
    'selectedCustomTheme': selectedCustomTheme,
    'reduceMotion': reduceMotion,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LazyAllyPreferences &&
        other.mode == mode &&
        other.colorBlind == colorBlind &&
        other.textScaleFactor == textScaleFactor &&
        other.selectedCustomScheme == selectedCustomScheme &&
        other.selectedCustomTheme == selectedCustomTheme &&
        other.reduceMotion == reduceMotion;
  }

  @override
  int get hashCode => Object.hash(
    mode,
    colorBlind,
    textScaleFactor,
    selectedCustomScheme,
    selectedCustomTheme,
    reduceMotion,
  );

  @override
  String toString() =>
      'LazyAllyPreferences(mode: $mode, colorBlind: $colorBlind, '
      'textScaleFactor: $textScaleFactor, '
      'selectedCustomScheme: $selectedCustomScheme, '
      'selectedCustomTheme: $selectedCustomTheme, '
      'reduceMotion: $reduceMotion)';
}
