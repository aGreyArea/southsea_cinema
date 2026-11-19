import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/repositories/settings_repository.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  final SettingsRepository repository = SettingsRepository.instance;

  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: SettingsView()));
  }

  String fieldText(WidgetTester tester, String key) {
    return tester.widget<TextField>(find.byKey(Key(key))).controller!.text;
  }

  setUp(() {
    repository.reset(); // settings are shared, so start every test fresh
  });

  group('SettingsView', () {
    testWidgets('shows every field of the profile form',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      expect(find.text('My Settings'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Patron Number'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Receive news by email'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SAVE SETTINGS'), findsOneWidget);
    });

    testWidgets('fills the form with previously saved settings',
        (WidgetTester tester) async {
      repository.save(const UserSettings(
        address: 'Lion Terrace',
        email: 'alex@example.com',
        patronNumber: '1234',
        receiveNewsletter: true,
      ));
      await pumpSettings(tester);

      expect(fieldText(tester, 'address-field'), 'Lion Terrace');
      expect(fieldText(tester, 'email-field'), 'alex@example.com');
      expect(fieldText(tester, 'patron-number-field'), '1234');
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('SAVE SETTINGS stores what the user entered',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(
          find.byKey(const Key('address-field')), 'Lion Terrace\nPortsmouth');
      await tester.enterText(
          find.byKey(const Key('email-field')), 'alex@example.com');
      await tester.enterText(
          find.byKey(const Key('patron-number-field')), '1234');
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('SAVE SETTINGS'));
      await tester.pump();

      final UserSettings saved = repository.settings;
      expect(saved.address, 'Lion Terrace\nPortsmouth');
      expect(saved.email, 'alex@example.com');
      expect(saved.patronNumber, '1234');
      expect(saved.receiveNewsletter, isTrue);
      expect(find.text('Settings saved'), findsOneWidget);
    });

    testWidgets('patron number only accepts digits',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(
          find.byKey(const Key('patron-number-field')), '12ab34');

      expect(fieldText(tester, 'patron-number-field'), '1234');
    });

    testWidgets('clear button empties the address',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.enterText(
          find.byKey(const Key('address-field')), 'Lion Terrace');
      await tester.tap(find.byKey(const Key('clear-address')));
      await tester.pump();

      expect(fieldText(tester, 'address-field'), isEmpty);
    });

    testWidgets('CANCEL throws away unsaved changes',
        (WidgetTester tester) async {
      repository.save(const UserSettings(email: 'alex@example.com'));
      await pumpSettings(tester);

      await tester.enterText(
          find.byKey(const Key('email-field')), 'changed@example.com');
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('CANCEL'));
      await tester.pump();

      expect(fieldText(tester, 'email-field'), 'alex@example.com');
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(repository.settings.email, 'alex@example.com');
    });
  });
}
