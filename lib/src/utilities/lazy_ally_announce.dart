import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Sends a polite accessibility announcement via
/// [SemanticsService.sendAnnouncement] (the multi-window-safe replacement
/// for the deprecated `SemanticsService.announce`).
///
/// Every interactive LazyAlly widget calls this on state change, since
/// selecting a new chip/switch value doesn't itself generate a spoken
/// confirmation. Exported so your own custom controls (e.g. a bespoke
/// `itemBuilder`) can match the same standard.
///
/// No-ops if [MediaQuery.supportsAnnounceOf] is false for the current
/// platform.
Future<void> lazyAllyAnnounce(BuildContext context, String message) {
  if (!MediaQuery.supportsAnnounceOf(context)) return Future<void>.value();
  return SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
}
