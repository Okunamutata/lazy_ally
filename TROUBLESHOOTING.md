# Troubleshooting

This page lists quirks and edge cases that come from how Flutter itself works, not from a bug in
`lazy_ally`. Each entry links back to the relevant API so you can see the fix in context.

## Contents

- [My settings flash back to defaults for a frame on startup](#my-settings-flash-back-to-defaults-for-a-frame-on-startup)
- ["Reduce motion" does not stop everything from animating](#reduce-motion-does-not-stop-everything-from-animating)
- [A toggle/slider keeps animating even with reduce motion on](#a-toggleslider-keeps-animating-even-with-reduce-motion-on)
- [Toggling a setting from inside a bottom sheet/dialog does not repaint](#toggling-a-setting-from-inside-a-bottom-sheetdialog-does-not-repaint)
- [My own `MediaQuery` override clobbers LazyAlly's text scale/reduce motion](#my-own-mediaquery-override-clobbers-lazyallys-text-scalereduce-motion)
- [There is no "extra dark" mode](#there-is-no-extra-dark-mode)
- [Which override wins: `customTheme`, `customColorScheme`, or `colorBlind`?](#which-override-wins-customtheme-customcolorscheme-or-colorblind)

## My settings flash back to defaults for a frame on startup

**Cause:** `LazyAlly` awaits `loadLazyAllyPreferences` asynchronously. It builds its first frame with
your constructor defaults, then applies the restored `LazyAllyPreferences` once your `Future`
resolves. A user who picked dark mode yesterday may see light mode flash for a frame before dark mode
takes over.

**Fix:** Fetch your storage before `runApp()`. Pass a plain, non-`async` closure that returns the
already-known value. `FutureOr<LazyAllyPreferences?> Function()` lets `loadLazyAllyPreferences` take
either shape. LazyAlly applies a synchronous value in `initState`, before the first frame, so there is
no flash:

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

## "Reduce motion" does not stop everything from animating

**Cause:** `context.lazyAlly.reduceMotion` is advisory, the same way OS-level "reduce motion" settings
are. LazyAlly wires it into `MediaQuery.disableAnimationsOf(context)` for your whole subtree. Flutter's
own framework widgets never check that flag themselves: implicit animations (`AnimatedContainer`,
`AnimatedOpacity`, and others), page route transitions, ink ripples, and `MaterialApp`'s own theme
cross-fade all ignore it. Nothing reduces motion unless code explicitly reads
`reduceMotion`/`reduceMotionListenable`.

**Fix:** For your own animations, gate them on `reduceMotionListenable`, or wrap the "motion" and
"reduced" versions in `LazyAllyReducedMotionBuilder`. For `MaterialApp`'s theme cross-fade, use this
pattern:

```dart
MaterialApp(
  themeAnimationDuration: context.lazyAlly.reduceMotion ? Duration.zero : kThemeAnimationDuration,
  // ...
)
```

See `example/lib/widgets/motion_examples.dart` for four more worked examples.

## A toggle/slider keeps animating even with reduce motion on

**Cause:** `LazyAllyColorBlindSwitch`/`LazyAllyReduceMotionSwitch` are built on `Switch`.
`LazyAllyTextScaleSlider` falls back to `Slider` when motion is not reduced. Neither widget exposes a
way to disable its own internal animation in stable Flutter. `LazyAllyBrightnessSelector`, the
reduced-motion state of `LazyAllyTextScaleSlider`, and the default `LazyAllyCustomSchemeSelector`/
`LazyAllyCustomThemeSelector` items already work around this. They swap `ChoiceChip`/`Slider` for plain
buttons through `LazyAllyReducedMotionBuilder`. `Switch` has no non-animated stand-in to swap to.

**Fix:** If a fully motion-free control matters for your users, build your own with
`reduceMotionListenable`/`LazyAllyReducedMotionBuilder` in place of
`LazyAllyColorBlindSwitch`/`LazyAllyReduceMotionSwitch`. This is the same tool those widgets use.

## Toggling a setting from inside a bottom sheet/dialog does not repaint

**Cause:** `showModalBottomSheet`/`showDialog` capture `Theme`/`IconTheme` as a **static snapshot** the
moment the route is pushed (`InheritedTheme.capture`). Flutter reparents the pushed route's content
into the root `Overlay`, structurally outside the calling context's tree. `LazyAllyController` state
updates correctly, but anything reading the frozen ambient `Theme.of(context)` inside that route never
repaints.

**Fix:** `LazyAllyPanel` already re-asserts a live `Theme` internally. This problem only appears if you
build your own settings surface, or place `LazyAllyCustomSchemeSelector`/`LazyAllyCustomThemeSelector`,
inside a pushed route yourself. Apply the same pattern:

```dart
Theme(data: context.lazyAlly.activeTheme, child: /* your content */)
```

## My own `MediaQuery` override clobbers LazyAlly's text scale/reduce motion

**Cause:** `LazyAlly` applies its own `MediaQuery` (composing text scale and reduce motion) around
`child`. If your app also uses `MaterialApp(builder: ...)` to apply its own `MediaQuery` override
further down the tree, the inner one wins. The two do not combine automatically.

**Fix:** Read `context.lazyAlly.textScaleFactor`/`context.lazyAlly.reduceMotion` inside your own
`builder`. Compose them into whatever `MediaQuery` you already build there.

## There is no "extra dark" mode

**Cause:** `LazyAllyController.mode` is deliberately limited to
`kLazyAllySystem`/`kLazyAllyLight`/`kLazyAllyDark`. LazyAlly has no built-in variants beyond these
three.

**Fix:** Register the variant as a named `customThemes` entry instead. This uses the same mechanism as
any other named theme, such as a Halloween or seasonal palette. Offer it through
`LazyAllyCustomThemeSelector`:

```dart
LazyAlly(
  light: myLightTheme,
  dark: myDarkTheme,
  customThemes: {'extraDark': (light: myLightTheme, dark: myTrueBlackTheme)},
  child: const MyApp(),
)
```

## Which override wins: `customTheme`, `customColorScheme`, or `colorBlind`?

Two independent layers resolve in this order every time `activeTheme` is read:

1. **Base theme** — `light`/`dark`, or the selected `customThemes` entry if one is set. This replaces
   the entire `ThemeData`: typography, shapes, and component themes.
2. **Color scheme** — layered on top of whichever base theme step 1 picked. A selected
   `customColorSchemes` entry wins if set. Otherwise, `colorBlind` (if on) swaps in the IBM
   color-blind-safe pair, or your own `colorBlindScheme`. If neither applies, the base theme's own
   `ColorScheme` is left alone.

A selected custom theme and a selected custom color scheme can be active at the same time. They are
not mutually exclusive, since one replaces structure and the other replaces color.
