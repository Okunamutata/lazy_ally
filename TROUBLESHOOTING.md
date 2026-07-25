# Troubleshooting

Quirks and edge cases that come from how Flutter itself works, not from a bug in `lazy_ally` — each
one links back to the relevant API so you can see the fix in context.

## Contents

- [My settings flash back to defaults for a frame on startup](#my-settings-flash-back-to-defaults-for-a-frame-on-startup)
- ["Reduce motion" doesn't stop everything from animating](#reduce-motion-doesnt-stop-everything-from-animating)
- [A toggle/slider keeps animating even with reduce motion on](#a-toggleslider-keeps-animating-even-with-reduce-motion-on)
- [Toggling a setting from inside a bottom sheet/dialog doesn't repaint](#toggling-a-setting-from-inside-a-bottom-sheetdialog-doesnt-repaint)
- [My own `MediaQuery` override clobbers LazyAlly's text scale/reduce motion](#my-own-mediaquery-override-clobbers-lazyallys-text-scalereduce-motion)
- [There's no "extra dark" mode](#theres-no-extra-dark-mode)
- [A custom animated widget crashes on dispose](#a-custom-animated-widget-crashes-on-dispose)
- [My screen doesn't update when I read `context.lazyAlly` inside `AnimatedBuilder`](#my-screen-doesnt-update-when-i-read-contextlazyally-inside-animatedbuilder)
- [Which override wins: `customTheme`, `customColorScheme`, or `colorBlind`?](#which-override-wins-customtheme-customcolorscheme-or-colorblind)

## My settings flash back to defaults for a frame on startup

**Cause:** `loadLazyAllyPreferences` is awaited asynchronously. `LazyAlly` builds its first frame with your
constructor defaults, then applies the restored `LazyAllyPreferences` once your `Future` resolves —
so a user who picked dark mode yesterday may see light mode flash for a frame before dark mode takes
over.

**Fix:** pre-fetch your storage *before* `runApp()` and pass a plain, non-`async` closure that just
returns the already-known value. `FutureOr<LazyAllyPreferences?> Function()` lets `loadLazyAllyPreferences` be either
shape; a genuinely synchronous one is applied in `initState`, before the first frame — no flash:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('lazy_ally_cache');
  final LazyAllyPreferences? cached = raw == null
      ? null
      : LazyAllyPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  runApp(LazyAlly(
    light: myLightTheme,
    dark: myDarkTheme,
    loadLazyAllyPreferences: () => cached, // not async — already fetched above
    child: const MyApp(),
  ));
}
```

## "Reduce motion" doesn't stop everything from animating

**Cause:** `context.lazyAlly.reduceMotion` is advisory, the same way OS-level "reduce motion" settings
are. It's wired into `MediaQuery.disableAnimationsOf(context)` for your whole subtree, but Flutter's
own framework widgets — implicit animations (`AnimatedContainer`, `AnimatedOpacity`, ...), page route
transitions, ink ripples, `MaterialApp`'s own theme cross-fade — never check that flag themselves.
Nothing does, unless code explicitly reads `reduceMotion`/`reduceMotionListenable`.

**Fix:** for your own animations, gate them on `reduceMotionListenable` or wrap the "motion" vs.
"reduced" version in `LazyAllyReducedMotionBuilder`. For `MaterialApp`'s theme cross-fade specifically:

```dart
MaterialApp(
  themeAnimationDuration: context.lazyAlly.reduceMotion ? Duration.zero : kThemeAnimationDuration,
  // ...
)
```

See `example/lib/widgets/motion_examples.dart` for four more worked examples.

## A toggle/slider keeps animating even with reduce motion on

**Cause:** `LazyAllyColorBlindSwitch`/`LazyAllyReduceMotionSwitch` are built on `Switch`, and
`LazyAllyTextScaleSlider` falls back to `Slider` when motion isn't reduced — neither widget exposes any
way to disable its own internal animation in stable Flutter. `LazyAllyBrightnessSelector`,
`LazyAllyTextScaleSlider`'s reduced-motion state, and the default `LazyAllyCustomSchemeSelector`/
`LazyAllyCustomThemeSelector` items all work around this already, by swapping `ChoiceChip`/`Slider` for
plain buttons via `LazyAllyReducedMotionBuilder` — `Switch` has no equivalent non-animated stand-in to
swap to.

**Fix:** if a fully motion-free control genuinely matters for your users, build your own with
`reduceMotionListenable`/`LazyAllyReducedMotionBuilder` in place of `LazyAllyColorBlindSwitch`/
`LazyAllyReduceMotionSwitch` — that's the same tool those widgets are built on.

## Toggling a setting from inside a bottom sheet/dialog doesn't repaint

**Cause:** `showModalBottomSheet`/`showDialog` capture `Theme`/`IconTheme` as a **static snapshot** the
moment the route is pushed (`InheritedTheme.capture`), because the pushed route's content is
reparented into the root `Overlay`, structurally outside the calling context's tree. `LazyAllyController`
state updates correctly, but anything reading the frozen ambient `Theme.of(context)` inside that route
never repaints.

**Fix:** `LazyAllyPanel` already re-asserts a live `Theme` internally, so this only bites if you build
your own settings surface (or place `LazyAllyCustomSchemeSelector`/`LazyAllyCustomThemeSelector`)
inside a pushed route yourself. Apply the same pattern:

```dart
Theme(data: context.lazyAlly.activeTheme, child: /* your content */)
```

## My own `MediaQuery` override clobbers LazyAlly's text scale/reduce motion

**Cause:** `LazyAlly` applies its own `MediaQuery` (composing text scale and reduce motion) around
`child`. If your app *also* uses `MaterialApp(builder: ...)` to apply its own `MediaQuery` override
further down the tree, the inner one wins — the two don't automatically combine.

**Fix:** read `context.lazyAlly.textScaleFactor`/`context.lazyAlly.reduceMotion` inside your own
`builder` and compose them into whatever `MediaQuery` you're already building there.

## There's no "extra dark" mode

**Cause:** `LazyAllyController.mode` is deliberately just `kLazyAllySystem`/`kLazyAllyLight`/
`kLazyAllyDark` — no bespoke variants.

**Fix:** register the variant as a named `customThemes` entry instead (same mechanism as any other
named theme — Halloween, a seasonal palette, etc.) and offer it via `LazyAllyCustomThemeSelector`:

```dart
LazyAlly(
  light: myLightTheme,
  dark: myDarkTheme,
  customThemes: {'extraDark': (light: myLightTheme, dark: myTrueBlackTheme)},
  child: const MyApp(),
)
```

## Which override wins: `customTheme`, `customColorScheme`, or `colorBlind`?

Two independent layers, resolved in this order every time `activeTheme` is read:

1. **Base theme** — `light`/`dark`, or the selected `customThemes` entry if one is set (replaces the
   entire `ThemeData`: typography, shapes, component themes).
2. **Color scheme** — layered on top of whichever base theme step 1 picked. A selected
   `customColorSchemes` entry wins if set; otherwise `colorBlind` (if on) swaps in the Okabe-Ito (or
   your own `colorBlindScheme`) pair; otherwise the base theme's own `ColorScheme` is left alone.

So a selected custom theme and a selected custom color scheme can be active *at the same time* —
they're not mutually exclusive, since one replaces structure and the other replaces color.
