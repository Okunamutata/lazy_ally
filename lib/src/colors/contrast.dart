import 'package:flutter/material.dart';

/// Returns a legible foreground color (pure white or black) for [background].
/// This function uses [ThemeData.estimateBrightnessForColor] to pick the
/// result.
///
/// Use this function when you build your own [ColorScheme] for
/// `LazyAlly`'s `colorBlindScheme` or `customColorSchemes`. For example:
/// `onPrimary: lazyAllyOnColorFor(myPrimary)`. A seed-derived `onX` color
/// contrasts only against the seed's own derived hue. It does not contrast
/// against a hue you pin explicitly.
Color lazyAllyOnColorFor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? Colors.white
    : Colors.black;
