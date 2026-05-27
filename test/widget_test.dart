// Widget tests for SilverSync.
// The default Flutter template test has been updated to reference
// the correct app class name (SilverSyncApp, not MyApp).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:silversync_ui/main.dart';

void main() {
  testWidgets('App launches and shows SilverSync UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SilverSyncApp()),
    );
    // App should render without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
