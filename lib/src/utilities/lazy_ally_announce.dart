import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Sends a polite accessibility announcement through
/// [SemanticsService.sendAnnouncement]. This method is the multi-window-safe
/// replacement for the deprecated `SemanticsService.announce`.
///
/// Every interactive LazyAlly widget calls this function on a state change,
/// because selecting a new chip or switch value does not itself generate a
/// spoken confirmation. This function is exported so your own custom
/// controls, such as a custom `itemBuilder`, can match the same standard.
///
/// This function is a no-op if [MediaQuery.supportsAnnounceOf] is false for
/// the current platform.
Future<void> lazyAllyAnnounce(BuildContext context, String message) {
  if (!MediaQuery.supportsAnnounceOf(context)) return Future<void>.value();
  return SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
}
