import 'package:material_ui/material_ui.dart';

import 'package:lazy_ally/src/lazy_ally_controller.dart';

/// An [InheritedNotifier] that carries a [LazyAllyController] down the
/// tree, so descendants rebuild when theme, color-blind, or text-scale
/// state changes.
class LazyAllyProvider extends InheritedNotifier<LazyAllyController> {
  const LazyAllyProvider({
    super.key,
    required LazyAllyController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest [LazyAllyController]. This method asserts if no ancestor
  /// [LazyAllyProvider] exists. Wrap your app in a `LazyAlly` widget first.
  static LazyAllyController of(BuildContext context) {
    final LazyAllyProvider? scope = context
        .dependOnInheritedWidgetOfExactType<LazyAllyProvider>();
    assert(
      scope != null,
      'No LazyAllyProvider found in context. Wrap your app in a LazyAlly widget.',
    );
    return scope!.notifier!;
  }

  /// Like [of], but returns `null` instead of asserting when no ancestor
  /// [LazyAllyProvider] exists.
  static LazyAllyController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LazyAllyProvider>()
        ?.notifier;
  }
}

/// Convenience accessors for [LazyAllyProvider].
extension LazyAllyContext on BuildContext {
  /// The nearest [LazyAllyController]. This getter asserts if no ancestor
  /// `LazyAlly` widget exists.
  LazyAllyController get lazyAlly => LazyAllyProvider.of(this);

  /// The resolved [ThemeData] for the current mode. Pass this directly to
  /// `MaterialApp(theme: context.lazyAllyTheme)`.
  ThemeData get lazyAllyTheme => LazyAllyProvider.of(this).activeTheme;
}
