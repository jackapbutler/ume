import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(
    bodyFontString,
    baseTextTheme,
  );
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(
    displayFontString,
    baseTextTheme,
  );
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 61, 33, 99),
      surfaceTint: Color(0xff6b538c),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffeddcff),
      onPrimaryContainer: Color(0xff533c73),
      secondary: Color(0xff645a70),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffebddf7),
      onSecondaryContainer: Color(0xff4c4357),
      tertiary: Color(0xff7f525b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd9df),
      onTertiaryContainer: Color(0xff653b43),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff1d1a20),
      onSurfaceVariant: Color(0xff4a454e),
      outline: Color(0xff7b757f),
      outlineVariant: Color(0xffccc4cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff322f35),
      inversePrimary: Color(0xffd7bafb),
      primaryFixed: Color(0xffeddcff),
      onPrimaryFixed: Color(0xff260e44),
      primaryFixedDim: Color(0xffd7bafb),
      onPrimaryFixedVariant: Color(0xff533c73),
      secondaryFixed: Color(0xffebddf7),
      onSecondaryFixed: Color(0xff20182a),
      secondaryFixedDim: Color(0xffcfc2da),
      onSecondaryFixedVariant: Color(0xff4c4357),
      tertiaryFixed: Color(0xffffd9df),
      onTertiaryFixed: Color(0xff321019),
      tertiaryFixedDim: Color(0xfff2b7c1),
      onTertiaryFixedVariant: Color(0xff653b43),
      surfaceDim: Color(0xffdfd8e0),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xfff3ecf4),
      surfaceContainerHigh: Color(0xffede6ee),
      surfaceContainerHighest: Color(0xffe7e0e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff412b61),
      surfaceTint: Color(0xff6b538c),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff7a629c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3b3246),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff73697f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff522a33),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff906069),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff131015),
      onSurfaceVariant: Color(0xff39343d),
      outline: Color(0xff56515a),
      outlineVariant: Color(0xff716b75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff322f35),
      inversePrimary: Color(0xffd7bafb),
      primaryFixed: Color(0xff7a629c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff614a82),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff73697f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff5a5166),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff906069),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff754851),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffcbc4cc),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xffede6ee),
      surfaceContainerHigh: Color(0xffe2dbe2),
      surfaceContainerHighest: Color(0xffd6cfd7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff372056),
      surfaceTint: Color(0xff6b538c),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff553e75),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff31293b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4f455a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff462129),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff673d46),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2f2a33),
      outlineVariant: Color(0xff4c4750),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff322f35),
      inversePrimary: Color(0xffd7bafb),
      primaryFixed: Color(0xff553e75),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3e275d),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4f455a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff372f42),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff673d46),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4d272f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbdb7be),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6eef6),
      surfaceContainer: Color(0xffe7e0e8),
      surfaceContainerHigh: Color(0xffd9d2da),
      surfaceContainerHighest: Color(0xffcbc4cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd7bafb),
      surfaceTint: Color(0xffd7bafb),
      onPrimary: Color(0xff3b255a),
      primaryContainer: Color(0xff533c73),
      onPrimaryContainer: Color(0xffeddcff),
      secondary: Color(0xffcfc2da),
      onSecondary: Color(0xff352d40),
      secondaryContainer: Color(0xff4c4357),
      onSecondaryContainer: Color(0xffebddf7),
      tertiary: Color(0xfff2b7c1),
      onTertiary: Color(0xff4b252d),
      tertiaryContainer: Color(0xff653b43),
      onTertiaryContainer: Color(0xffffd9df),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff151218),
      onSurface: Color(0xffe7e0e8),
      onSurfaceVariant: Color(0xffccc4cf),
      outline: Color(0xff958e99),
      outlineVariant: Color(0xff4a454e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe7e0e8),
      inversePrimary: Color(0xff6b538c),
      primaryFixed: Color(0xffeddcff),
      onPrimaryFixed: Color(0xff260e44),
      primaryFixedDim: Color(0xffd7bafb),
      onPrimaryFixedVariant: Color(0xff533c73),
      secondaryFixed: Color(0xffebddf7),
      onSecondaryFixed: Color(0xff20182a),
      secondaryFixedDim: Color(0xffcfc2da),
      onSecondaryFixedVariant: Color(0xff4c4357),
      tertiaryFixed: Color(0xffffd9df),
      onTertiaryFixed: Color(0xff321019),
      tertiaryFixedDim: Color(0xfff2b7c1),
      onTertiaryFixedVariant: Color(0xff653b43),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff3b383e),
      surfaceContainerLowest: Color(0xff100d12),
      surfaceContainerLow: Color(0xff1d1a20),
      surfaceContainer: Color(0xff211e24),
      surfaceContainerHigh: Color(0xff2c292f),
      surfaceContainerHighest: Color(0xff37333a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe8d4ff),
      surfaceTint: Color(0xffd7bafb),
      onPrimary: Color(0xff30194f),
      primaryContainer: Color(0xff9f85c2),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffe5d7f1),
      onSecondary: Color(0xff2a2235),
      secondaryContainer: Color(0xff988ca3),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd1d8),
      onTertiary: Color(0xff3e1a23),
      tertiaryContainer: Color(0xffb7838c),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe2dae5),
      outline: Color(0xffb7afba),
      outlineVariant: Color(0xff958e98),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe7e0e8),
      inversePrimary: Color(0xff543d74),
      primaryFixed: Color(0xffeddcff),
      onPrimaryFixed: Color(0xff1b0239),
      primaryFixedDim: Color(0xffd7bafb),
      onPrimaryFixedVariant: Color(0xff412b61),
      secondaryFixed: Color(0xffebddf7),
      onSecondaryFixed: Color(0xff150e1f),
      secondaryFixedDim: Color(0xffcfc2da),
      onSecondaryFixedVariant: Color(0xff3b3246),
      tertiaryFixed: Color(0xffffd9df),
      onTertiaryFixed: Color(0xff25060f),
      tertiaryFixedDim: Color(0xfff2b7c1),
      onTertiaryFixedVariant: Color(0xff522a33),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff474349),
      surfaceContainerLowest: Color(0xff08070b),
      surfaceContainerLow: Color(0xff1f1c22),
      surfaceContainer: Color(0xff2a272c),
      surfaceContainerHigh: Color(0xff353137),
      surfaceContainerHighest: Color(0xff403c43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff7ecff),
      surfaceTint: Color(0xffd7bafb),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffd3b7f7),
      onPrimaryContainer: Color(0xff13002e),
      secondary: Color(0xfff7ecff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffcbbed6),
      onSecondaryContainer: Color(0xff0f0819),
      tertiary: Color(0xffffebed),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffeeb3be),
      onTertiaryContainer: Color(0xff1d0209),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff6edf9),
      outlineVariant: Color(0xffc8c0cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe7e0e8),
      inversePrimary: Color(0xff543d74),
      primaryFixed: Color(0xffeddcff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffd7bafb),
      onPrimaryFixedVariant: Color(0xff1b0239),
      secondaryFixed: Color(0xffebddf7),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffcfc2da),
      onSecondaryFixedVariant: Color(0xff150e1f),
      tertiaryFixed: Color(0xffffd9df),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff2b7c1),
      onTertiaryFixedVariant: Color(0xff25060f),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff534f55),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff211e24),
      surfaceContainer: Color(0xff322f35),
      surfaceContainerHigh: Color(0xff3e3a40),
      surfaceContainerHighest: Color(0xff49454c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
