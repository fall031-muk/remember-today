import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../services/share_service.dart';
import '../themes/font_themes.dart';
import '../themes/app_themes.dart';
import 'diary_detail_screen.dart';

class DiaryCalendarScreen extends StatefulWidget {
  const DiaryCalendarScreen({super.key});

  @override
  State<DiaryCalendarScreen> createState() => _DiaryCalendarScreenState();
}

class _DiaryCalendarScreenState extends State<DiaryCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, DiaryEntry> _diaryEntries = {};
  bool _isLoading = true;
  FontThemeType _currentFont = FontThemeType.nanum;
  AppThemeType _currentTheme = AppThemeType.schoolDiary;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadSavedSettings();
    _loadDiaryEntries();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 글씨체 불러오기
    final savedFont = prefs.getString('app_font');
    if (savedFont != null) {
      setState(() {
        _currentFont = FontThemeType.values.firstWhere(
          (font) => font.toString() == savedFont,
          orElse: () => FontThemeType.nanum,
        );
      });
    }
    
    // 테마 불러오기
    final savedTheme = prefs.getString('app_theme');
    if (savedTheme != null) {
      setState(() {
        _currentTheme = AppThemeType.values.firstWhere(
          (theme) => theme.toString() == savedTheme,
          orElse: () => AppThemeType.schoolDiary,
        );
      });
    }
  }

  Future<void> _loadDiaryEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final diaries = await DatabaseService.getAllDiaries();
      final Map<String, DiaryEntry> entriesMap = {};
      
      for (final diary in diaries) {
        entriesMap[diary.date] = diary;
      }

      setState(() {
        _diaryEntries = entriesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<DiaryEntry> _getEventsForDay(DateTime day) {
    String dateKey = DateFormat('yyyy-MM-dd').format(day);
    final entry = _diaryEntries[dateKey];
    return entry != null ? [entry] : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '일기 캘린더',
          style: FontThemes.getTextStyle(
            _currentFont,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Column(
              children: [
                // 캘린더
                Container(
                  margin: EdgeInsets.all(16),
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
                  child: TableCalendar<DiaryEntry>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: 'ko_KR',
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    // 기분 이모티콘 표시
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          final diary = events.first as DiaryEntry;
                          return Positioned(
                            bottom: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(2),
                              child: Text(
                                diary.mood,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    // 스타일링
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 16,
                        color: Colors.red[400]!,
                      ),
                      holidayTextStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 16,
                        color: Colors.red[400]!,
                      ),
                      defaultTextStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      selectedTextStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      todayTextStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppThemes.getPrimaryColor(_currentTheme),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppThemes.getPrimaryColor(_currentTheme).withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppThemes.getPrimaryColor(_currentTheme).withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                      markerSize: 6,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: AppThemes.getPrimaryColor(_currentTheme),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      formatButtonTextStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      titleTextStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 18,
                        color: AppThemes.getPrimaryColor(_currentTheme),
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: AppThemes.getPrimaryColor(_currentTheme),
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: AppThemes.getPrimaryColor(_currentTheme),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 14,
                        color: Colors.grey[600]!,
                      ),
                      weekendStyle: FontThemes.getTextStyle(
                        _currentFont,
                        fontSize: 14,
                        color: Colors.red[400]!,
                      ),
                    ),
                  ),
                ),
                
                // 선택된 날짜의 일기
                Expanded(
                  child: _buildSelectedDayContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildSelectedDayContent() {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          '날짜를 선택해주세요',
          style: FontThemes.getTextStyle(
            _currentFont,
            fontSize: 16,
            color: Colors.grey[600]!,
          ),
        ),
      );
    }

    String selectedDateKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final diary = _diaryEntries[selectedDateKey];
    String formattedDate = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(_selectedDay!);

    return Container(
      margin: EdgeInsets.all(16),
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
          // 날짜 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: FontThemes.getTextStyle(
                  _currentFont,
                  fontSize: 18,
                  color: AppThemes.getPrimaryColor(_currentTheme),
                ),
              ),
              if (diary != null)
                Row(
                  children: [
                    Text(
                      diary.weather,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 8),
                    Text(
                      diary.mood,
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 20),
          
          // 일기 내용
          Expanded(
            child: diary != null
                ? _buildDiaryContent(diary)
                : _buildNoDiaryContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryContent(DiaryEntry diary) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사진과 일기 내용을 함께 표시
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사진 썸네일
              if (diary.imageBytes != null) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildThumbnailImage(diary.imageBytes!),
                  ),
                ),
                SizedBox(width: 15),
              ],
              
              // 일기 내용
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    diary.content,
                    style: FontThemes.getTextStyle(
                      _currentFont,
                      fontSize: 16,
                      color: AppThemes.getPrimaryColor(_currentTheme),
                      height: 1.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // 액션 버튼들
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailScreen(diary: diary),
                          ),
                        );
                      },
                      icon: Icon(Icons.visibility),
                      label: Text('자세히 보기'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareDiary(diary),
                      icon: Icon(Icons.share),
                      label: Text('공유하기'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // 선택된 날짜로 일기 수정 화면으로 이동
                    Navigator.pop(context, _selectedDay);
                  },
                  icon: Icon(Icons.edit),
                  label: Text('이 날 일기 수정하기'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDiaryContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            '이 날의 일기가 없어요',
            style: FontThemes.getTextStyle(
              _currentFont,
              fontSize: 18,
              color: Colors.grey[600]!,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '새로운 일기를 작성해보세요!',
            style: FontThemes.getTextStyle(
              _currentFont,
              fontSize: 14,
              color: Colors.grey[500]!,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // 선택된 날짜로 일기 작성 화면으로 이동
              Navigator.pop(context, _selectedDay);
            },
            icon: Icon(Icons.add),
            label: Text('이 날 일기 쓰기'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareDiary(DiaryEntry diary) {
    ShareService.showShareOptions(context, diary);
  }

  Widget _buildThumbnailImage(String imageBytes) {
    try {
      Uint8List bytes = base64Decode(imageBytes);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[400],
              size: 24,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: Icon(
          Icons.broken_image,
          color: Colors.grey[400],
          size: 24,
        ),
      );
    }
  }
} 