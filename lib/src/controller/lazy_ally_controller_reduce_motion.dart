part of '../lazy_ally_controller.dart';

// region Reduce motion
mixin _ReduceMotionMixin on ChangeNotifier {
  late final ValueNotifier<bool> _reduceMotionNotifier;
  bool _reduceMotionSeeded = false;

  /// Advisory only — see [LazyAllyController.reduceMotion] for the full
  /// caveat on what does and doesn't respect this.
  bool get reduceMotion => _reduceMotionNotifier.value;

  /// Scoped [Listenable] for [reduceMotion] alone, so listening doesn't
  /// fire for unrelated controller changes.
  ValueListenable<bool> get reduceMotionListenable => _reduceMotionNotifier;

  void setReduceMotion(bool value) {
    if (value == _reduceMotionNotifier.value) return;
    // .value already notifies reduceMotionListenable's own listeners;
    // notifyListeners() below covers this controller's separately.
    _reduceMotionNotifier.value = value;
    notifyListeners();
  }

  /// Seeds the initial [reduceMotion] value from the OS's own
  /// `MediaQueryData.disableAnimations` (or an app-supplied override).
  /// Called once by `LazyAlly` on first build; a no-op if a cache restore
  /// (see [LazyAllyController.applyCache]) already supplied a value first —
  /// mirrors [_TextScaleMixin.seedFromSystemTextScale]'s guard against a
  /// system seed clobbering an already-restored preference.
  void seedReduceMotion(bool value) {
    if (_reduceMotionSeeded) return;
    _reduceMotionSeeded = true;
    setReduceMotion(value);
  }
}
// endregion
