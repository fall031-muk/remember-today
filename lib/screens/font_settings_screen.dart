import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/font_themes.dart';

class FontSettingsScreen extends StatefulWidget {
  final Function(FontThemeType) onFontChanged;
  final FontThemeType currentFont;

  const FontSettingsScreen({
    super.key,
    required this.onFontChanged,
    required this.currentFont,
  });

  @override
  State<FontSettingsScreen> createState() => _FontSettingsScreenState();
}

class _FontSettingsScreenState extends State<FontSettingsScreen> {
  late FontThemeType _selectedFont;

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.currentFont;
  }

  Future<void> _saveFont(FontThemeType font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_font', font.toString());
    setState(() {
      _selectedFont = font;
    });
    widget.onFontChanged(font);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '글씨체 설정',
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
              '한글 손글씨 글씨체를 선택해보세요',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '일기 작성과 표시에 적용됩니다',
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: FontThemes.getAllFontTypes().length,
                itemBuilder: (context, index) {
                  final fontType = FontThemes.getAllFontTypes()[index];
                  final isSelected = _selectedFont == fontType;
                  
                  return _buildFontCard(fontType, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontCard(FontThemeType fontType, bool isSelected) {
    final fontName = FontThemes.getFontName(fontType);
    final fontDescription = FontThemes.getFontDescription(fontType);

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: isSelected ? 8 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => _saveFont(fontType),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 폰트 이름과 선택 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fontName,
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // 폰트 설명
                Text(
                  fontDescription,
                  style: GoogleFonts.notoSerif(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: 15),
                
                // 폰트 미리보기
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '미리보기',
                        style: GoogleFonts.notoSerif(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '오늘은 정말 좋은 하루였어요! 😊\n새로운 일기장 앱을 만들어서 기분이 좋네요.',
                        style: FontThemes.getTextStyle(
                          fontType,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Today was a wonderful day! 🌟\nI\'m so happy to create this diary app.',
                        style: FontThemes.getTextStyle(
                          fontType,
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 