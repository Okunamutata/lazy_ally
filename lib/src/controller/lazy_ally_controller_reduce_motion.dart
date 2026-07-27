part of '../lazy_ally_controller.dart';

// region Reduce motion
mixin _ReduceMotionMixin on ChangeNotifier {
  late final ValueNotifier<bool> _reduceMotionNotifier;
  bool _reduceMotionSeeded = false;

  /// This value is advisory only. See [LazyAllyController.reduceMotion]
  /// for the full caveat about what does and does not respect this value.
  bool get reduceMotion => _reduceMotionNotifier.value;

  /// A scoped [Listenable] for [reduceMotion] alone. This listenable does
  /// not fire for unrelated controller changes.
  ValueListenable<bool> get reduceMotionListenable => _reduceMotionNotifier;

  void setReduceMotion(bool value) {
    if (value == _reduceMotionNotifier.value) return;
    // .value already notifies reduceMotionListenable's own listeners.
    // notifyListeners() below covers this controller's listeners separately.
    _reduceMotionNotifier.value = value;
    notifyListeners();
  }

  /// Seeds the initial [reduceMotion] value from the OS's own
  /// `MediaQueryData.disableAnimations` value (or an app-supplied override).
  /// `LazyAlly` calls this once, on first build. This method is a no-op if
  /// a cache restore (see [LazyAllyController.applyCache]) already supplied
  /// a value first. This guard mirrors
  /// [_TextScaleMixin.seedFromSystemTextScale], which uses the same check
  /// to stop a system seed from overwriting an already-restored preference.
  void seedReduceMotion(bool value) {
    if (_reduceMotionSeeded) return;
    _reduceMotionSeeded = true;
    setReduceMotion(value);
  }
}
// endregion
