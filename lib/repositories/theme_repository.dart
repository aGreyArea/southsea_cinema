import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  // one shared theme setting for the whole app
  static final ThemeRepository instance = ThemeRepository();

  static const String darkModeKey = 'dark_mode';

  // MaterialApp listens to this, so changing it re-themes the whole app.
  // The app was designed dark, so dark is the default.
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  // Created when needed rather than once up front, because
  // SharedPreferencesAsync throws if its storage has not been set up yet.
  SharedPreferencesAsync get _preferences => SharedPreferencesAsync();

  // Reads the saved choice when the app starts.
  Future<void> load() async {
    try {
      final bool? savedDarkMode = await _preferences.getBool(darkModeKey);
      themeMode.value =
          savedDarkMode == false ? ThemeMode.light : ThemeMode.dark;
    } catch (error) {
      // If the saved value can't be read, keep the default dark theme
      // rather than stopping the app from starting.
      debugPrint('Could not load the theme setting: $error');
      themeMode.value = ThemeMode.dark;
    }
  }

  // Switches the theme straight away and saves the choice for next time.
  Future<void> setDarkMode(bool darkMode) async {
    themeMode.value = darkMode ? ThemeMode.dark : ThemeMode.light;
    await _preferences.setBool(darkModeKey, darkMode);
  }
}
