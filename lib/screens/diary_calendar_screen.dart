import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../services/share_service.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadDiaryEntries();
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
          style: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
                    // 스타일링
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: GoogleFonts.notoSerif(
                        color: Colors.red[400],
                      ),
                      holidayTextStyle: GoogleFonts.notoSerif(
                        color: Colors.red[400],
                      ),
                      defaultTextStyle: GoogleFonts.notoSerif(),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      formatButtonTextStyle: GoogleFonts.notoSerif(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      titleTextStyle: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).primaryColor,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.notoSerif(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      weekendStyle: GoogleFonts.notoSerif(
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
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
          style: GoogleFonts.notoSerif(
            fontSize: 16,
            color: Colors.grey[600],
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
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
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
          // 일기 내용
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
                         child: Text(
               diary.content,
               style: GoogleFonts.caveat( // 손글씨 스타일 폰트로 변경
                 fontSize: 18,
                 color: Theme.of(context).primaryColor,
                 height: 1.8,
               ),
             ),
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
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '새로운 일기를 작성해보세요!',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: Colors.grey[500],
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
} 