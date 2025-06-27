import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum FontThemeType {
  nanum, // 나눔손글씨
  jua, // 주아체
  gamja, // 감자꽃체
  sunflower, // 해바라기체
  stylish, // 스타일리시체
  cute, // 귀여운체
}

class FontThemes {
  static const Map<FontThemeType, Map<String, dynamic>> _fontThemes = {
    FontThemeType.nanum: {
      'name': '나눔손글씨',
      'fontFamily': 'NanumPenScript',
      'description': '자연스러운 손글씨 느낌',
    },
    FontThemeType.jua: {
      'name': '주아체',
      'fontFamily': 'Jua',
      'description': '둥글둥글 귀여운 글씨',
    },
    FontThemeType.gamja: {
      'name': '감자꽃체',
      'fontFamily': 'GamjaFlower',
      'description': '손으로 쓴 듯한 자연스러운 글씨',
    },
    FontThemeType.sunflower: {
      'name': '해바라기체',
      'fontFamily': 'Sunflower',
      'description': '밝고 경쾌한 손글씨',
    },
    FontThemeType.stylish: {
      'name': '스타일리시체',
      'fontFamily': 'Stylish',
      'description': '세련된 손글씨 스타일',
    },
    FontThemeType.cute: {
      'name': '귀여운체',
      'fontFamily': 'CuteFont',
      'description': '깜찍한 손글씨',
    },
  };

  static TextStyle getTextStyle(FontThemeType fontType, {
    double fontSize = 16,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) {
    final fontData = _fontThemes[fontType]!;
    final fontFamily = fontData['fontFamily'] as String;

    // Google Fonts에서 지원하는 한글 폰트들
    switch (fontType) {
      case FontThemeType.nanum:
        return GoogleFonts.nanumPenScript(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: height,
        );
      case FontThemeType.jua:
        return GoogleFonts.jua(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: height,
        );
      case FontThemeType.gamja:
        return GoogleFonts.gamjaFlower(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: height,
        );
      case FontThemeType.sunflower:
        return GoogleFonts.sunflower(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: height,
        );
      case FontThemeType.stylish:
        return GoogleFonts.stylish(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: height,
        );
      case FontThemeType.cute:
        return GoogleFonts.cuteFont(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: height,
        );
      default:
        return GoogleFonts.nanumPenScript(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: height,
        );
    }
  }

  static String getFontName(FontThemeType fontType) {
    return _fontThemes[fontType]!['name'];
  }

  static String getFontDescription(FontThemeType fontType) {
    return _fontThemes[fontType]!['description'];
  }

  static List<FontThemeType> getAllFontTypes() {
    return FontThemeType.values;
  }
} 