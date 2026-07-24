import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_ally/lazy_ally.dart';

import 'package:lazy_ally_example/main.dart';

void main() {
  testWidgets('example app boots into HomePage with LazyAlly scope available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      LazyAlly(
        light: ThemeData.light(),
        dark: ThemeData.dark(),
        child: const ExampleApp(),
      ),
    );

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('switching the appearance segment updates the active theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      LazyAlly(
        light: ThemeData.light(),
        dark: ThemeData.dark(),
        initialMode: kLazyAllyLight,
        child: const ExampleApp(),
      ),
    );

    final context = tester.element(find.byType(HomePage));
    expect(context.lazyAlly.mode, kLazyAllyLight);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(context.lazyAlly.mode, kLazyAllyDark);
  });
}
