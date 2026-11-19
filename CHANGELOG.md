# Changelog
## 1.0.5 - 2026-11-19

- README: switch the banner, demo GIF, and maintainer logo to absolute GitHub URLs. pub.dev drops
  relative-path images from the rendered README, so they show as alt text only. GitHub rendering is
  unchanged. Also refresh the install snippet to `^1.0.5`.

## 1.0.4 - 2026-11-19

- Migrated from the deprecated in-framework `package:flutter/material.dart` to the standalone
  `package:material_ui` package, with `dart fix --code=migrate_design_widgets`. Symbol and class
  names are unchanged, but `ThemeData` and `ColorScheme` now come from `material_ui`. Apps that
  still import `flutter/material.dart` can keep working through `MaterialUiCompatibilityBridge`.
- Raised the minimum SDK floor to Dart 3.13.0 and Flutter 3.47.0, to match `material_ui`.

## 1.0.3 - 2026-07-27

- Small copy change in README.md 

## 1.0.2 - 2026-07-27

- Small copy change in README.md

## 1.0.1 - 2026-07-27

- Compressed and updated demo GIF on [README.md](README.md)

## 1.0.0 - 2026-07-27

Initial stable release. Core primitives for accessible theming in stock Flutter.

- `LazyAlly` widget: wraps an app and provides theming without replacing `MaterialApp`.
- `LazyAllyController` (`ChangeNotifier`) and `LazyAllyProvider` (`InheritedNotifier`) handle
  stock-Flutter state propagation, with `context.lazyAlly` / `context.lazyAllyTheme` convenience
  accessors. The controller is split across `lazy_ally_controller_*.dart` part files by concern
  (brightness, color-blind, custom schemes/themes, text scale, reduce motion) for readability, but
  stays one class, one library.
- Required `light` / `dark` `ThemeData`. Brightness modes are exactly `kLazyAllySystem` (the default,
  which tracks the OS's live platform brightness continuously, not just at first build), `kLazyAllyLight`,
  and `kLazyAllyDark`. There is no built-in "extra dark" or similar mode. Register a variant like that
  as a named `customThemes` entry instead.
- `LazyAllyColorSchemePair` (`({ColorScheme light, ColorScheme dark})`) for `colorBlindScheme` and
  `customColorSchemes` entries swaps only `ThemeData.colorScheme` on top of whichever base theme is
  active. `LazyAllyThemePair` (`({ThemeData light, ThemeData dark})`) for `customThemes` entries
  replaces the *entire* base theme (typography, shapes, component themes). Both always resolve, live,
  to whichever member matches the active brightness. Supplying a complete, correct pair per brightness
  is the caller's responsibility.
- Color-blind flag (`colorBlind`) is orthogonal to brightness mode. When on, `activeTheme` swaps in a
  full `ColorScheme` rather than remapping individual colors. It defaults to a generated IBM
  color-blind-safe pair and is overridable through `colorBlindScheme`.
- `customColorSchemes: Map<String, LazyAllyColorSchemePair>` (plus `initialCustomScheme`,
  `setCustomScheme`) and `customThemes: Map<String, LazyAllyThemePair>` (plus `initialCustomTheme`,
  `setCustomTheme`) form two independent, open-ended named registries. A selected custom scheme
  overrides `colorBlind` at `activeTheme` resolution. A selected custom theme replaces `light`/`dark`
  as the base before that resolution happens.
- Text scale has configurable `textScaleMin` / `textScaleMax` / `textScaleDefault`, seeded from the
  OS's own text scaler on first build rather than overriding it outright.
- Reduce-motion flag (`reduceMotion`) is seeded from `MediaQuery.disableAnimationsOf` and wired back
  into `LazyAlly`'s own `MediaQuery` override. It is also exposed as `reduceMotionListenable`
  (`ValueListenable<bool>`), with `LazyAllyReducedMotionBuilder` covering the common case of swapping
  to a static-but-still-communicative widget.
- `LazyAllyPreferences` is a serializable snapshot (`mode`, `colorBlind`, `textScaleFactor`,
  `selectedCustomScheme`, `selectedCustomTheme`, `reduceMotion`) with `toJson`/`fromJson`. `LazyAlly`
  accepts `loadLazyAllyPreferences`/`onLazyAllyPreferencesChanged` hooks (plain functions, no bundled
  storage dependency) so you can restore or persist it however you like. A plain (non-`async`)
  `loadLazyAllyPreferences`, for example one pre-fetched before `runApp()`, is applied in `initState`
  before the first frame, with no flash of constructor defaults. An `async` one is applied once it
  resolves, which may show defaults for a frame or two.
- `LazyAllyLabels` is a plain data class holding every string LazyAlly's widgets render or announce,
  English by default, overridable per-widget or once through `LazyAllyPanel(labels: ...)`. It needs no
  `Locale`/`intl` dependency, so you bring your own localizations.
- `lazyAllyAnnounce` (`SemanticsService.sendAnnouncement`): every interactive LazyAlly widget
  announces its own state changes. It is exported so custom controls (for example, a bespoke
  `itemBuilder`) can match the same standard.
- Atomic control widgets: `LazyAllyBrightnessSelector`, `LazyAllyTextScaleSlider`,
  `LazyAllyColorBlindSwitch`, `LazyAllyReduceMotionSwitch`, `LazyAllyCustomSchemeSelector`, and
  `LazyAllyCustomThemeSelector`, plus `LazyAllyPanel`, a pre-composed layout of the first four
  (`showReduceMotion` hides that row). None of them opens, sizes, or manages a sheet/dialog/route.
  Navigation stays the calling app's job. See `example/` for the intended pattern: a
  `FloatingActionButton` that opens `showModalBottomSheet(builder: (_) => const LazyAllyPanel())`.
  `LazyAllyPanel` re-asserts a live `Theme` from `context.lazyAlly.activeTheme`, since
  `showModalBottomSheet`/`showDialog` capture `Theme` as a static snapshot at push time.
  - `LazyAllyBrightnessSelector` normally renders a `Wrap` of icon-over-label `ChoiceChip`s, not a
    `SegmentedButton`, which has nowhere to go but overflow with 3 options at large text scale.
  - `LazyAllyBrightnessSelector`, `LazyAllyTextScaleSlider`, and the default `ChoiceChip` item in
    `LazyAllyCustomSchemeSelector`/`LazyAllyCustomThemeSelector` all use
    `LazyAllyReducedMotionBuilder` to swap to a simpler, non-animated widget (plain toggle buttons,
    "-"/"+" step buttons) under `reduceMotion`, instead of fighting each widget's own built-in
    animation in place. `LazyAllyColorBlindSwitch`/`LazyAllyReduceMotionSwitch` (`Switch`) have no
    equivalent swap. Apps that need a fully motion-free control can build one directly with
    `reduceMotionListenable`/`LazyAllyReducedMotionBuilder`, the same tool these widgets themselves
    are built on.
  - `LazyAllyCustomSchemeSelector`/`LazyAllyCustomThemeSelector` are **not** part of `LazyAllyPanel`.
    Copy is a product decision. Both are builders: `itemBuilder` hands you
    `(context, name, selected, onSelect)` per entry (plus a leading `null` "none selected" slot), with
    a plain `ChoiceChip` fallback if omitted. They render nothing (plus a debug-only nudge) when their
    registry is empty. That is optional, not a misconfiguration.
- `lazyAllyOnColorFor(Color)` is a small exported utility (legible black/white foreground for a given
  background) useful when building your own `colorBlindScheme` or `customColorSchemes` entries.
