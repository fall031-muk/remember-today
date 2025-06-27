import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../services/share_service.dart';
import '../themes/font_themes.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  FontThemeType _currentFont = FontThemeType.nanum;

  @override
  void initState() {
    super.initState();
    _loadSavedFont();
  }

  Future<void> _loadSavedFont() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFont = prefs.getString('app_font');
    if (savedFont != null) {
      setState(() {
        _currentFont = FontThemeType.values.firstWhere(
          (font) => font.toString() == savedFont,
          orElse: () => FontThemeType.nanum,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(widget.diary.date);
    String formattedDate = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              ShareService.showShareOptions(context, widget.diary);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기분과 날씨
              _buildMoodWeatherDisplay(context),
              SizedBox(height: 30),
              
              // 사진 (있다면)
              if (widget.diary.imagePath != null) ...[
                _buildImageDisplay(context),
                SizedBox(height: 30),
              ],
              
              // 일기 내용
              _buildContentDisplay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodWeatherDisplay(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '오늘의 날씨',
                style: GoogleFonts.notoSerif(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.diary.weather,
                style: TextStyle(fontSize: 40),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.grey[300],
          ),
          Column(
            children: [
              Text(
                '오늘의 기분',
                style: GoogleFonts.notoSerif(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.diary.mood,
                style: TextStyle(fontSize: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 사진',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.photo,
                size: 50,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 이야기',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 15),
          Text(
            widget.diary.content,
            style: FontThemes.getTextStyle(
              _currentFont,
              fontSize: 18,
              color: Theme.of(context).primaryColor,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
} 