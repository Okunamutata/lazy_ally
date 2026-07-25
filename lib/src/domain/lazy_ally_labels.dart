import 'package:flutter/foundation.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';

/// All the human-readable copy LazyAlly's built-in widgets use — chip
/// labels, switch titles/subtitles, panel headings, custom-scheme/theme
/// fallback names, and the accessibility announcements each widget sends
/// via `lazyAllyAnnounce`.
///
/// Every LazyAlly widget defaults to `const LazyAllyLabels()` (English) but
/// accepts a `labels: LazyAllyLabels` override, so a non-English app can
/// supply its own copy — from `AppLocalizations`, an ARB-generated class,
/// or anywhere else.
/// Build one from your own localizations and
/// pass it to [LazyAllyPanel] (which forwards it to every control it
/// renders) or to an atomic widget directly:
///
/// ```dart
/// final t = AppLocalizations.of(context)!;
/// LazyAllyPanel(
///   labels: LazyAllyLabels(
///     systemBrightness: t.lazyAllySystem,
///     lightBrightness: t.lazyAllyLight,
///     darkBrightness: t.lazyAllyDark,
///     colorBlindTitle: t.lazyAllyColorBlindTitle,
///     // ...
///   ),
/// )
/// ```
///
/// The `...Announcement`/formatter fields are optional — leave them unset
/// and LazyAlly composes a reasonable English sentence from the (possibly
/// already-translated) plain-string fields above them; supply one yourself
/// if your language's word order needs more than substitution can give.
@immutable
class LazyAllyLabels {
  const LazyAllyLabels({
    this.systemBrightness = 'System',
    this.lightBrightness = 'Light',
    this.darkBrightness = 'Dark',
    this.brightnessAnnouncement,
    this.colorBlindTitle = 'Color-blind friendly',
    this.colorBlindSubtitle = 'Distinct, high-contrast palette for data colors',
    this.colorBlindAnnouncement,
    this.reduceMotionTitle = 'Reduce motion',
    this.reduceMotionSubtitle = 'Minimize animations',
    this.reduceMotionAnnouncement,
    this.textScaleAnnouncement,
    this.decreaseTextSizeTooltip = 'Decrease text size',
    this.increaseTextSizeTooltip = 'Increase text size',
    this.noSchemeSelected = 'None',
    this.schemeAnnouncement,
    this.noThemeSelected = 'Default',
    this.themeAnnouncement,
    this.appearanceHeading = 'Appearance',
    this.textSizeHeading = 'Text size',
  });

  /// Chip label for [kLazyAllySystem].
  final String systemBrightness;

  /// Chip label for [kLazyAllyLight].
  final String lightBrightness;

  /// Chip label for [kLazyAllyDark].
  final String darkBrightness;

  /// The display label for a mode value — [systemBrightness],
  /// [lightBrightness], or [darkBrightness].
  String brightnessLabelFor(String mode) {
    if (mode == kLazyAllySystem) return systemBrightness;
    if (mode == kLazyAllyDark) return darkBrightness;
    return lightBrightness;
  }

  /// Announcement sent when a brightness chip is selected. Defaults to
  /// "$label brightness selected".
  final String Function(String label)? brightnessAnnouncement;

  /// Resolves [brightnessAnnouncement], or its default, for [label] (the
  /// already-resolved [brightnessLabelFor] result).
  String announceBrightness(String label) =>
      brightnessAnnouncement?.call(label) ?? '$label brightness selected';

  /// [LazyAllyColorBlindSwitch]'s title.
  final String colorBlindTitle;

  /// [LazyAllyColorBlindSwitch]'s subtitle.
  final String colorBlindSubtitle;

  /// Announcement sent when color-blind mode is toggled. Defaults to
  /// "$colorBlindTitle on"/"$colorBlindTitle off".
  final String Function(bool value)? colorBlindAnnouncement;

  String announceColorBlind(bool value) =>
      colorBlindAnnouncement?.call(value) ??
      '$colorBlindTitle ${value ? 'on' : 'off'}';

  /// [LazyAllyReduceMotionSwitch]'s title.
  final String reduceMotionTitle;

  /// [LazyAllyReduceMotionSwitch]'s subtitle.
  final String reduceMotionSubtitle;

  /// Announcement sent when reduce-motion is toggled. Defaults to
  /// "$reduceMotionTitle on"/"$reduceMotionTitle off".
  final String Function(bool value)? reduceMotionAnnouncement;

  String announceReduceMotion(bool value) =>
      reduceMotionAnnouncement?.call(value) ??
      '$reduceMotionTitle ${value ? 'on' : 'off'}';

  /// Both [LazyAllyTextScaleSlider]'s `semanticFormatterCallback` (read out
  /// continuously while dragging) and its `onChangeEnd` announcement.
  /// Defaults to "1.20 times text size" for `value == 1.2`.
  final String Function(double value)? textScaleAnnouncement;

  String announceTextScale(double value) =>
      textScaleAnnouncement?.call(value) ??
      '${value.toStringAsFixed(2)} times text size';

  /// Tooltip for the "-" step button `LazyAllyTextScaleSlider` shows in
  /// place of the [Slider] when `reduceMotion` is on.
  final String decreaseTextSizeTooltip;

  /// Tooltip for the "+" step button — see [decreaseTextSizeTooltip].
  final String increaseTextSizeTooltip;

  /// [LazyAllyCustomSchemeSelector]'s default `itemBuilder` label, and the
  /// name used in [announceScheme], for the leading "no scheme selected"
  /// slot (`name == null`).
  final String noSchemeSelected;

  /// Announcement sent when a [LazyAllyCustomSchemeSelector] entry is
  /// selected — fires for a custom `itemBuilder` too, not just the default
  /// one. Defaults to "$name color scheme selected", or
  /// "$noSchemeSelected color scheme selected" for the `null` slot.
  final String Function(String? name)? schemeAnnouncement;

  String announceScheme(String? name) =>
      schemeAnnouncement?.call(name) ??
      '${name ?? noSchemeSelected} color scheme selected';

  /// [LazyAllyCustomThemeSelector]'s default `itemBuilder` label, and the
  /// name used in [announceTheme], for the leading "no theme selected" slot
  /// (`name == null`).
  final String noThemeSelected;

  /// Announcement sent when a [LazyAllyCustomThemeSelector] entry is
  /// selected. Defaults to "$name theme selected", or "$noThemeSelected
  /// theme selected" for the `null` slot.
  final String Function(String? name)? themeAnnouncement;

  String announceTheme(String? name) =>
      themeAnnouncement?.call(name) ??
      '${name ?? noThemeSelected} theme selected';

  /// [LazyAllyPanel]'s "Appearance" section heading.
  final String appearanceHeading;

  /// [LazyAllyPanel]'s "Text size" section heading.
  final String textSizeHeading;
}
