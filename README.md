![lazy_ally banner](assets/banner.png)

# 🍊 lazy_ally

[![pub package](https://img.shields.io/pub/v/lazy_ally.svg)](https://pub.dev/packages/lazy_ally)
[![CI](https://github.com/okunamutata/lazy_ally/actions/workflows/ci.yaml/badge.svg)](https://github.com/okunamutata/lazy_ally/actions/workflows/ci.yaml)
[![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.44.0-02569B.svg)](https://flutter.dev)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The lazy way to make your Flutter app accessible: system-aware theming, color-blind support,
reduce-motion, and screen-reader announcements — done for you, in stock Flutter, one widget wide.

> **Status:** early / pre-release (`0.1.0-dev`). See [CHANGELOG.md](CHANGELOG.md).

---

## Features

- **Pure Flutter, zero extra dependencies** — built entirely on stock `ThemeData`, `ChangeNotifier`,
  and `InheritedNotifier`. No `MaterialApp` replacement, no bundled fonts, no state-management package.
- **Live system theming** — system/light/dark, synced to the OS *continuously*, not just at launch.
- **Color-blind safe by default** — the Okabe-Ito palette out of the box, contrast-correct, and
  orthogonal to brightness, so a color-blind user never gives up their light/dark preference to get it.
- **Named custom themes & color schemes** — two independent, open-ended registries: swap the whole
  `ThemeData` or just the `ColorScheme`, both resolved live against the active brightness.
- **Text scale that respects the OS** — seeds from the system's own text scaler and composes with it,
  instead of silently overriding a user's accessibility setting.
- **Reduce-motion aware controls** — built-in widgets swap to genuinely simple, non-animated
  alternatives under reduce-motion, not just a toned-down version of the same animation.
- **Screen-reader announcements** — every interactive widget announces its own state changes via
  `SemanticsService`, out of the box.
- **Ready for translation** — every string is overridable through one `LazyAllyLabels` object; no
  `intl`/`Locale` dependency required.
- **Pluggable persistence** — bring your own storage via plain `loadLazyAllyPreferences`/
  `onLazyAllyPreferencesChanged` hooks, with a documented zero-flash startup pattern.
- **Well tested** — 44 package tests + 16 example/widget tests, enforced in CI on every push.

![lazy_ally demo](assets/demo.gif)

---

## What "lazy" means here

**lazy** *(adj.)*

> I choose a lazy person to do a hard job. Because a lazy person will find an easy way to do it.
>
> — Bill Gates…
or Steve Jobs…
definitely not Mark

A `lazy_ally` widget is lazy the way a seatbelt is lazy. We measure it in what you *don't* have to build:
the harder the accessibility problem, the lazier '*easier*' the implementation & dev experience need to be.

---

## Why

- Most Flutter apps end up wiring the same three things by hand: a light/dark theme switch, some way to
keep text size sane and user-adjustable, 
- Accessible minded functionality often takes a back seat to domain specific features & shipping 
- The same accessibility problems get solved over and over again in every app.
- We saw a need for a flutter native low maintenance interface using only `ThemeData`, `ChangeNotifier`, `InheritedNotifier`, and
`BuildContext` — the same primitives you'd reach for if you wrote it yourself, if you had the time.

---

## Install

```yaml
dependencies:
  lazy_ally: ^0.1.0
```

---

## How lazy is lazy?

Ranked by how much work each one saves you — the harder the problem, the lazier the fix.

### Dynamic brightness, text scale, and color-blind support — not lazy at all 🤧

```dart
runApp(LazyAlly(light: myLightTheme, dark: myDarkTheme, child: const MyApp()));
```

### The whole accessible settings surface — extremely lazy 🥱

```dart
void main() => runApp(
      LazyAlly(
        light: myLightTheme,
        dark: myDarkTheme,
        loadLazyAllyPreferences: _loadCache,                       // persistence, your storage of choice
        onLazyAllyPreferencesChanged: _saveCache,
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: context.lazyAllyTheme,
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => const LazyAllyPanel(),
          ),
          child: const Icon(Icons.accessibility_new),
        ),
        // ...
      ),
    );
  }
}
```

That's brightness, text scale, color-blind, and reduce-motion — live, persisted, announced, and
translatable — behind one button. Full runnable version: [`example/`](example/).

---

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:lazy_ally/lazy_ally.dart';

Future<void> main() async {
  // Prefetch before runApp so loadLazyAllyPreferences below can return an
  // already-known value instead of a Future — LazyAlly then applies it in
  // initState, before the first frame, with no flash of constructor defaults.
  final LazyAllyPreferences? cachedPrefs = await readCachedLazyAllyPreferences();

  runApp(
    LazyAlly(
      light: myLightTheme,
      dark: myDarkTheme,
      // Optional — everything below has a reasonable default.
      colorBlindScheme: (light: /* ... */, dark: /* ... */),
      customColorSchemes: <String, LazyAllyColorSchemePair>{ /* ... */ },
      initialCustomScheme: 'pride',
      customThemes: <String, LazyAllyThemePair>{ /* ... */ },
      initialCustomTheme: 'mango',
      textScaleMin: 0.85,
      textScaleMax: 1.6,
      textScaleDefault: 1.0,
      initialMode: kLazyAllySystem,
      initialColorBlind: false,
      initiallyDisableAnimation: false,
      loadLazyAllyPreferences: () => cachedPrefs,
      onLazyAllyPreferencesChanged: (prefs) => /* ... */,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Works because MyApp.build's context is already a descendant of the
    // LazyAllyProvider that LazyAlly installs above it.
    return MaterialApp(
      theme: context.lazyAllyTheme,
      home: const HomePage(),
    );
  }
}
```

Read and change settings anywhere below `LazyAlly` via `context.lazyAlly`:

```dart
final ally = context.lazyAlly;
ally.setMode(kLazyAllyDark);       // kLazyAllySystem | kLazyAllyLight | kLazyAllyDark
ally.setColorBlind(true);
ally.setTextScaleFactor(1.2);      // clamped to [textScaleMin, textScaleMax]
```

`kLazyAllySystem` is the default mode and tracks the OS's live platform brightness continuously. There
is no bespoke "extra dark" mode; register a variant like that as a named `customThemes` entry instead
— see [TROUBLESHOOTING.md](TROUBLESHOOTING.md#theres-no-extra-dark-mode).

### Control widgets

`LazyAllyBrightnessSelector`, `LazyAllyTextScaleSlider`, `LazyAllyColorBlindSwitch`,
`LazyAllyReduceMotionSwitch` read and write `context.lazyAlly` directly — drop them anywhere below
`LazyAlly`. `LazyAllyPanel` is a pre-composed column of the first four, meant for a
`showModalBottomSheet`/dialog/settings-page you build and manage yourself (LazyAlly stays out of
navigation decisions):

```dart
showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (_) => const LazyAllyPanel(
    // Defaults true — set false if your app isn't ready to expose reduce
    // motion yet. The rest of the panel is unaffected.
    showReduceMotion: false,
  ),
);
```

### Non-English apps

Every LazyAlly widget defaults to English copy but accepts a `labels: LazyAllyLabels` override — chip
labels, switch titles/subtitles, panel headings, and the accessibility announcements each widget
sends. It's a plain data class, not a localization framework; build one from your own
`AppLocalizations`/ARB-generated strings and pass it to `LazyAllyPanel` (which forwards it to every
control it renders) or to an atomic widget directly. See the [`LazyAllyLabels`
dartdoc](lib/src/domain/lazy_ally_labels.dart) for every field.

### Accessibility announcements

Every interactive LazyAlly widget calls `lazyAllyAnnounce` (via `SemanticsService.sendAnnouncement`)
on state change, since selecting a new chip/switch value doesn't itself generate a spoken
confirmation. `lazyAllyAnnounce` is exported so your own custom controls (e.g. a bespoke
`itemBuilder`) can match the same standard.

---

## Common gotchas

The short version — see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for the full explanation and fix on
each:

- [First-frame flash on startup with an `async loadLazyAllyPreferences`](TROUBLESHOOTING.md#my-settings-flash-back-to-defaults-for-a-frame-on-startup)
- [Reduce motion doesn't stop *everything* from animating](TROUBLESHOOTING.md#reduce-motion-doesnt-stop-everything-from-animating)
- [A `Switch`/`Slider`-based control keeps animating regardless](TROUBLESHOOTING.md#a-toggleslider-keeps-animating-even-with-reduce-motion-on)
- [Settings changed inside a bottom sheet/dialog don't repaint](TROUBLESHOOTING.md#toggling-a-setting-from-inside-a-bottom-sheetdialog-doesnt-repaint)
- [Your own `MediaQuery(builder: ...)` shadows LazyAlly's](TROUBLESHOOTING.md#my-own-mediaquery-override-clobbers-lazyallys-text-scalereduce-motion)

---

## Design decisions

- **Color-blind is a flag, not a fourth theme.** Brightness (`system`/`light`/`dark`) and color-blind
  (`on`/`off`) are independent axes — a color-blind user keeps their light/dark preference. Turning it
  on swaps in a full `ColorScheme`, not a hand-indexed color list — named slots (`primary`,
  `secondary`, ...) are harder to misuse than `palette[i]`.
- **No bespoke brightness variants.** Only `system`/`light`/`dark` are built in. A variant like "extra
  dark" is just a named `customThemes` entry — the same open mechanism any other named theme uses.
- **Theme/scheme overrides are light/dark pairs, resolved by the package — correctness is yours.**
  LazyAlly always picks the member matching the active brightness, so a selected pair never ends up
  mismatched; it does not inspect or "fix" either member.
- **No `MaterialApp` replacement, no bundled font.** `LazyAlly` wraps your app; it doesn't ask you
  to swap widgets or pay for typography you didn't ask for.
- **No bundled storage or localization framework.** `loadLazyAllyPreferences`/`onLazyAllyPreferencesChanged` and
  `LazyAllyLabels` are plain hooks/data classes — you bring `SharedPreferences`/`intl`/whatever you
  already use.

---

## Related

If you also want **dev-time** accessibility auditing (contrast checks, tap-target size, missing
semantics) during development, pair this with
[`accessibility_tools`](https://pub.dev/packages/accessibility_tools) — a different job, complementary
rather than competing.

---

## Contact

- **Bugs & feature requests:** [GitHub Issues](https://github.com/okunamutata/lazy_ally/issues)
- **General inquiries:** [lazyfruit.dev](https://lazyfruit.dev)
- **Email:** [lazy.ally.reprise769@passmail.net](mailto:lazy.ally.reprise769@passmail.net)

<img src="assets/lazyfruit-logo.png" width="20" alt="" align="absmiddle"> Maintained by **LazyFruit** — a public-interest Flutter studio.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). This is the author's first published Dart/Flutter package —
issues, PRs, and "this API is awkward, here's why" feedback are genuinely welcome.

---

## License

MIT — see [LICENSE](LICENSE).

---

Made with ♥️ in North Carolina.
