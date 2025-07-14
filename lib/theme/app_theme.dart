import 'package:flutter/material.dart';

// Цвета для ячеек игрового поля
class GameColors {
  // Основные цвета, подобранные по картинке
  static const background = Color(0xFF0A1A6B); // Глубокий синий фон
  static const cellGradientStart = Color(
    0xFF2233AA,
  ); // Ячейка: насыщенный синий
  static const cellGradientEnd = Color(0xFF1A2AFF); // Ячейка: светлее
  static const border = Color(0xFF0A1A6B); // Темно-синий бордер
  static const priceText = Color(0xFFFFEB3B); // Ярко-желтый для цен
  static const themeText = Colors.white; // Белый для тем

  // Градиенты для ячеек
  static const List<Color> cellGradient = [cellGradientStart, cellGradientEnd];
}

class AppTheme {
  // Цвета для светлой и темной темы одинаковые (игровое поле всегда синее)
  static final ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: GameColors.cellGradientStart,
    onPrimary: Colors.white,
    secondary: GameColors.cellGradientEnd,
    onSecondary: Colors.white,
    tertiary: GameColors.priceText,
    onTertiary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: GameColors.cellGradientStart,
    onSurface: Colors.white,
    surfaceContainerHighest: GameColors.cellGradientEnd,
    onSurfaceVariant: Colors.white,
    outline: GameColors.border,
    outlineVariant: GameColors.border,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Colors.white,
    onInverseSurface: GameColors.background,
    inversePrimary: GameColors.cellGradientEnd,
    surfaceTint: GameColors.cellGradientStart,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GameColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: GameColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;

  // Цвета для ячеек
  static List<Color> getCellGradient() => GameColors.cellGradient;
  static Color getBorderColor() => GameColors.border;
  static Color getPriceTextColor() => GameColors.priceText;
  static Color getThemeTextColor() => GameColors.themeText;
}
