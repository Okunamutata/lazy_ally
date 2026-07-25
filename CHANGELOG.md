# Changelog

## 0.1.0-dev.1

Core primitives — first working milestone, not yet published to pub.dev.

- `LazyAlly` widget: wraps an app, providing theming without replacing `MaterialApp`.
- `LazyAllyController` (`ChangeNotifier`) + `LazyAllyProvider` (`InheritedNotifier`) for stock-Flutter
  state propagation; `context.lazyAlly` / `context.lazyAllyTheme` convenience accessors. Split across
  `lazy_ally_controller_*.dart` part files by concern (brightness, color-blind, custom schemes/themes,
  text scale, reduce motion) for readability — still one class, one library.
- Required `light` / `dark` `ThemeData`. Brightness modes are exactly `kLazyAllySystem` (the default,
  tracks the OS's live platform brightness continuously, not just at first build) / `kLazyAllyLight` /
  `kLazyAllyDark` — no bespoke "extra dark" or similar; register a variant like that as a named
  `customThemes` entry instead.
- `LazyAllyColorSchemePair` (`({ColorScheme light, ColorScheme dark})`) for `colorBlindScheme` and
  `customColorSchemes` entries — swaps only `ThemeData.colorScheme` on top of whichever base theme is
  active. `LazyAllyThemePair` (`({ThemeData light, ThemeData dark})`) for `customThemes` entries —
  replaces the *entire* base theme (typography, shapes, component themes). Both always resolve to
  whichever member matches the active brightness, live; supplying a complete, correct pair per
  brightness is the caller's responsibility.
- Color-blind flag (`colorBlind`) orthogonal to brightness mode. When on, `activeTheme` swaps in a
  full `ColorScheme` rather than remapping individual colors. Defaults to a generated IBM
  color-blind-safe pair;
  overridable via `colorBlindScheme`.
- `customColorSchemes: Map<String, LazyAllyColorSchemePair>` (+ `initialCustomScheme`,
  `setCustomScheme`) and `customThemes: Map<String, LazyAllyThemePair>` (+ `initialCustomTheme`,
  `setCustomTheme`) — two independent, open-ended named registries. A selected custom scheme overrides
  `colorBlind` at `activeTheme` resolution; a selected custom theme replaces `light`/`dark` as the base
  before that resolution happens.
- Text scale with configurable `textScaleMin` / `textScaleMax` / `textScaleDefault`, seeded from the
  OS's own text scaler on first build rather than overriding it outright.
- Reduce-motion flag (`reduceMotion`), seeded from `MediaQuery.disableAnimationsOf` and wired back into
  `LazyAlly`'s own `MediaQuery` override. Also exposed as `reduceMotionListenable`
  (`ValueListenable<bool>`), and `LazyAllyReducedMotionBuilder` for the common case of swapping to a
  static-but-still-communicative widget.
- `LazyAllyPreferences` — a serializable snapshot (`mode`, `colorBlind`, `textScaleFactor`,
  `selectedCustomScheme`, `selectedCustomTheme`, `reduceMotion`) with `toJson`/`fromJson`. `LazyAlly`
  accepts `loadLazyAllyPreferences`/`onLazyAllyPreferencesChanged` hooks (plain functions, no bundled storage dependency) to
  restore/persist it however you like. A plain (non-`async`) `loadLazyAllyPreferences` — e.g. pre-fetched before
  `runApp()` — is applied in `initState` before the first frame, with no flash of constructor
  defaults; an `async` one is applied once it resolves, which may show defaults for a frame or two.
- `LazyAllyLabels` — a plain data class holding every string LazyAlly's widgets render or announce,
  English by default, overridable per-widget or once via `LazyAllyPanel(labels: ...)`. No `Locale`/
  `intl` dependency; bring your own localizations.
- `lazyAllyAnnounce` (`SemanticsService.sendAnnouncement`) — every interactive LazyAlly widget
  announces its own state changes; exported so custom controls (e.g. a bespoke `itemBuilder`) can
  match the same standard.
- Atomic control widgets — `LazyAllyBrightnessSelector`, `LazyAllyTextScaleSlider`,
  `LazyAllyColorBlindSwitch`, `LazyAllyReduceMotionSwitch`, `LazyAllyCustomSchemeSelector`,
  `LazyAllyCustomThemeSelector` — plus `LazyAllyPanel`, a pre-composed layout of the first four
  (`showReduceMotion` to hide that row). None of them open, size, or manage a sheet/dialog/route —
  navigation stays the calling app's job; see `example/` for the intended pattern (a
  `FloatingActionButton` opening `showModalBottomSheet(builder: (_) => const LazyAllyPanel())`).
  `LazyAllyPanel` re-asserts a live `Theme` from `context.lazyAlly.activeTheme`, since
  `showModalBottomSheet`/`showDialog` capture `Theme` as a static snapshot at push time.
  - `LazyAllyBrightnessSelector` normally renders a `Wrap` of icon-over-label `ChoiceChip`s (not a
    `SegmentedButton`, which has nowhere to go but overflow with 3 options at large text scale).
  - `LazyAllyBrightnessSelector`, `LazyAllyTextScaleSlider`, and the default `ChoiceChip` item in
    `LazyAllyCustomSchemeSelector`/`LazyAllyCustomThemeSelector` all use
    `LazyAllyReducedMotionBuilder` to swap to a simpler, non-animated widget (plain toggle buttons,
    "-"/"+" step buttons) under `reduceMotion` — rather than fighting each widget's own built-in
    animation in place. `LazyAllyColorBlindSwitch`/`LazyAllyReduceMotionSwitch` (`Switch`) have no
    equivalent swap. Apps needing a fully motion-free control can build one with
    `reduceMotionListenable`/`LazyAllyReducedMotionBuilder` directly — that's the tool these widgets
    themselves are built on.
  - `LazyAllyCustomSchemeSelector`/`LazyAllyCustomThemeSelector` are **not** part of `LazyAllyPanel` —
    copy is a product decision. Both are builders: `itemBuilder` hands you
    `(context, name, selected, onSelect)` per entry (plus a leading `null` "none selected" slot), with
    a plain `ChoiceChip` fallback if omitted. Render nothing (plus a debug-only nudge) when their
    registry is empty — that's optional, not a misconfiguration.
- `lazyAllyOnColorFor(Color)` — a small exported utility (legible black/white foreground for a given
  background) useful when building your own `colorBlindScheme` or `customColorSchemes` entries.
