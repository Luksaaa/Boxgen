import 'package:boxgen/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Boxgen renders training controls and mode selector', (
    tester,
  ) async {
    await tester.pumpWidget(const BoxgenApp());

    expect(find.text('BOXGEN'), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

    await tester.tap(find.text('Combo').first);
    await tester.pumpAndSettle();

    expect(find.text('Training mode'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Tactical'), findsOneWidget);
  });
}
