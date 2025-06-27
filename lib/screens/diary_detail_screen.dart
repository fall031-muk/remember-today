import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 사진',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (_hasImage())
                Text(
                  '탭하여 크게 보기',
                  style: GoogleFonts.notoSerif(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: _hasImage() ? () => _showFullScreenImage(context) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: 200,
                  maxHeight: 400, // 최대 높이 설정
                ),
                child: _buildImageWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasImage() {
    return (widget.diary.imageBytes != null && widget.diary.imageBytes!.isNotEmpty) ||
           (widget.diary.imagePath != null && widget.diary.imagePath!.isNotEmpty && !kIsWeb);
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: _buildFullScreenImageWidget(),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenImageWidget() {
    // 저장된 이미지 바이트 데이터가 있으면 우선 사용
    if (widget.diary.imageBytes != null && widget.diary.imageBytes!.isNotEmpty) {
      try {
        Uint8List imageBytes = base64Decode(widget.diary.imageBytes!);
        return Image.memory(
          imageBytes,
          fit: BoxFit.contain,
        );
      } catch (e) {
        return Container();
      }
    }
    
    // 파일 경로가 있으면 사용 (모바일에서만)
    if (widget.diary.imagePath != null && widget.diary.imagePath!.isNotEmpty && !kIsWeb) {
      return Image.file(
        File(widget.diary.imagePath!),
        fit: BoxFit.contain,
      );
    }
    
    return Container();
  }

  Widget _buildImageWidget() {
    // 1. 저장된 이미지 바이트 데이터가 있으면 우선 사용
    if (widget.diary.imageBytes != null && widget.diary.imageBytes!.isNotEmpty) {
      try {
        Uint8List imageBytes = base64Decode(widget.diary.imageBytes!);
        return Image.memory(
          imageBytes,
          width: double.infinity,
          fit: BoxFit.contain, // 전체 이미지 표시
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget('저장된 이미지를 불러올 수 없습니다');
          },
        );
      } catch (e) {
        print('Base64 디코딩 오류: $e');
        return _buildErrorWidget('이미지 데이터가 손상되었습니다');
      }
    }
    
    // 2. 파일 경로가 있으면 사용 (모바일에서만)
    if (widget.diary.imagePath != null && widget.diary.imagePath!.isNotEmpty) {
      if (kIsWeb) {
        return _buildWebNoImageWidget();
      } else {
        return Image.file(
          File(widget.diary.imagePath!),
          width: double.infinity,
          fit: BoxFit.contain, // 전체 이미지 표시
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget('이미지 파일을 불러올 수 없습니다');
          },
        );
      }
    }
    
    // 3. 이미지가 없는 경우
    return _buildNoImageWidget();
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey[500],
          ),
          SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebNoImageWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 50,
            color: Colors.grey[500],
          ),
          SizedBox(height: 10),
          Text(
            '웹에서는 파일 경로로 저장된\n이미지를 표시할 수 없습니다',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImageWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo,
            size: 50,
            color: Colors.grey[500],
          ),
          SizedBox(height: 10),
          Text(
            '이미지가 없습니다',
            style: GoogleFonts.notoSerif(
              color: Colors.grey[600],
              fontSize: 12,
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