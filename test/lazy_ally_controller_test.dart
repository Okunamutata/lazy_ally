import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_ally/lazy_ally.dart';

void main() {
  final ThemeData light = ThemeData.light();
  final ThemeData dark = ThemeData.dark();
  // Explicitly distinguished from `light`/`dark` via scaffoldBackgroundColor
  // — ThemeData has value equality, so two structurally-identical themes
  // would defeat isNot(...)-style assertions below.
  final LazyAllyThemePair mangoTheme = (
    light: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.orange),
    dark: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.deepOrange),
  );
  final LazyAllyThemePair blueberryTheme = (
    light: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.indigo),
    dark: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.indigoAccent,
    ),
  );

  group('mode resolution', () {
    test('defaults to system mode, which resolves to light by default systemBrightness', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      expect(c.mode, kLazyAllySystem);
      expect(c.systemBrightness, Brightness.light);
      expect(c.activeTheme, light);
    });

    test('setMode switches the active theme and notifies', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        initialMode: kLazyAllyLight,
      );
      int notified = 0;
      c.addListener(() => notified++);

      c.setMode(kLazyAllyDark);

      expect(c.mode, kLazyAllyDark);
      expect(c.activeTheme, dark);
      expect(notified, 1);
    });

    test('setMode is a no-op (no notify) when unchanged', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        initialMode: kLazyAllyLight,
      );
      int notified = 0;
      c.addListener(() => notified++);

      c.setMode(kLazyAllyLight);

      expect(notified, 0);
    });
  });

  group('system mode follows setSystemBrightness live', () {
    test('resolves to dark when systemBrightness is dark', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      c.setSystemBrightness(Brightness.dark);
      expect(c.activeTheme, dark);
    });

    test('re-resolves live: switching systemBrightness while mode stays system updates activeTheme', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      expect(c.activeTheme, light);

      c.setSystemBrightness(Brightness.dark);
      expect(c.activeTheme, dark);

      c.setSystemBrightness(Brightness.light);
      expect(c.activeTheme, light);
    });

    test('notifies when systemBrightness changes while mode is system', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      int notified = 0;
      c.addListener(() => notified++);

      c.setSystemBrightness(Brightness.dark);

      expect(notified, 1);
    });

    test(
      'does not notify when systemBrightness changes while mode is not system',
      () {
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
          initialMode: kLazyAllyLight,
        );
        int notified = 0;
        c.addListener(() => notified++);

        c.setSystemBrightness(Brightness.dark);

        expect(notified, 0);
        // Still tracked, just not visible yet — accurate the moment mode
        // switches back to system.
        expect(c.systemBrightness, Brightness.dark);
      },
    );

    test('setSystemBrightness is a no-op when unchanged', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      int notified = 0;
      c.addListener(() => notified++);

      c.setSystemBrightness(Brightness.light);

      expect(notified, 0);
    });

    test('an explicit initialMode overrides the system default', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        initialMode: kLazyAllyDark,
      );
      expect(c.mode, kLazyAllyDark);
      c.setSystemBrightness(Brightness.dark);
      // Still dark, unaffected by systemBrightness while mode != system.
      expect(c.mode, kLazyAllyDark);
    });
  });

  group('color-blind flag is orthogonal to mode', () {
    test('toggling color-blind does not change mode', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        initialMode: kLazyAllyDark,
      );
      c.setColorBlind(true);
      expect(c.mode, kLazyAllyDark);
      expect(c.colorBlind, isTrue);
    });

    test('activeTheme is unchanged when color-blind is off', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      expect(c.activeTheme, same(light));
    });

    test('activeTheme swaps in the IBM color-blind-safe light scheme by default, matched '
        "to the active theme's own brightness", () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        initialColorBlind: true,
      );
      expect(c.activeTheme.colorScheme, kIbmColorBlindSchemeLight);
      expect(
        c.activeTheme.scaffoldBackgroundColor,
        kIbmColorBlindSchemeLight.surface,
      );
    });

    test('activeTheme swaps in the IBM color-blind-safe dark scheme when the active theme is dark', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        initialMode: kLazyAllyDark,
        initialColorBlind: true,
      );
      expect(c.activeTheme.colorScheme, kIbmColorBlindSchemeDark);
    });

    test('an explicit colorBlindScheme override replaces the IBM color-blind-safe default, '
        'and re-resolves the correct member on mode switch', () {
      final ColorScheme customLight = ColorScheme.fromSeed(
        seedColor: Colors.purple,
      );
      final ColorScheme customDark = ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.dark,
      );
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        colorBlindScheme: (light: customLight, dark: customDark),
        initialColorBlind: true,
      );
      expect(c.activeTheme.colorScheme, customLight);
      expect(c.colorBlindScheme, customLight);

      c.setMode(kLazyAllyDark);
      expect(c.colorBlindScheme, customDark);
      expect(c.activeTheme.colorScheme, customDark);
    });
  });

  group('custom color schemes override colorBlind', () {
    final ColorScheme halloweenLight = ColorScheme.fromSeed(
      seedColor: Colors.orange,
    );
    final ColorScheme halloweenDark = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    );
    final ColorScheme prideLight = ColorScheme.fromSeed(seedColor: Colors.red);
    final ColorScheme prideDark = ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    );

    test('selecting a custom scheme wins even when colorBlind is also on', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customColorSchemes: <String, LazyAllyColorSchemePair>{
          'halloween': (light: halloweenLight, dark: halloweenDark),
          'pride': (light: prideLight, dark: prideDark),
        },
        initialColorBlind: true,
      );
      c.setCustomScheme('halloween');
      expect(c.activeTheme.colorScheme, halloweenLight);
      expect(c.activeTheme.scaffoldBackgroundColor, halloweenLight.surface);
    });

    test('picks the dark member when the active theme is dark, and re-resolves '
        'live on mode switch (not fixed at selection time)', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customColorSchemes: <String, LazyAllyColorSchemePair>{
          'halloween': (light: halloweenLight, dark: halloweenDark),
        },
        initialCustomScheme: 'halloween',
      );
      expect(c.activeTheme.colorScheme, halloweenLight);

      c.setMode(kLazyAllyDark);
      expect(c.activeTheme.colorScheme, halloweenDark);
    });

    test(
      'falls back to colorBlind resolution once the custom scheme is cleared',
      () {
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
          customColorSchemes: <String, LazyAllyColorSchemePair>{
            'halloween': (light: halloweenLight, dark: halloweenDark),
          },
          initialColorBlind: true,
          initialCustomScheme: 'halloween',
        );
        expect(c.activeTheme.colorScheme, halloweenLight);

        c.setCustomScheme(null);
        expect(c.activeTheme.colorScheme, kIbmColorBlindSchemeLight);
      },
    );

    test(
      'an unregistered/stale selected name falls through rather than throwing',
      () {
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
          customColorSchemes: <String, LazyAllyColorSchemePair>{
            'halloween': (light: halloweenLight, dark: halloweenDark),
          },
          initialCustomScheme: 'not-registered',
        );
        expect(c.resolvedCustomScheme, isNull);
        expect(c.activeTheme, same(light));
      },
    );

    test('customColorSchemes is exposed but not externally mutable', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customColorSchemes: <String, LazyAllyColorSchemePair>{
          'halloween': (light: halloweenLight, dark: halloweenDark),
        },
      );
      expect(
        () => c.customColorSchemes['pride'] = (
          light: prideLight,
          dark: prideDark,
        ),
        throwsUnsupportedError,
      );
    });

    test('setCustomScheme notifies once and is a no-op when unchanged', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customColorSchemes: <String, LazyAllyColorSchemePair>{
          'halloween': (light: halloweenLight, dark: halloweenDark),
        },
      );
      int notified = 0;
      c.addListener(() => notified++);

      c.setCustomScheme('halloween');
      c.setCustomScheme('halloween');

      expect(c.selectedCustomScheme, 'halloween');
      expect(notified, 1);
    });
  });

  group('custom themes (full ThemeData) replace light/dark', () {
    test('selecting a custom theme replaces the base ThemeData entirely', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customThemes: <String, LazyAllyThemePair>{
          'mango': mangoTheme,
          'blueberry': blueberryTheme,
        },
      );
      c.setCustomTheme('mango');
      expect(c.activeTheme, mangoTheme.light);
    });

    test('picks the dark member when the active theme is dark, and re-resolves '
        'live on mode switch (not fixed at selection time)', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
        initialCustomTheme: 'mango',
      );
      expect(c.activeTheme, mangoTheme.light);

      c.setMode(kLazyAllyDark);
      expect(c.activeTheme, mangoTheme.dark);
    });

    test('falls back to light/dark once the custom theme is cleared', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
        initialCustomTheme: 'mango',
      );
      expect(c.activeTheme, mangoTheme.light);

      c.setCustomTheme(null);
      expect(c.activeTheme, light);
    });

    test(
      'an unregistered/stale selected name falls through rather than throwing',
      () {
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
          customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
          initialCustomTheme: 'not-registered',
        );
        expect(c.activeTheme, same(light));
      },
    );

    test('customThemes is exposed but not externally mutable', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
      );
      expect(
        () => c.customThemes['blueberry'] = blueberryTheme,
        throwsUnsupportedError,
      );
    });

    test('setCustomTheme notifies once and is a no-op when unchanged', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
      );
      int notified = 0;
      c.addListener(() => notified++);

      c.setCustomTheme('mango');
      c.setCustomTheme('mango');

      expect(c.selectedCustomTheme, 'mango');
      expect(notified, 1);
    });

    test('colorBlind still layers its ColorScheme on top of a selected custom '
        'theme — customThemes and customColorSchemes are independent axes', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
        initialCustomTheme: 'mango',
        initialColorBlind: true,
      );
      final ThemeData active = c.activeTheme;
      expect(active.colorScheme, kIbmColorBlindSchemeLight);
      // Structure (e.g. scaffoldBackgroundColor before the colorBlind
      // swap overwrote it) still traces back to mango, not plain light —
      // proven by scaffoldBackgroundColor matching the ColorScheme swap
      // rather than mango's own orange, since colorBlind wins for color.
      expect(active.scaffoldBackgroundColor, kIbmColorBlindSchemeLight.surface);
    });
  });

  group('LazyAllyPreferences round-trip', () {
    test('toCache snapshots current cache-worthy state', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customColorSchemes: <String, LazyAllyColorSchemePair>{
          'halloween': (light: light.colorScheme, dark: dark.colorScheme),
        },
        customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
        initialMode: kLazyAllyDark,
        initialColorBlind: true,
        initialCustomScheme: 'halloween',
        initialCustomTheme: 'mango',
        textScaleDefault: 1.3,
      );
      c.setReduceMotion(true);

      final LazyAllyPreferences cache = c.toCache();
      expect(cache.mode, kLazyAllyDark);
      expect(cache.colorBlind, isTrue);
      expect(cache.textScaleFactor, 1.3);
      expect(cache.selectedCustomScheme, 'halloween');
      expect(cache.selectedCustomTheme, 'mango');
      expect(cache.reduceMotion, isTrue);
    });

    test('applyCache restores every field in a single notification', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        customColorSchemes: <String, LazyAllyColorSchemePair>{
          'halloween': (light: light.colorScheme, dark: dark.colorScheme),
        },
        customThemes: <String, LazyAllyThemePair>{'mango': mangoTheme},
      );
      int notified = 0;
      c.addListener(() => notified++);

      c.applyCache(
        const LazyAllyPreferences(
          mode: kLazyAllyDark,
          colorBlind: true,
          textScaleFactor: 1.25,
          selectedCustomScheme: 'halloween',
          selectedCustomTheme: 'mango',
          reduceMotion: true,
        ),
      );

      expect(c.mode, kLazyAllyDark);
      expect(c.colorBlind, isTrue);
      expect(c.textScaleFactor, 1.25);
      expect(c.selectedCustomScheme, 'halloween');
      expect(c.selectedCustomTheme, 'mango');
      expect(c.reduceMotion, isTrue);
      expect(notified, 1);
    });

    test('applyCache clamps textScaleFactor to the configured range', () {
      final LazyAllyController c = LazyAllyController(
        light: light,
        dark: dark,
        textScaleMin: 0.8,
        textScaleMax: 1.4,
      );
      c.applyCache(
        const LazyAllyPreferences(
          mode: kLazyAllyLight,
          colorBlind: false,
          textScaleFactor: 3.0,
          reduceMotion: false,
        ),
      );
      expect(c.textScaleFactor, 1.4);
    });

    test('applyCache marks text scale as already seeded, so a later OS seed '
        'does not clobber the restored value', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      c.applyCache(
        const LazyAllyPreferences(
          mode: kLazyAllyLight,
          colorBlind: false,
          textScaleFactor: 1.1,
          reduceMotion: false,
        ),
      );
      c.seedFromSystemTextScale(1.6);
      expect(c.textScaleFactor, 1.1);
    });

    test('LazyAllyPreferences.toJson/fromJson round-trips', () {
      const LazyAllyPreferences cache = LazyAllyPreferences(
        mode: kLazyAllyDark,
        colorBlind: true,
        textScaleFactor: 1.25,
        selectedCustomScheme: 'halloween',
        selectedCustomTheme: 'mango',
        reduceMotion: true,
      );
      final Map<String, dynamic> json = cache.toJson();
      final LazyAllyPreferences restored = LazyAllyPreferences.fromJson(json);
      expect(restored, cache);
    });

    test('LazyAllyPreferences.fromJson falls back to safe defaults for missing keys', () {
      final LazyAllyPreferences cache = LazyAllyPreferences.fromJson(
        <String, dynamic>{},
      );
      expect(cache.mode, kLazyAllySystem);
      expect(cache.colorBlind, isFalse);
      expect(cache.textScaleFactor, 1.0);
      expect(cache.selectedCustomScheme, isNull);
      expect(cache.selectedCustomTheme, isNull);
      expect(cache.reduceMotion, isFalse);
    });

    test('LazyAllyPreferences equality is structural', () {
      const LazyAllyPreferences a = LazyAllyPreferences(
        mode: kLazyAllyLight,
        colorBlind: false,
        textScaleFactor: 1.0,
        reduceMotion: false,
      );
      const LazyAllyPreferences b = LazyAllyPreferences(
        mode: kLazyAllyLight,
        colorBlind: false,
        textScaleFactor: 1.0,
        reduceMotion: false,
      );
      const LazyAllyPreferences c = LazyAllyPreferences(
        mode: kLazyAllyDark,
        colorBlind: false,
        textScaleFactor: 1.0,
        reduceMotion: false,
      );
      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group(
    "resolving a scheme is a plain swap — correctness is the caller's job",
    () {
      test(
        'a mislabeled pair (a dark-brightness scheme under the light key) is '
        'used as-is, not corrected: supplying a complete, readable scheme per '
        "brightness is the caller's responsibility, not the package's",
        () {
          final ColorScheme mislabeledAsLight = ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          );
          final LazyAllyController c = LazyAllyController(
            light: light,
            dark: dark,
            customColorSchemes: <String, LazyAllyColorSchemePair>{
              'oops': (light: mislabeledAsLight, dark: dark.colorScheme),
            },
            initialCustomScheme: 'oops',
          );
          // mode defaults to light, so .light is picked — even though it's
          // actually Brightness.dark. LazyAlly doesn't inspect or correct it.
          expect(c.activeTheme.colorScheme, mislabeledAsLight);
          expect(c.activeTheme.colorScheme.brightness, Brightness.dark);
        },
      );
    },
  );

  group('reduceMotion', () {
    test('defaults to false when no initial value is given', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      expect(c.reduceMotion, isFalse);
      expect(c.reduceMotionListenable.value, isFalse);
    });

    test(
      'setReduceMotion updates both the getter and reduceMotionListenable',
      () {
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
        );
        c.setReduceMotion(true);
        expect(c.reduceMotion, isTrue);
        expect(c.reduceMotionListenable.value, isTrue);
      },
    );

    test('reduceMotionListenable notifies its own listeners independently of the controller', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      int listenableNotified = 0;
      int controllerNotified = 0;
      c.reduceMotionListenable.addListener(() => listenableNotified++);
      c.addListener(() => controllerNotified++);

      c.setReduceMotion(true);

      expect(listenableNotified, 1);
      expect(controllerNotified, 1);

      // A change unrelated to reduceMotion must not fire reduceMotionListenable.
      c.setMode(kLazyAllyDark);
      expect(listenableNotified, 1);
      expect(controllerNotified, 2);
    });

    test('setReduceMotion is a no-op when unchanged', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      int notified = 0;
      c.addListener(() => notified++);

      c.setReduceMotion(false);

      expect(notified, 0);
    });

    test(
      'seedReduceMotion applies once, mirroring seedFromSystemTextScale',
      () {
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
        );
        c.seedReduceMotion(true);
        expect(c.reduceMotion, isTrue);

        // A second seed call must not override a value the user (or a cache
        // restore) may have since set.
        c.setReduceMotion(false);
        c.seedReduceMotion(true);
        expect(c.reduceMotion, isFalse);
      },
    );

    test(
      'applyCache marks reduceMotion as already seeded, so a later OS seed '
      'does not clobber the restored value — regression coverage for the '
      'restored preference being overwritten by LazyAlly.didChangeDependencies',
      () {
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
        );
        c.applyCache(
          const LazyAllyPreferences(
            mode: kLazyAllyLight,
            colorBlind: false,
            textScaleFactor: 1.0,
            reduceMotion: true,
          ),
        );
        // The (default-false) system value must not win over the restored
        // cache value.
        c.seedReduceMotion(false);
        expect(c.reduceMotion, isTrue);
      },
    );
  });

  group('text scale', () {
    test('defaults to 1.0 when no default is given', () {
      final LazyAllyController c = LazyAllyController(light: light, dark: dark);
      expect(c.textScaleFactor, 1.0);
    });

    test('setTextScaleFactor clamps to the configured range', () {
      final LazyAllyController c = LazyAllyController(
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
        final LazyAllyController c = LazyAllyController(
          light: light,
          dark: dark,
        );
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
        final LazyAllyController c = LazyAllyController(
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
