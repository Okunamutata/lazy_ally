part of '../lazy_ally_controller.dart';

// region Custom themes
mixin _CustomThemesMixin on ChangeNotifier {
  late final Map<String, LazyAllyThemePair> _customThemes;
  late String? _selectedCustomTheme;

  /// Named [LazyAllyThemePair]s. When you select one (see
  /// [setCustomTheme]), the selection fully replaces
  /// [LazyAllyController.light]/[LazyAllyController.dark] as the base theme.
  Map<String, LazyAllyThemePair> get customThemes => _customThemes;

  /// The selected entry in [customThemes]. The value is `null` if nothing
  /// is selected.
  String? get selectedCustomTheme => _selectedCustomTheme;

  void setCustomTheme(String? name) {
    if (name == _selectedCustomTheme) return;
    _selectedCustomTheme = name;
    notifyListeners();
  }
}
// endregion
