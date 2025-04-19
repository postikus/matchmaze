// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matchmaze/main.dart';
import 'package:matchmaze/core/ui_settings.dart';

void main() {
  testWidgets('App renders start screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with the StartScreen
    expect(find.text('MATCHMAZE'), findsOneWidget);
    expect(find.text('Match & Destroy'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);

    // Verify title styling
    final titleFinder = find.text('MATCHMAZE');
    final titleWidget = tester.widget<Text>(titleFinder);
    expect(titleWidget.style?.fontSize, equals(UISettings.titleFontSize));
    expect(titleWidget.style?.color, equals(UISettings.titleColor));
    expect(titleWidget.style?.letterSpacing, equals(UISettings.titleLetterSpacing));

    // Verify subtitle styling
    final subtitleFinder = find.text('Match & Destroy');
    final subtitleWidget = tester.widget<Text>(subtitleFinder);
    expect(subtitleWidget.style?.fontSize, equals(UISettings.subtitleFontSize));
    expect(subtitleWidget.style?.color, equals(UISettings.subtitleColor));
    expect(subtitleWidget.style?.letterSpacing, equals(UISettings.subtitleLetterSpacing));

    // Verify play button styling
    final buttonFinder = find.byType(ElevatedButton);
    final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
    expect(buttonWidget.style?.backgroundColor?.resolve({}), equals(UISettings.playButtonColor));
    expect(buttonWidget.style?.foregroundColor?.resolve({}), equals(UISettings.playButtonTextColor));
  });
}
