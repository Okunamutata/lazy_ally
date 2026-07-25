part of '../lazy_ally_controller.dart';

// region Custom themes
mixin _CustomThemesMixin on ChangeNotifier {
  late final Map<String, LazyAllyThemePair> _customThemes;
  late String? _selectedCustomTheme;

  /// Named [LazyAllyThemePair]s. Selecting one (see [setCustomTheme])
  /// replaces [LazyAllyController.light]/[LazyAllyController.dark] entirely
  /// as the base theme.
  Map<String, LazyAllyThemePair> get customThemes => _customThemes;

  /// The selected entry in [customThemes], or `null`.
  String? get selectedCustomTheme => _selectedCustomTheme;

  void setCustomTheme(String? name) {
    if (name == _selectedCustomTheme) return;
    _selectedCustomTheme = name;
    notifyListeners();
  }
}
// endregion
