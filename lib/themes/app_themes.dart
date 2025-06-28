import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType {
  schoolDiary, // 학교 일기장 (노란색 공책)
  candyShop, // 문방구 사탕가게 (분홍/빨강)
  summerVacation, // 여름방학 (하늘색/민트)
  autumnLeaf, // 가을 단풍 (주황/갈색)
  winterStory, // 겨울 이야기 (보라/남색)
}

class AppThemes {
  static const Map<AppThemeType, Map<String, dynamic>> _themes = {
    AppThemeType.schoolDiary: {
      'name': '📒 학교 일기장',
      'description': '노란 공책과 연필의 추억',
      'primary': 0xFFE6B800, // 진한 노랑 (연필심 색)
      'background': 0xFFFFFAE6, // 연한 크림 노랑 (공책 색)
      'accent': 0xFFFF9500, // 주황 (형광펜 색)
      'emoji': '📒',
    },
    AppThemeType.candyShop: {
      'name': '🍭 문방구 사탕가게',
      'description': '달콤한 사탕과 스티커의 추억',
      'primary': 0xFFE91E63, // 진한 핑크 (사탕 색)
      'background': 0xFFFCE4EC, // 연한 핑크 (솜사탕 색)
      'accent': 0xFFFF5722, // 빨강 (딸기맛 색)
      'emoji': '🍭',
    },
    AppThemeType.summerVacation: {
      'name': '🌊 여름방학',
      'description': '바다와 수박의 시원한 추억',
      'primary': 0xFF00BCD4, // 하늘색 (바다 색)
      'background': 0xFFE0F7FA, // 연한 민트 (시원한 색)
      'accent': 0xFF4CAF50, // 초록 (수박 껍질 색)
      'emoji': '🌊',
    },
    AppThemeType.autumnLeaf: {
      'name': '🍂 가을 단풍',
      'description': '낙엽과 고구마의 따뜻한 추억',
      'primary': 0xFFFF6F00, // 주황 (단풍 색)
      'background': 0xFFFFF3E0, // 연한 주황 (석양 색)
      'accent': 0xFF8D6E63, // 갈색 (나무 색)
      'emoji': '🍂',
    },
    AppThemeType.winterStory: {
      'name': '❄️ 겨울 이야기',
      'description': '눈과 호빵의 포근한 추억',
      'primary': 0xFF3F51B5, // 남색 (겨울 하늘 색)
      'background': 0xFFF3F5FF, // 연한 보라 (눈 오는 하늘 색)
      'accent': 0xFF9C27B0, // 보라 (겨울 꽃 색)
      'emoji': '❄️',
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

  static String getThemeDescription(AppThemeType themeType) {
    return _themes[themeType]!['description'] ?? '';
  }

  static String getThemeEmoji(AppThemeType themeType) {
    return _themes[themeType]!['emoji'] ?? '';
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