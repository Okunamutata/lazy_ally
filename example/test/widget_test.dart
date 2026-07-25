import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_ally/lazy_ally.dart';

import 'package:lazy_ally_example/main.dart';

void main() {
  testWidgets('example app boots into HomePage with LazyAlly scope available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      LazyAlly(
        light: ThemeData.light(),
        dark: ThemeData.dark(),
        child: const ExampleApp(),
      ),
    );

    expect(find.byType(HomePage), findsOneWidget);
    // Appearance/color-blind/text-scale controls live inside LazyAllyPanel
    // now (opened via the FAB) — HomePage itself doesn't duplicate them
    // inline, so this checks something HomePage does render directly.
    expect(find.text('Active theme colors'), findsOneWidget);
  });

  testWidgets('switching the appearance segment updates the active theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      LazyAlly(
        light: ThemeData.light(),
        dark: ThemeData.dark(),
        initialMode: kLazyAllyLight,
        // Avoids pumpAndSettle hanging below: MotionExamplesSection has two
        // continuously-repeating AnimationControllers (by design, until
        // reduce-motion is on), which pumpAndSettle would otherwise wait
        // forever for.
        initiallyDisableAnimation: true,
        child: const ExampleApp(),
      ),
    );

    final Element context = tester.element(find.byType(HomePage));
    expect(context.lazyAlly.mode, kLazyAllyLight);

    // Brightness controls live inside LazyAllyPanel (opened via the FAB) —
    // HomePage doesn't place LazyAllyBrightnessSelector inline itself.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(context.lazyAlly.mode, kLazyAllyDark);
  });

  testWidgets(
    'the FAB opens a bottom sheet containing LazyAllyPanel, built entirely '
    'by the app (not the package) — regression coverage for the atomic '
    'widgets needing a real Navigator/Directionality ancestor, which they '
    'get here because the app places them, not LazyAlly. '
    'LazyAllyCustomSchemeSelector is deliberately absent — it is no longer '
    'part of the default panel.',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          initiallyDisableAnimation: true,
          child: const ExampleApp(),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LazyAllyPanel), findsOneWidget);
      // HomePage doesn't place any of these inline itself — they only come
      // from LazyAllyPanel, so a plain, unscoped findsOneWidget is enough.
      expect(find.byType(LazyAllyBrightnessSelector), findsOneWidget);
      expect(find.byType(LazyAllyTextScaleSlider), findsOneWidget);
      expect(find.byType(LazyAllyColorBlindSwitch), findsOneWidget);
      expect(find.byType(LazyAllyReduceMotionSwitch), findsOneWidget);
      // Not absent from the tree entirely — HomePage places it inline, so
      // it's still mounted behind the sheet — just not inside the panel.
      expect(
        find.descendant(
          of: find.byType(LazyAllyPanel),
          matching: find.byType(LazyAllyCustomSchemeSelector),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'LazyAllyCustomSchemeSelector, placed inline by the app rather than '
    'inside LazyAllyPanel, overrides color-blind mode end to end — '
    "exercising HomePage's own custom itemBuilder (FilterChip, capitalized "
    "labels), not the package's default ChoiceChip fallback",
    (WidgetTester tester) async {
      final ColorScheme halloweenLight = ColorScheme.fromSeed(
        seedColor: Colors.orange,
      );
      final ColorScheme halloweenDark = ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.dark,
      );
      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          customColorSchemes: <String, LazyAllyColorSchemePair>{
            'halloween': (light: halloweenLight, dark: halloweenDark),
          },
          initialColorBlind: true,
          initiallyDisableAnimation: true,
          child: const ExampleApp(),
        ),
      );

      final Element context = tester.element(find.byType(HomePage));
      expect(
        context.lazyAlly.activeTheme.colorScheme,
        kOkabeItoColorSchemeLight,
      );

      // HomePage's ListView has enough content above this section (motion
      // examples included) that neither the selector nor its chip is
      // mounted at all yet — RenderSliverList only builds children within
      // reach of the viewport's cache extent, for both the default and
      // .builder constructors alike, so a plain find.byType/skipOffstage
      // can't see them regardless of the skipOffstage value: that only
      // un-hides already-mounted offstage elements, it doesn't force more
      // of them to be built. scrollUntilVisible is the one finder that
      // tolerates a target that isn't built yet — it scrolls incrementally
      // and re-checks after each step, mounting more of the list as it
      // goes, unlike ensureVisible (which needs the target already mounted
      // to measure where to scroll to in the first place).
      final Finder halloweenChip = find.widgetWithText(
        FilterChip,
        'Halloween',
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(halloweenChip, 200);
      expect(
        find.byType(LazyAllyCustomSchemeSelector, skipOffstage: false),
        findsOneWidget,
      );
      // scrollUntilVisible stops as soon as the finder matches at all,
      // which can leave the target only barely on-screen (e.g. right at
      // the viewport edge) — not reliably tappable. Now that it's mounted,
      // ensureVisible can do its normal job of centering it precisely.
      await tester.ensureVisible(halloweenChip);
      await tester.pump();
      await tester.tap(halloweenChip);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(context.lazyAlly.selectedCustomScheme, 'halloween');
      // Default mode is light, so the .light member of the pair is picked.
      expect(context.lazyAlly.activeTheme.colorScheme, halloweenLight);
    },
  );

  testWidgets(
    'toggling color-blind from inside the open LazyAllyPanel sheet repaints '
    'live — regression coverage for showModalBottomSheet capturing Theme as '
    'a static snapshot at push time (InheritedTheme.capture); '
    'LazyAllyPanel re-asserts a live Theme specifically to avoid that',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          initiallyDisableAnimation: true,
          child: const ExampleApp(),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final BuildContext sheetContext = tester.element(
        find.byType(LazyAllyColorBlindSwitch),
      );
      expect(
        Theme.of(sheetContext).colorScheme,
        isNot(kOkabeItoColorSchemeLight),
      );

      await tester.tap(find.byType(LazyAllyColorBlindSwitch));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(Theme.of(sheetContext).colorScheme, kOkabeItoColorSchemeLight);
    },
  );

  testWidgets(
    'toggling reduce-motion actually reaches MediaQuery.disableAnimationsOf, '
    'not just the controller getter',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          child: const ExampleApp(),
        ),
      );

      final Element context = tester.element(find.byType(HomePage));
      expect(MediaQuery.disableAnimationsOf(context), isFalse);

      context.lazyAlly.setReduceMotion(true);
      await tester.pump();

      expect(MediaQuery.disableAnimationsOf(context), isTrue);
    },
  );

  testWidgets('LazyAllyPanel(showReduceMotion: false) hides just that row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      LazyAlly(
        light: ThemeData.light(),
        dark: ThemeData.dark(),
        child: const MaterialApp(
          home: Scaffold(body: LazyAllyPanel(showReduceMotion: false)),
        ),
      ),
    );

    expect(find.byType(LazyAllyReduceMotionSwitch), findsNothing);
    // The rest of the panel is unaffected by the flag.
    expect(find.text('System'), findsOneWidget);
    expect(find.byType(LazyAllyColorBlindSwitch), findsOneWidget);
  });

  testWidgets(
    'LazyAllyCustomThemeSelector, placed inline by the app, replaces the '
    "whole base ThemeData — exercising HomePage's own itemBuilder",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          customThemes: <String, LazyAllyThemePair>{
            'mango': (
              light: ThemeData.light().copyWith(
                scaffoldBackgroundColor: Colors.orange,
              ),
              dark: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.deepOrange,
              ),
            ),
          },
          initiallyDisableAnimation: true,
          child: const ExampleApp(),
        ),
      );

      final Element context = tester.element(find.byType(HomePage));
      // scrollUntilVisible, not ensureVisible — see the equivalent comment
      // on the LazyAllyCustomSchemeSelector test above for why.
      final Finder mangoChip = find.widgetWithText(
        FilterChip,
        'Mango',
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(mangoChip, 200);
      // See the equivalent ensureVisible follow-up on the
      // LazyAllyCustomSchemeSelector test above for why this is needed too.
      await tester.ensureVisible(mangoChip);
      await tester.pump();
      await tester.tap(mangoChip);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(context.lazyAlly.selectedCustomTheme, 'mango');
      expect(
        context.lazyAlly.activeTheme.scaffoldBackgroundColor,
        Colors.orange,
      );
    },
  );

  testWidgets(
    'LazyAlly(loadLazyAllyPreferences:) applies a restored cache once ready, and '
    'onLazyAllyPreferencesChanged fires with a fresh snapshot on further changes',
    (WidgetTester tester) async {
      final List<LazyAllyPreferences> saved = <LazyAllyPreferences>[];
      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          initiallyDisableAnimation: true,
          loadLazyAllyPreferences: () async => const LazyAllyPreferences(
            mode: kLazyAllyDark,
            colorBlind: true,
            textScaleFactor: 1.3,
            reduceMotion: false,
          ),
          onLazyAllyPreferencesChanged: (LazyAllyPreferences cache) =>
              saved.add(cache),
          child: const ExampleApp(),
        ),
      );
      // loadLazyAllyPreferences is awaited asynchronously — the first frame still shows
      // constructor defaults; pump once more to let it resolve and apply.
      await tester.pump();

      final Element context = tester.element(find.byType(HomePage));
      expect(context.lazyAlly.mode, kLazyAllyDark);
      expect(context.lazyAlly.colorBlind, isTrue);
      expect(context.lazyAlly.textScaleFactor, 1.3);
      // Restoring the cache itself is a change too, so it round-trips
      // straight back through onLazyAllyPreferencesChanged.
      expect(saved, isNotEmpty);
      expect(saved.last.mode, kLazyAllyDark);

      context.lazyAlly.setColorBlind(false);
      expect(saved.last.colorBlind, isFalse);
    },
  );

  testWidgets(
    'LazyAlly(loadLazyAllyPreferences:) returning a plain (non-async) value applies it '
    'before the first frame — no flash of constructor defaults',
    (WidgetTester tester) async {
      // Not `async` — a real pre-fetched value, same as a dev reading their
      // storage before runApp() and closing over the result.
      LazyAllyPreferences? syncloadLazyAllyPreferences() =>
          const LazyAllyPreferences(
            mode: kLazyAllyDark,
            colorBlind: true,
            textScaleFactor: 1.3,
            reduceMotion: false,
          );

      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          initiallyDisableAnimation: true,
          loadLazyAllyPreferences: syncloadLazyAllyPreferences,
          child: const ExampleApp(),
        ),
      );

      // Single pump, no follow-up — already correct on the very first frame.
      final Element context = tester.element(find.byType(HomePage));
      expect(context.lazyAlly.mode, kLazyAllyDark);
      expect(context.lazyAlly.colorBlind, isTrue);
      expect(context.lazyAlly.textScaleFactor, 1.3);
    },
  );

  testWidgets(
    'a synchronously-restored reduceMotion: true survives the OS-seed step '
    'in didChangeDependencies — regression coverage for the cache being '
    'clobbered by the (default-false) system/initiallyDisableAnimation '
    'value right after LazyAlly.applyCache restores it',
    (WidgetTester tester) async {
      LazyAllyPreferences? syncloadLazyAllyPreferences() =>
          const LazyAllyPreferences(
            mode: kLazyAllyLight,
            colorBlind: false,
            textScaleFactor: 1.0,
            reduceMotion: true,
          );

      await tester.pumpWidget(
        LazyAlly(
          light: ThemeData.light(),
          dark: ThemeData.dark(),
          // Deliberately omitted (defaults to the OS's own
          // disableAnimations, which is false in the test harness) so this
          // only passes if the restored cache value — not the system
          // default — wins.
          loadLazyAllyPreferences: syncloadLazyAllyPreferences,
          child: const ExampleApp(),
        ),
      );

      final Element context = tester.element(find.byType(HomePage));
      expect(context.lazyAlly.reduceMotion, isTrue);
    },
  );

  testWidgets(
    'onLazyAllyPreferencesChanged supplied only after the first build still '
    'gets wired up — regression coverage for a callback that becomes '
    'available later (e.g. once some async dependency resolves) being '
    'silently never attached',
    (WidgetTester tester) async {
      final List<LazyAllyPreferences> saved = <LazyAllyPreferences>[];
      final ValueNotifier<LazyAllyPreferencesWriter?> writer =
          ValueNotifier<LazyAllyPreferencesWriter?>(null);
      addTearDown(writer.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<LazyAllyPreferencesWriter?>(
          valueListenable: writer,
          builder:
              (
                BuildContext context,
                LazyAllyPreferencesWriter? onChanged,
                Widget? _,
              ) {
                return LazyAlly(
                  light: ThemeData.light(),
                  dark: ThemeData.dark(),
                  onLazyAllyPreferencesChanged: onChanged,
                  child: const ExampleApp(),
                );
              },
        ),
      );

      final Element context = tester.element(find.byType(HomePage));

      // No callback yet — nothing should be recorded.
      context.lazyAlly.setColorBlind(true);
      expect(saved, isEmpty);

      // Supply the callback via a rebuild, well after initState.
      writer.value = (LazyAllyPreferences cache) => saved.add(cache);
      await tester.pump();

      context.lazyAlly.setColorBlind(false);
      expect(saved, isNotEmpty);
      expect(saved.last.colorBlind, isFalse);
    },
  );
}
