import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MainApp renders', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
