# lazy_ally

[![pub package](https://img.shields.io/pub/v/lazy_ally.svg)](https://pub.dev/packages/lazy_ally)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Wrap your app in a `LazyAlly` widget for light/dark/extra-dark theming, an orthogonal Okabe-Ito
color-blind flag, and text-scale limits — built entirely on stock Flutter tooling. No `MaterialApp`
replacement, no bundled fonts, no state-management package dependency.

> **Status:** early / pre-release (`0.1.0-dev`). Core primitives are implemented and tested; the
> bundled control-sheet UI, pluggable storage, and custom-theme registry are still in progress. See
> [CHANGELOG.md](CHANGELOG.md).

## Why

Most Flutter apps end up wiring the same three things by hand: a light/dark theme switch, some way to
keep text size sane and user-adjustable, and — much less often, but it matters — a way to make data
and status colors distinguishable for color-blind users. `lazy_ally` is that wiring, generalized into
one widget, using only `ThemeData`, `ChangeNotifier`, `InheritedNotifier`, and `BuildContext` — the
same primitives you'd reach for if you wrote it yourself.

Color-blind support defaults to the [Okabe-Ito palette](https://jfly.uni-koeln.de/color/), chosen to
stay distinguishable under the common forms of color vision deficiency, and is **orthogonal to
brightness mode** — turning it on doesn't cost you your light/dark preference.

## Install

```yaml
dependencies:
  lazy_ally: ^0.1.0
```

(Not yet published to pub.dev — see the status note above.)

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:lazy_ally/lazy_ally.dart';

void main() => runApp(
      LazyAlly(
        light: myLightTheme,
        dark: myDarkTheme,
        // Optional — everything below has a reasonable default.
        extraDark: myExtraDarkTheme,
        textScaleMin: 0.85,
        textScaleMax: 1.6,
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Works because MyApp.build's context is already a descendant of the
    // LazyAllyScope that LazyAlly installs above it.
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
ally.setMode(kLazyAllyDark);       // kLazyAllyLight | kLazyAllyDark | kLazyAllyExtraDark
ally.setColorBlind(true);
ally.setTextScaleFactor(1.2);      // clamped to [textScaleMin, textScaleMax]

// For semantic/data colors (chart series, status tags) — not neutral chrome:
final seriesColor = ally.cvdSafeColor(myBrandColor, seriesIndex);
```

Text scale is **seeded from the OS's own text scaler** on first build (composing with system
accessibility settings), not silently overridden — see the [`LazyAlly`
dartdoc](lib/src/lazy_ally.dart) for the one integration caveat if your app already uses
`MaterialApp(builder: ...)` for its own `MediaQuery` overrides.

Full runnable demo: [`example/`](example/).

## Design decisions

- **Color-blind is a flag, not a fourth theme.** Brightness (`light`/`dark`/`extraDark`) and
  color-blind (`on`/`off`) are independent axes — a color-blind user keeps their light/dark
  preference. It's also scoped to semantic/data colors via `cvdSafeColor`, not neutral surfaces,
  since backgrounds are already contrast-driven rather than hue-driven.
- **No `MaterialApp` replacement, no bundled font.** `LazyAlly` wraps your app; it doesn't ask you
  to swap widgets or pay for typography you didn't ask for.
- **Pluggable, not prescriptive.** `light`/`dark`/`extraDark` are plain `ThemeData` — bring your own
  theme, this package doesn't invent a parallel type.

## Related

If you also want **dev-time** accessibility auditing (contrast checks, tap-target size, missing
semantics) during development, pair this with
[`accessibility_tools`](https://pub.dev/packages/accessibility_tools) — a different job, complementary
rather than competing.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). This is the author's first published Dart/Flutter package —
issues, PRs, and "this API is awkward, here's why" feedback are genuinely welcome.

## License

MIT — see [LICENSE](LICENSE).
