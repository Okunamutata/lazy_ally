import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_ally/lazy_ally.dart';

void main() {
  final light = ThemeData.light();
  final dark = ThemeData.dark();
  final extraDark = ThemeData.dark(useMaterial3: true);

  group('mode resolution', () {
    test('defaults to light', () {
      final c = LazyAllyController(light: light, dark: dark);
      expect(c.mode, kLazyAllyLight);
      expect(c.activeTheme, light);
    });

    test('setMode switches the active theme and notifies', () {
      final c = LazyAllyController(light: light, dark: dark);
      var notified = 0;
      c.addListener(() => notified++);

      c.setMode(kLazyAllyDark);

      expect(c.mode, kLazyAllyDark);
      expect(c.activeTheme, dark);
      expect(notified, 1);
    });

    test('setMode is a no-op (no notify) when unchanged', () {
      final c = LazyAllyController(light: light, dark: dark);
      var notified = 0;
      c.addListener(() => notified++);

      c.setMode(kLazyAllyLight);

      expect(notified, 0);
    });

    test('extraDark falls back to dark when unset', () {
      final c = LazyAllyController(light: light, dark: dark);
      c.setMode(kLazyAllyExtraDark);
      expect(c.activeTheme, dark);
    });

    test('extraDark resolves to its own theme when provided', () {
      final c = LazyAllyController(
        light: light,
        dark: dark,
        extraDark: extraDark,
      );
      c.setMode(kLazyAllyExtraDark);
      expect(c.activeTheme, extraDark);
    });
  });

  group('color-blind flag is orthogonal to mode', () {
    test('toggling color-blind does not change mode', () {
      final c = LazyAllyController(
        light: light,
        dark: dark,
        initialMode: kLazyAllyDark,
      );
      c.setColorBlind(true);
      expect(c.mode, kLazyAllyDark);
      expect(c.colorBlind, isTrue);
    });

    test('cvdSafeColor returns the original color when off', () {
      final c = LazyAllyController(light: light, dark: dark);
      const original = Color(0xFF123456);
      expect(c.cvdSafeColor(original, 0), original);
    });

    test('cvdSafeColor returns Okabe-Ito palette entries when on', () {
      final c = LazyAllyController(
        light: light,
        dark: dark,
        initialColorBlind: true,
      );
      expect(c.cvdSafeColor(const Color(0xFF123456), 0), kOkabeItoPalette[0]);
      expect(c.cvdSafeColor(const Color(0xFF123456), 1), kOkabeItoPalette[1]);
    });

    test('cvdSafeColor wraps around the palette length', () {
      final c = LazyAllyController(
        light: light,
        dark: dark,
        initialColorBlind: true,
      );
      final index = kOkabeItoPalette.length + 2;
      expect(
        c.cvdSafeColor(const Color(0xFF123456), index),
        kOkabeItoPalette[2],
      );
    });
  });

  group('text scale', () {
    test('defaults to 1.0 when no default is given', () {
      final c = LazyAllyController(light: light, dark: dark);
      expect(c.textScaleFactor, 1.0);
    });

    test('setTextScaleFactor clamps to the configured range', () {
      final c = LazyAllyController(
        light: light,
        dark: dark,
        textScaleMin: 0.8,
        textScaleMax: 1.4,
      );

      c.setTextScaleFactor(3.0);
      expect(c.textScaleFactor, 1.4);

      c.setTextScaleFactor(0.1);
      expect(c.textScaleFactor, 0.8);
    });

    test(
      'seedFromSystemTextScale applies once when no explicit default given',
      () {
        final c = LazyAllyController(light: light, dark: dark);
        c.seedFromSystemTextScale(1.3);
        expect(c.textScaleFactor, 1.3);

        // A second call must not override a value the user may have since set.
        c.setTextScaleFactor(1.1);
        c.seedFromSystemTextScale(2.0);
        expect(c.textScaleFactor, 1.1);
      },
    );

    test(
      'seedFromSystemTextScale is a no-op when an explicit default was given',
      () {
        final c = LazyAllyController(
          light: light,
          dark: dark,
          textScaleDefault: 1.2,
        );
        c.seedFromSystemTextScale(1.6);
        expect(c.textScaleFactor, 1.2);
      },
    );

    test('constructor asserts textScaleMin <= textScaleMax', () {
      expect(
        () => LazyAllyController(
          light: light,
          dark: dark,
          textScaleMin: 2.0,
          textScaleMax: 1.0,
        ),
        throwsAssertionError,
      );
    });
  });
}
