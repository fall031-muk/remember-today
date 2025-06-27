import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType {
  vintage, // 기본 브라운
  sunset, // 주황/빨강
  forest, // 초록
  ocean, // 파랑
  lavender, // 보라
  rose, // 핑크
}

class AppThemes {
  static const Map<AppThemeType, Map<String, dynamic>> _themes = {
    AppThemeType.vintage: {
      'name': '빈티지 브라운',
      'primary': 0xFF8B4513,
      'background': 0xFFFFF8E7,
      'accent': 0xFFCD853F,
    },
    AppThemeType.sunset: {
      'name': '석양 오렌지',
      'primary': 0xFFD2691E,
      'background': 0xFFFFF5EE,
      'accent': 0xFFFF7F50,
    },
    AppThemeType.forest: {
      'name': '숲속 그린',
      'primary': 0xFF556B2F,
      'background': 0xFFF0FFF0,
      'accent': 0xFF9ACD32,
    },
    AppThemeType.ocean: {
      'name': '바다 블루',
      'primary': 0xFF4682B4,
      'background': 0xFFF0F8FF,
      'accent': 0xFF87CEEB,
    },
    AppThemeType.lavender: {
      'name': '라벤더 퍼플',
      'primary': 0xFF9370DB,
      'background': 0xFFF8F0FF,
      'accent': 0xFFDDA0DD,
    },
    AppThemeType.rose: {
      'name': '로즈 핑크',
      'primary': 0xFFBC8F8F,
      'background': 0xFFFFF0F5,
      'accent': 0xFFFFB6C1,
    },
  };

  static ThemeData getTheme(AppThemeType themeType) {
    final themeData = _themes[themeType]!;
    final primaryColor = Color(themeData['primary']);
    final backgroundColor = Color(themeData['background']);
    final accentColor = Color(themeData['accent']);

    return ThemeData(
      primarySwatch: _createMaterialColor(primaryColor),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        background: backgroundColor,
      ),
      textTheme: GoogleFonts.notoSerifTextTheme(),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryColor, width: 2),
          foregroundColor: primaryColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  static String getThemeName(AppThemeType themeType) {
    return _themes[themeType]!['name'];
  }

  static Color getPrimaryColor(AppThemeType themeType) {
    return Color(_themes[themeType]!['primary']);
  }

  static Color getBackgroundColor(AppThemeType themeType) {
    return Color(_themes[themeType]!['background']);
  }

  static Color getAccentColor(AppThemeType themeType) {
    return Color(_themes[themeType]!['accent']);
  }

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
} 