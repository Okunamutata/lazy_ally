part of '../lazy_ally_controller.dart';

// region Brightness / mode
mixin _BrightnessMixin on ChangeNotifier {
  late String _mode;
  Brightness _systemBrightness = Brightness.light;

  /// The value is [kLazyAllyLight], [kLazyAllyDark], or [kLazyAllySystem]
  /// (the default).
  String get mode => _mode;

  /// The current brightness of the OS. `LazyAlly` keeps this value in sync
  /// on every dependency change. This value affects [activeTheme] only
  /// while [mode] is [kLazyAllySystem].
  Brightness get systemBrightness => _systemBrightness;

  void setSystemBrightness(Brightness value) {
    if (value == _systemBrightness) return;
    _systemBrightness = value;
    if (_mode == kLazyAllySystem) notifyListeners();
  }

  void setMode(String mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// The resolved brightness is [systemBrightness] when [mode] is
  /// [kLazyAllySystem]. Otherwise the resolved brightness is [mode] itself.
  Brightness get _resolvedBrightness {
    if (_mode == kLazyAllySystem) return _systemBrightness;
    return _mode == kLazyAllyDark ? Brightness.dark : Brightness.light;
  }
}
// endregion
