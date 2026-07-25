import 'package:flutter/material.dart';

/// Returns a legible foreground color (pure white or black) for [background],
/// based on [ThemeData.estimateBrightnessForColor].
///
/// Useful when building your own [ColorScheme] for `LazyAlly`'s
/// `colorBlindScheme` or `customColorSchemes` — e.g.
/// `onPrimary: lazyAllyOnColorFor(myPrimary)` — since a seed-derived `onX`
/// color is only guaranteed to contrast against the seed's *own* derived
/// hue, not a hue you've pinned explicitly.
Color lazyAllyOnColorFor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? Colors.white
    : Colors.black;
