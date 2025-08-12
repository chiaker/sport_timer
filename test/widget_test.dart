// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:s_timer/main.dart';

void main() {
  testWidgets('App builds and shows empty list text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const STimerApp());

    expect(find.text('Нет сохранённых последовательностей'), findsOneWidget);

    // Add button exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
