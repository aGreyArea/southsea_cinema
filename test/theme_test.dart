import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/theme.dart';

void main() {
  group('cinemaDarkTheme', () {
    test('keeps the original dark colours', () {
      expect(cinemaDarkTheme.brightness, Brightness.dark);
      expect(cinemaDarkTheme.scaffoldBackgroundColor, cinemaBackground);
      expect(cinemaDarkTheme.colorScheme.surface, cinemaSurface);
      expect(cinemaDarkTheme.colorScheme.onSurface, cinemaFontWhite);
      expect(cinemaDarkTheme.colorScheme.onSurfaceVariant, cinemaFontMuted);
      expect(cinemaDarkTheme.appBarTheme.backgroundColor, cinemaSurface);
      expect(
          cinemaDarkTheme.appBarTheme.titleTextStyle!.color, cinemaFontWhite);
    });
  });

  group('cinemaLightTheme', () {
    test('uses a light background with white cards and dark text', () {
      expect(cinemaLightTheme.brightness, Brightness.light);
      expect(cinemaLightTheme.scaffoldBackgroundColor, cinemaLightBackground);
      expect(cinemaLightTheme.colorScheme.surface, cinemaLightSurface);
      expect(cinemaLightTheme.colorScheme.onSurface, cinemaFontDark);
      expect(
          cinemaLightTheme.colorScheme.onSurfaceVariant, cinemaLightFontMuted);
      expect(cinemaLightTheme.appBarTheme.backgroundColor, cinemaLightSurface);
      expect(
          cinemaLightTheme.appBarTheme.titleTextStyle!.color, cinemaFontDark);
    });
  });

  test('both themes keep the brand blue', () {
    for (final ThemeData theme in [cinemaDarkTheme, cinemaLightTheme]) {
      expect(theme.colorScheme.primary, cinemaBrand);
      expect(theme.appBarTheme.iconTheme!.color, cinemaBrand);
    }
  });
}
