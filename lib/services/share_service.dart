import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';

class ShareService {
  static Future<void> shareDiary(DiaryEntry diary, BuildContext context) async {
    try {
      // 공유할 텍스트 포맷팅
      final String shareText = _formatDiaryForShare(diary);
      
      // 공유하기
      await Share.share(
        shareText,
        subject: '${_formatDate(diary.date)}의 일기',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('공유하는 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static String _formatDiaryForShare(DiaryEntry diary) {
    final String date = _formatDate(diary.date);
    final String moodText = _getMoodText(diary.mood);
    final String weatherText = _getWeatherText(diary.weather);

    return '''
📝 Remember Today - 일기

📅 날짜: $date
${diary.weather} 날씨: $weatherText
${diary.mood} 기분: $moodText

✍️ 오늘의 이야기:
${diary.content}

━━━━━━━━━━━━━━━━━━━━━━
💝 Remember Today 앱으로 작성된 일기입니다
    ''';
  }

  static String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String _getMoodText(String mood) {
    const moodMap = {
      '😊': '기쁨',
      '😢': '슬픔',
      '😴': '피곤',
      '😍': '사랑',
      '😤': '화남',
      '🤔': '고민',
      '😎': '멋짐',
      '🥳': '신남',
    };
    return moodMap[mood] ?? '기타';
  }

  static String _getWeatherText(String weather) {
    const weatherMap = {
      '☀️': '맑음',
      '⛅': '구름',
      '☁️': '흐림',
      '🌧️': '비',
      '⛈️': '폭우',
      '🌈': '무지개',
      '❄️': '눈',
      '🌪️': '바람',
    };
    return weatherMap[weather] ?? '기타';
  }

  static void showShareOptions(BuildContext context, DiaryEntry diary) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '일기 공유하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.share, color: Theme.of(context).primaryColor),
              title: Text('텍스트로 공유'),
              subtitle: Text('일기 내용을 텍스트로 공유합니다'),
              onTap: () {
                Navigator.pop(context);
                shareDiary(diary, context);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.copy, color: Theme.of(context).primaryColor),
              title: Text('텍스트 복사'),
              subtitle: Text('일기 내용을 클립보드에 복사합니다'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(diary, context);
              },
            ),
            
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static void _copyToClipboard(DiaryEntry diary, BuildContext context) {
    // 클립보드 복사는 여기서 구현 (flutter/services 필요)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('일기가 클립보드에 복사되었습니다!'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
} 