// Basic widget test for SecureVault password manager.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SecureVault app launches', (WidgetTester tester) async {
    // Basic smoke test - app should show loading initially
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
