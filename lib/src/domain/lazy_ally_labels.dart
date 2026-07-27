import 'package:flutter/foundation.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';

/// All the human-readable text that LazyAlly's built-in widgets use: chip
/// labels, switch titles and subtitles, panel headings, custom-scheme and
/// custom-theme fallback names, and the accessibility announcements each
/// widget sends through `lazyAllyAnnounce`.
///
/// Every LazyAlly widget defaults to `const LazyAllyLabels()`, which is in
/// English, but accepts a `labels: LazyAllyLabels` override. This lets a
/// non-English app supply its own text, from `AppLocalizations`, an
/// ARB-generated class, or anywhere else. Build one from your own
/// localizations and pass it to [LazyAllyPanel], which forwards the labels
/// to every control it renders, or pass it to an atomic widget directly:
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
/// The `...Announcement`/formatter fields are optional. If you leave them
/// unset, LazyAlly composes a reasonable English sentence from the plain
/// string fields above them, which may already be translated. Supply one
/// yourself if your language's word order needs more than substitution can
/// give.
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

  /// The display label for a mode value: [systemBrightness],
  /// [lightBrightness], or [darkBrightness].
  String brightnessLabelFor(String mode) {
    if (mode == kLazyAllySystem) return systemBrightness;
    if (mode == kLazyAllyDark) return darkBrightness;
    return lightBrightness;
  }

  /// The announcement sent when a brightness chip is selected. The default
  /// value is "$label brightness selected".
  final String Function(String label)? brightnessAnnouncement;

  /// Resolves [brightnessAnnouncement], or its default value, for [label],
  /// the already-resolved result of [brightnessLabelFor].
  String announceBrightness(String label) =>
      brightnessAnnouncement?.call(label) ?? '$label brightness selected';

  /// [LazyAllyColorBlindSwitch]'s title.
  final String colorBlindTitle;

  /// [LazyAllyColorBlindSwitch]'s subtitle.
  final String colorBlindSubtitle;

  /// The announcement sent when color-blind mode is toggled. The default
  /// value is "$colorBlindTitle on" or "$colorBlindTitle off".
  final String Function(bool value)? colorBlindAnnouncement;

  String announceColorBlind(bool value) =>
      colorBlindAnnouncement?.call(value) ??
      '$colorBlindTitle ${value ? 'on' : 'off'}';

  /// [LazyAllyReduceMotionSwitch]'s title.
  final String reduceMotionTitle;

  /// [LazyAllyReduceMotionSwitch]'s subtitle.
  final String reduceMotionSubtitle;

  /// The announcement sent when reduce-motion is toggled. The default
  /// value is "$reduceMotionTitle on" or "$reduceMotionTitle off".
  final String Function(bool value)? reduceMotionAnnouncement;

  String announceReduceMotion(bool value) =>
      reduceMotionAnnouncement?.call(value) ??
      '$reduceMotionTitle ${value ? 'on' : 'off'}';

  /// This field supplies both [LazyAllyTextScaleSlider]'s
  /// `semanticFormatterCallback`, which is read out continuously while
  /// dragging, and its `onChangeEnd` announcement. The default value is
  /// "1.20 times text size" for `value == 1.2`.
  final String Function(double value)? textScaleAnnouncement;

  String announceTextScale(double value) =>
      textScaleAnnouncement?.call(value) ??
      '${value.toStringAsFixed(2)} times text size';

  /// The tooltip for the "-" step button that `LazyAllyTextScaleSlider`
  /// shows in place of the [Slider] when `reduceMotion` is on.
  final String decreaseTextSizeTooltip;

  /// The tooltip for the "+" step button. See [decreaseTextSizeTooltip].
  final String increaseTextSizeTooltip;

  /// [LazyAllyCustomSchemeSelector]'s default `itemBuilder` label, and the
  /// name used in [announceScheme], for the leading "no scheme selected"
  /// slot, where `name == null`.
  final String noSchemeSelected;

  /// The announcement sent when a [LazyAllyCustomSchemeSelector] entry is
  /// selected. This announcement also fires for a custom `itemBuilder`,
  /// not only the default one. The default value is "$name color scheme
  /// selected", or "$noSchemeSelected color scheme selected" for the
  /// `null` slot.
  final String Function(String? name)? schemeAnnouncement;

  String announceScheme(String? name) =>
      schemeAnnouncement?.call(name) ??
      '${name ?? noSchemeSelected} color scheme selected';

  /// [LazyAllyCustomThemeSelector]'s default `itemBuilder` label, and the
  /// name used in [announceTheme], for the leading "no theme selected" slot,
  /// where `name == null`.
  final String noThemeSelected;

  /// The announcement sent when a [LazyAllyCustomThemeSelector] entry is
  /// selected. The default value is "$name theme selected", or
  /// "$noThemeSelected theme selected" for the `null` slot.
  final String Function(String? name)? themeAnnouncement;

  String announceTheme(String? name) =>
      themeAnnouncement?.call(name) ??
      '${name ?? noThemeSelected} theme selected';

  /// [LazyAllyPanel]'s "Appearance" section heading.
  final String appearanceHeading;

  /// [LazyAllyPanel]'s "Text size" section heading.
  final String textSizeHeading;
}
