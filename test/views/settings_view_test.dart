import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/repositories/settings_repository.dart';
import 'package:southsea_cinema/repositories/theme_repository.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  final SettingsRepository repository = SettingsRepository.instance;
  final ThemeRepository themeRepository = ThemeRepository.instance;
  const Key newsletterSwitch = Key('newsletter-switch');
  const Key darkModeSwitch = Key('dark-mode-switch');

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
    // empty in-memory storage instead of the phone's real preferences
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    themeRepository.themeMode.value = ThemeMode.dark;
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
      expect(find.byKey(newsletterSwitch), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.byKey(darkModeSwitch), findsOneWidget);
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
      expect(tester.widget<Switch>(find.byKey(newsletterSwitch)).value, isTrue);
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
      await tester.tap(find.byKey(newsletterSwitch));
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
      await tester.tap(find.byKey(newsletterSwitch));
      await tester.pump();
      await tester.tap(find.text('CANCEL'));
      await tester.pump();

      expect(fieldText(tester, 'email-field'), 'alex@example.com');
      expect(
          tester.widget<Switch>(find.byKey(newsletterSwitch)).value, isFalse);
      expect(repository.settings.email, 'alex@example.com');
    });

    testWidgets('Dark mode switch starts on, because the app is dark',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      expect(tester.widget<Switch>(find.byKey(darkModeSwitch)).value, isTrue);
    });

    testWidgets('turning Dark mode off switches to light mode and saves it',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.tap(find.byKey(darkModeSwitch));
      await tester.pump();

      expect(themeRepository.themeMode.value, ThemeMode.light);
      expect(tester.widget<Switch>(find.byKey(darkModeSwitch)).value, isFalse);
      expect(
          await SharedPreferencesAsync().getBool(ThemeRepository.darkModeKey),
          isFalse);
    });

    testWidgets('turning Dark mode back on switches to dark mode and saves it',
        (WidgetTester tester) async {
      themeRepository.themeMode.value = ThemeMode.light;
      await pumpSettings(tester);
      expect(tester.widget<Switch>(find.byKey(darkModeSwitch)).value, isFalse);

      await tester.tap(find.byKey(darkModeSwitch));
      await tester.pump();

      expect(themeRepository.themeMode.value, ThemeMode.dark);
      expect(tester.widget<Switch>(find.byKey(darkModeSwitch)).value, isTrue);
      expect(
          await SharedPreferencesAsync().getBool(ThemeRepository.darkModeKey),
          isTrue);
    });

    testWidgets('CANCEL does not undo the Dark mode switch',
        (WidgetTester tester) async {
      await pumpSettings(tester);

      await tester.tap(find.byKey(darkModeSwitch));
      await tester.pump();
      await tester.tap(find.text('CANCEL'));
      await tester.pump();

      expect(themeRepository.themeMode.value, ThemeMode.light);
    });
  });
}
