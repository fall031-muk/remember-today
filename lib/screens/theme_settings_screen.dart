import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';

class ThemeSettingsScreen extends StatefulWidget {
  final Function(AppThemeType) onThemeChanged;
  final AppThemeType currentTheme;

  const ThemeSettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  late AppThemeType _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  Future<void> _saveTheme(AppThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme.toString());
    setState(() {
      _selectedTheme = theme;
    });
    widget.onThemeChanged(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '테마 설정',
          style: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '레트로 감성 테마를 선택해보세요',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,
                ),
                itemCount: AppThemeType.values.length,
                itemBuilder: (context, index) {
                  final themeType = AppThemeType.values[index];
                  final isSelected = _selectedTheme == themeType;
                  
                  return _buildThemeCard(themeType, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppThemeType themeType, bool isSelected) {
    final primaryColor = AppThemes.getPrimaryColor(themeType);
    final backgroundColor = AppThemes.getBackgroundColor(themeType);
    final accentColor = AppThemes.getAccentColor(themeType);
    final themeName = AppThemes.getThemeName(themeType);

    return GestureDetector(
      onTap: () => _saveTheme(themeType),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 테마 색상 미리보기
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 30,
                      )
                    : null,
              ),
            ),
            // 테마 이름
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      themeName,
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isSelected) ...[
                      SizedBox(height: 4),
                      Text(
                        '선택됨',
                        style: GoogleFonts.notoSerif(
                          fontSize: 10,
                          color: primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 