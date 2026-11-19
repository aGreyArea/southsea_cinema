import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('PrimaryButton renders its label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Add to order',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Add to order'), findsOneWidget);
    });

    testWidgets('PrimaryButton invokes onPressed when tapped',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Add to order',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add to order'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });
}
