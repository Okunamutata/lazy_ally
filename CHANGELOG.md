# Changelog

## 0.1.0-dev.1

Core primitives — first working milestone, not yet published to pub.dev.

- `LazyAlly` widget: wraps an app, providing theming without replacing `MaterialApp`.
- `LazyAllyController` (`ChangeNotifier`) + `LazyAllyScope` (`InheritedNotifier`) for stock-Flutter
  state propagation; `context.lazyAlly` / `context.lazyAllyTheme` convenience accessors.
- Required `light` / `dark` `ThemeData`; optional `extraDark` (falls back to `dark`).
- Color-blind flag (`colorBlind`) orthogonal to brightness mode, defaulting to the Okabe-Ito palette,
  scoped to semantic/data colors via `cvdSafeColor(color, domainIndex)`.
- Text scale with configurable `textScaleMin` / `textScaleMax` / `textScaleDefault`, seeded from the
  OS's own text scaler on first build rather than overriding it outright.
- Not yet included (planned for 0.2): bundled control-sheet widget, `SemanticsService` announcements,
  pluggable `LazyAllyStorage`, contrast/tap-target guideline tests in CI.
