part of '../lazy_ally_controller.dart';

// region Text scale
mixin _TextScaleMixin on ChangeNotifier {
  late final double _textScaleMin;
  late final double _textScaleMax;
  late final bool _hadExplicitTextScaleDefault;
  late double _textScaleFactor;
  bool _seededFromSystem = false;

  /// The value is always within the range [textScaleMin]..[textScaleMax].
  double get textScaleFactor => _textScaleFactor;

  double get textScaleMin => _textScaleMin;

  double get textScaleMax => _textScaleMax;

  void setTextScaleFactor(double value) {
    final double clamped = _clampD(value, _textScaleMin, _textScaleMax);
    if (clamped == _textScaleFactor) return;
    _textScaleFactor = clamped;
    notifyListeners();
  }

  /// Seeds the initial text scale from the OS's own text scaler. This
  /// method composes with the OS value instead of discarding it.
  /// `LazyAlly` calls this once, on first build. This method is a no-op
  /// if the app gave an explicit `textScaleDefault`, or if the controller
  /// already seeded a value.
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
