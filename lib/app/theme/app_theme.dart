import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.indigo,
      useMaterial3: true,
      subThemesData: const FlexSubThemesData(
        cardRadius: 16.0,
        dialogRadius: 16.0,
        defaultRadius: 12.0,
        inputDecoratorRadius: 12.0,
        inputDecoratorIsFilled: true,
        inputDecoratorUnfocusedHasBorder: false,
      ),
    );
  }

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.indigo,
      useMaterial3: true,
      subThemesData: const FlexSubThemesData(
        cardRadius: 16.0,
        dialogRadius: 16.0,
        defaultRadius: 12.0,
        inputDecoratorRadius: 12.0,
        inputDecoratorIsFilled: true,
        inputDecoratorUnfocusedHasBorder: false,
      ),
    );
  }
}
