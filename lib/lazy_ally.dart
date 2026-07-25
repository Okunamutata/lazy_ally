/// Wrap your app in a [LazyAlly] widget for system/light/dark theming (plus
/// your own named custom themes/color schemes), an orthogonal Okabe-Ito
/// color-blind flag, and text-scale limits — built entirely on stock
/// Flutter tooling (`ThemeData`, `ChangeNotifier`, `InheritedNotifier`,
/// `BuildContext`).
library;

export 'src/colors/contrast.dart';
export 'src/lazy_ally.dart';
export 'src/utilities/lazy_ally_announce.dart';
export 'src/domain/lazy_ally_preferences.dart';
export 'src/lazy_ally_controller.dart';
export 'src/domain/lazy_ally_labels.dart';
export 'src/lazy_ally_provider.dart';
export 'src/colors/okabe_ito.dart';
export 'src/widgets/lazy_ally_brightness_selector.dart';
export 'src/widgets/lazy_ally_color_blind_switch.dart';
export 'src/widgets/lazy_ally_custom_scheme_selector.dart';
export 'src/widgets/lazy_ally_custom_theme_selector.dart';
export 'src/widgets/lazy_ally_panel.dart';
export 'src/widgets/lazy_ally_reduce_motion_switch.dart';
export 'src/widgets/lazy_ally_reduced_motion_builder.dart';
export 'src/widgets/lazy_ally_text_scale_slider.dart';
