import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> goToStep(WidgetTester tester, int index) async {
  final chip = find.byKey(ValueKey('consultationStep$index'));
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}
