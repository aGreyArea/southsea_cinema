import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/repositories/theme_repository.dart';

void main() {
  final ThemeRepository repository = ThemeRepository.instance;

  setUp(() {
    // empty in-memory storage instead of the phone's real preferences
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    repository.themeMode.value = ThemeMode.dark;
  });

  group('ThemeRepository', () {
    test('starts in dark mode', () {
      expect(repository.themeMode.value, ThemeMode.dark);
      expect(repository.isDarkMode, isTrue);
    });

    test('load keeps dark mode when nothing has been saved', () async {
      repository.themeMode.value = ThemeMode.light;

      await repository.load();

      expect(repository.themeMode.value, ThemeMode.dark);
    });

    test('load reads a saved light mode choice', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(
              <String, Object>{ThemeRepository.darkModeKey: false});

      await repository.load();

      expect(repository.themeMode.value, ThemeMode.light);
      expect(repository.isDarkMode, isFalse);
    });

    test('load reads a saved dark mode choice', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(
              <String, Object>{ThemeRepository.darkModeKey: true});
      repository.themeMode.value = ThemeMode.light;

      await repository.load();

      expect(repository.themeMode.value, ThemeMode.dark);
    });

    test('setDarkMode(false) switches to light mode and saves it', () async {
      await repository.setDarkMode(false);

      expect(repository.themeMode.value, ThemeMode.light);
      expect(
          await SharedPreferencesAsync().getBool(ThemeRepository.darkModeKey),
          isFalse);
    });

    test('setDarkMode(true) switches to dark mode and saves it', () async {
      await repository.setDarkMode(false);
      await repository.setDarkMode(true);

      expect(repository.themeMode.value, ThemeMode.dark);
      expect(
          await SharedPreferencesAsync().getBool(ThemeRepository.darkModeKey),
          isTrue);
    });

    test('a saved choice is loaded again after a restart', () async {
      await repository.setDarkMode(false);
      repository.themeMode.value = ThemeMode.dark; // as if the app restarted

      await repository.load();

      expect(repository.themeMode.value, ThemeMode.light);
    });

    test('setDarkMode tells listeners such as MaterialApp', () async {
      int notifications = 0;
      void listener() => notifications++;
      repository.themeMode.addListener(listener);
      addTearDown(() => repository.themeMode.removeListener(listener));

      await repository.setDarkMode(false);

      expect(notifications, 1);
    });
  });
}
