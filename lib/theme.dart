import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';

// Widgets read their colours from Theme.of(context).colorScheme, so they
// follow whichever of these themes MaterialApp is using:
//   onSurface        - normal text
//   onSurfaceVariant - muted text, e.g. field labels
//   surface          - cards, app bar and input fields
//   outlineVariant   - input field borders

final ThemeData cinemaDarkTheme = _buildTheme(
  brightness: Brightness.dark,
  background: cinemaBackground,
  surface: cinemaSurface,
  text: cinemaFontWhite,
  mutedText: cinemaFontMuted,
  outline: cinemaOutline,
);

final ThemeData cinemaLightTheme = _buildTheme(
  brightness: Brightness.light,
  background: cinemaLightBackground,
  surface: cinemaLightSurface,
  text: cinemaFontDark,
  mutedText: cinemaLightFontMuted,
  outline: cinemaLightOutline,
);

ThemeData _buildTheme({
  required Brightness brightness,
  required Color background,
  required Color surface,
  required Color text,
  required Color mutedText,
  required Color outline,
}) {
  final ThemeData base =
      brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: cinemaBrand,
      brightness: brightness,
      primary: cinemaBrand,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: mutedText,
      outlineVariant: outline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      iconTheme: const IconThemeData(color: cinemaBrand),
      titleTextStyle: cinemaHeaderStyle.copyWith(color: text),
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: background),
  );
}
