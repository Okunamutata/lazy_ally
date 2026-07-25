part of '../lazy_ally_controller.dart';

// region Text scale
mixin _TextScaleMixin on ChangeNotifier {
  late final double _textScaleMin;
  late final double _textScaleMax;
  late final bool _hadExplicitTextScaleDefault;
  late double _textScaleFactor;
  bool _seededFromSystem = false;

  /// Always within [textScaleMin]..[textScaleMax].
  double get textScaleFactor => _textScaleFactor;

  double get textScaleMin => _textScaleMin;

  double get textScaleMax => _textScaleMax;

  void setTextScaleFactor(double value) {
    final double clamped = _clampD(value, _textScaleMin, _textScaleMax);
    if (clamped == _textScaleFactor) return;
    _textScaleFactor = clamped;
    notifyListeners();
  }

  /// Seeds the initial text scale from the OS's own text scaler, composing
  /// with rather than discarding it. Called once by `LazyAlly` on first
  /// build; no-op if an explicit `textScaleDefault` was given, or already
  /// seeded.
  void seedFromSystemTextScale(double systemFactor) {
    if (_seededFromSystem || _hadExplicitTextScaleDefault) return;
    _seededFromSystem = true;
    final double clamped = _clampD(systemFactor, _textScaleMin, _textScaleMax);
    if (clamped != _textScaleFactor) {
      _textScaleFactor = clamped;
      notifyListeners();
    }
  }
}
// endregion
