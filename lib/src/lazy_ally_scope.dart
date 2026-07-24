import 'package:flutter/material.dart';

import 'lazy_ally_controller.dart';

/// [InheritedNotifier] carrying a [LazyAllyController] down the tree so
/// descendants rebuild when theme, color-blind, or text-scale state changes.
class LazyAllyScope extends InheritedNotifier<LazyAllyController> {
  const LazyAllyScope({
    super.key,
    required LazyAllyController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest [LazyAllyController]. Asserts if no ancestor [LazyAllyScope]
  /// exists — wrap your app in a `LazyAlly` widget first.
  static LazyAllyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LazyAllyScope>();
    assert(
      scope != null,
      'No LazyAllyScope found in context. Wrap your app in a LazyAlly widget.',
    );
    return scope!.notifier!;
  }

  /// Like [of], but returns `null` instead of asserting when no ancestor
  /// [LazyAllyScope] exists.
  static LazyAllyController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LazyAllyScope>()
        ?.notifier;
  }
}

/// Convenience accessors for [LazyAllyScope].
extension LazyAllyContext on BuildContext {
  /// The nearest [LazyAllyController]. Asserts if no ancestor `LazyAlly`
  /// widget exists.
  LazyAllyController get lazyAlly => LazyAllyScope.of(this);

  /// The resolved [ThemeData] for the current mode — pass this straight to
  /// `MaterialApp(theme: context.lazyAllyTheme)`.
  ThemeData get lazyAllyTheme => LazyAllyScope.of(this).activeTheme;
}
