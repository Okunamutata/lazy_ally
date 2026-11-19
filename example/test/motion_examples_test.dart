import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_ally/lazy_ally.dart';
import 'package:lazy_ally_example/widgets/motion_examples.dart';

Widget _harness(Widget child, {bool reduceMotion = false}) {
  return LazyAlly(
    light: ThemeData.light(),
    dark: ThemeData.dark(),
    initiallyDisableAnimation: reduceMotion,
    child: Builder(
      builder: (BuildContext context) => MaterialApp(
        theme: context.lazyAllyTheme,
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

// Scoped to descendants of [of] because Scaffold always builds its
// floating-action-button transition machinery internally — using these same
// RotationTransition/ScaleTransition widget types — even with no
// floatingActionButton supplied. A bare find.byType(...) here would also
// match that unrelated internal machinery.
Finder _descendant(Finder of, Type transitionType) {
  return find.descendant(of: of, matching: find.byType(transitionType));
}

void main() {
  group('ReduceMotionAwareSpinner', () {
    final Finder of = find.byType(ReduceMotionAwareSpinner);

    testWidgets(
      'animates (RotationTransition, ticking) when motion is not reduced',
      (WidgetTester tester) async {
        await tester.pumpWidget(_harness(const ReduceMotionAwareSpinner()));

        expect(_descendant(of, RotationTransition), findsOneWidget);
        expect(find.text('Saving…'), findsNothing);
        expect(tester.hasRunningAnimations, isTrue);
      },
    );

    testWidgets(
      'shows a static icon + label, animation stopped, when motion is reduced',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(const ReduceMotionAwareSpinner(), reduceMotion: true),
        );

        expect(_descendant(of, RotationTransition), findsNothing);
        expect(find.byIcon(Icons.sync), findsOneWidget);
        expect(find.text('Saving…'), findsOneWidget);
      },
    );
  });

  group('ReduceMotionAwareLikeButton', () {
    final Finder of = find.byType(ReduceMotionAwareLikeButton);

    testWidgets(
      'bounces (ScaleTransition) on like when motion is not reduced',
      (WidgetTester tester) async {
        await tester.pumpWidget(_harness(const ReduceMotionAwareLikeButton()));
        expect(_descendant(of, ScaleTransition), findsOneWidget);

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(_descendant(of, ScaleTransition), findsOneWidget);
      },
    );

    testWidgets(
      'toggles instantly (no ScaleTransition) when motion is reduced',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(const ReduceMotionAwareLikeButton(), reduceMotion: true),
        );
        expect(_descendant(of, ScaleTransition), findsNothing);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // The state change itself still communicates "liked" without any
        // scale animation running.
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(_descendant(of, ScaleTransition), findsNothing);
      },
    );
  });

  group('ReduceMotionAwareNewBadge', () {
    final Finder of = find.byType(ReduceMotionAwareNewBadge);

    testWidgets(
      'pulses (ScaleTransition, ticking) when motion is not reduced',
      (WidgetTester tester) async {
        await tester.pumpWidget(_harness(const ReduceMotionAwareNewBadge()));

        expect(_descendant(of, ScaleTransition), findsOneWidget);
        expect(tester.hasRunningAnimations, isTrue);
      },
    );

    testWidgets(
      'shows a static ringed dot, animation stopped, when motion is reduced',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _harness(const ReduceMotionAwareNewBadge(), reduceMotion: true),
        );

        expect(_descendant(of, ScaleTransition), findsNothing);
      },
    );
  });
}
