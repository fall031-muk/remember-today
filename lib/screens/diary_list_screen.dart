import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../themes/font_themes.dart';
import 'diary_detail_screen.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<DiaryEntry> _diaries = [];
  bool _isLoading = true;
  FontThemeType _currentFont = FontThemeType.nanum;

  @override
  void initState() {
    super.initState();
    _loadSavedFont();
    _loadDiaries();
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

  Future<void> _loadDiaries() async {
    try {
      final diaries = await DatabaseService.getAllDiaries();
      setState(() {
        _diaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기를 불러오는데 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E7),
      appBar: AppBar(
        title: Text(
          '나의 일기장',
          style: FontThemes.getTextStyle(
            _currentFont,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B4513),
              ),
            )
          : _diaries.isEmpty
              ? _buildEmptyState()
              : _buildDiaryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            '아직 작성된 일기가 없어요',
            style: FontThemes.getTextStyle(
              _currentFont,
              fontSize: 18,
              color: Colors.grey[600]!,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '첫 번째 일기를 작성해보세요!',
            style: FontThemes.getTextStyle(
              _currentFont,
              fontSize: 14,
              color: Colors.grey[500]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _diaries.length,
        itemBuilder: (context, index) {
          final diary = _diaries[index];
          return _buildDiaryCard(diary);
        },
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry diary) {
    DateTime date = DateTime.parse(diary.date);
    String formattedDate = DateFormat('MM월 dd일 (E)', 'ko_KR').format(date);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryDetailScreen(diary: diary),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사진 썸네일
              if (diary.imageBytes != null) ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildThumbnailImage(diary.imageBytes!),
                  ),
                ),
                SizedBox(width: 15),
              ],
              
              // 일기 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: FontThemes.getTextStyle(
                            _currentFont,
                            fontSize: 16,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              diary.weather,
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(width: 8),
                            Text(
                              diary.mood,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      diary.content.length > 100 
                          ? '${diary.content.substring(0, 100)}...'
                          : diary.content,
                      style: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(String imagePath) {
    try {
      Uint8List imageBytes = base64Decode(imagePath);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[400],
              size: 30,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: Icon(
          Icons.photo,
          color: Colors.grey[400],
          size: 30,
        ),
      );
    }
  }
} 