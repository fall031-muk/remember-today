import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/diary_entry.dart';
import 'services/database_service.dart';
import 'services/share_service.dart';
import 'screens/diary_list_screen.dart';
import 'screens/diary_search_screen.dart';
import 'screens/diary_calendar_screen.dart';
import 'screens/theme_settings_screen.dart';
import 'screens/font_settings_screen.dart';
import 'themes/app_themes.dart';
import 'themes/font_themes.dart';
import 'services/image_filter_service.dart';
import 'themes/diary_decorations.dart';
import 'dart:convert';
import 'dart:math' as math;

void main() {
  runApp(const RememberTodayApp());
}

class RememberTodayApp extends StatefulWidget {
  const RememberTodayApp({super.key});

  @override
  State<RememberTodayApp> createState() => _RememberTodayAppState();
}

class _RememberTodayAppState extends State<RememberTodayApp> {
  AppThemeType _currentTheme = AppThemeType.schoolDiary;
  FontThemeType _currentFont = FontThemeType.nanum;

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
    _loadSavedFont();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
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

  void _onThemeChanged(AppThemeType newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  void _onFontChanged(FontThemeType newFont) {
    setState(() {
      _currentFont = newFont;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remember Today',
      theme: AppThemes.getTheme(_currentTheme),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: Locale('ko', 'KR'),
      home: DiaryHomePage(
        currentTheme: _currentTheme,
        onThemeChanged: _onThemeChanged,
        currentFont: _currentFont,
        onFontChanged: _onFontChanged,
      ),
    );
  }
}

class DiaryHomePage extends StatefulWidget {
  final AppThemeType currentTheme;
  final Function(AppThemeType) onThemeChanged;
  final FontThemeType currentFont;
  final Function(FontThemeType) onFontChanged;

  const DiaryHomePage({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.currentFont,
    required this.onFontChanged,
  });

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  String _selectedMood = '😊';
  String _selectedWeather = '☀️';
  String _diaryText = '';
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  Uint8List? _filteredImageBytes;
  ImageFilterType? _selectedFilter;
  bool _isProcessingFilter = false;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _currentDiaryId; // 수정 중인 일기의 ID
  
  final List<String> _moods = ['😊', '😢', '😴', '😍', '😤', '🤔', '😎', '🥳'];
  final List<String> _weathers = ['☀️', '⛅', '☁️', '🌧️', '⛈️', '🌈', '❄️', '🌪️'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaryForDate(DateTime selectedDate) async {
    setState(() {
      _selectedDate = selectedDate;
      _isLoading = true;
    });

    try {
      String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
      DiaryEntry? existingDiary = await DatabaseService.getDiaryByDate(dateKey);
      
      if (existingDiary != null) {
        // 기존 일기가 있으면 로드
        setState(() {
          _currentDiaryId = existingDiary.id;
          _selectedMood = existingDiary.mood;
          _selectedWeather = existingDiary.weather;
          _textController.text = existingDiary.content;
          // 이미지는 나중에 처리할 수 있음
          _selectedImage = null;
          _selectedImageBytes = null;
          _filteredImageBytes = null;
          _selectedFilter = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${DateFormat('MM월 dd일').format(selectedDate)} 일기를 불러왔습니다! ✏️'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } else {
        // 새 일기 작성
        setState(() {
          _currentDiaryId = null;
          _selectedMood = '😊';
          _selectedWeather = '☀️';
          _textController.clear();
          _selectedImage = null;
          _selectedImageBytes = null;
          _filteredImageBytes = null;
          _selectedFilter = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${DateFormat('MM월 dd일').format(selectedDate)} 새 일기를 작성하세요! 📝'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일기를 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('이미지 선택됨: ${image.path}');
        final bytes = await image.readAsBytes();
        print('이미지 바이트 크기: ${bytes.length}');
        
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
          _filteredImageBytes = null; // 새 이미지 선택시 필터 초기화
          _selectedFilter = null;
        });
        
        print('이미지 상태 업데이트 완료');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사진이 선택되었습니다! 🖼️'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } else {
        print('이미지 선택 취소됨');
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _applyImageFilter(ImageFilterType filterType) async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isProcessingFilter = true;
      _selectedFilter = filterType;
    });

    try {
      // 로딩 표시를 위한 최소 대기 시간과 필터 처리를 병렬로 실행
      final filterFuture = FilterInfo.applyFilter(filterType, _selectedImageBytes!);
      final minWaitFuture = Future.delayed(Duration(milliseconds: 1500)); // 1.5초 최소 로딩 시간
      
      // 둘 다 완료될 때까지 대기
      final results = await Future.wait([filterFuture, minWaitFuture]);
      final Uint8List filteredBytes = results[0] as Uint8List;

      setState(() {
        _filteredImageBytes = filteredBytes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${FilterInfo.allFilters.firstWhere((f) => f.type == filterType).name} 필터가 적용되었습니다! ✨'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필터 적용 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isProcessingFilter = false;
    });
  }

  void _resetImageFilter() {
    setState(() {
      _filteredImageBytes = null;
      _selectedFilter = null;
    });
  }

  void _showFullScreenImage(BuildContext context) {
    if (_selectedImageBytes == null) return;

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
                child: Image.memory(
                  _filteredImageBytes ?? _selectedImageBytes!,
                  fit: BoxFit.contain,
                ),
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

  Future<void> _saveDiary() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일기 내용을 입력해주세요!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String selectedDateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // 이미지 바이트를 Base64로 인코딩 (필터 적용된 이미지 우선)
      String? encodedImageBytes;
      if (_filteredImageBytes != null) {
        encodedImageBytes = base64Encode(_filteredImageBytes!);
      } else if (_selectedImageBytes != null) {
        encodedImageBytes = base64Encode(_selectedImageBytes!);
      }
      
      DiaryEntry newEntry = DiaryEntry(
        id: _currentDiaryId,
        date: selectedDateKey,
        mood: _selectedMood,
        weather: _selectedWeather,
        content: _textController.text,
        imagePath: _selectedImage?.path,
        imageBytes: encodedImageBytes,
        createdAt: DateTime.now(),
      );

      if (_currentDiaryId != null) {
        // 업데이트
        await DatabaseService.updateDiary(newEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${DateFormat('MM월 dd일').format(_selectedDate)} 일기가 수정되었습니다! 📝'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } else {
        // 새로 저장
        await DatabaseService.insertDiary(newEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${DateFormat('MM월 dd일').format(_selectedDate)} 일기가 저장되었습니다! 📝'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }

      // 저장 후 현재 일기 ID 업데이트 (새로 저장된 경우)
      if (_currentDiaryId == null) {
        // 새로 저장된 일기의 ID를 가져와서 설정
        String selectedDateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
        DiaryEntry? savedDiary = await DatabaseService.getDiaryByDate(selectedDateKey);
        if (savedDiary != null) {
          setState(() {
            _currentDiaryId = savedDiary.id;
          });
        }
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Remember Today',
          style: GoogleFonts.permanentMarker(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text('일기 검색'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiarySearchScreen(),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.calendar_month),
                  title: Text('캘린더 보기'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () async {
                  Navigator.pop(context); // 먼저 메뉴 닫기
                  final selectedDate = await Navigator.push<DateTime>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryCalendarScreen(),
                    ),
                  );
                  if (selectedDate != null) {
                    _loadDiaryForDate(selectedDate);
                  }
                },
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.palette),
                  title: Text('테마 설정'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThemeSettingsScreen(
                        currentTheme: widget.currentTheme,
                        onThemeChanged: widget.onThemeChanged,
                      ),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.font_download),
                  title: Text('글씨체 설정'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FontSettingsScreen(
                        currentFont: widget.currentFont,
                        onFontChanged: widget.onFontChanged,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppThemes.getBackgroundColor(widget.currentTheme),
              AppThemes.getBackgroundColor(widget.currentTheme).withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🌈 홀로그램 헤더 - 90년대 다이어리 표지
                  _buildHologramHeader(),
                  
                  // 🎨 도화지 영역 - 그림과 사진
                  _buildArtSection(),
                  
                  // 📝 줄노트 영역 - 글쓰기만
                  _buildNotebookSection(),
                  
                  SizedBox(height: 20),
                  
                  // 액션 버튼들
                  _buildRetroActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHologramHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF6B9D), // 핑크
            Color(0xFFC44CE6), // 보라
            Color(0xFF4ECDC4), // 청록
            Color(0xFF45B7D1), // 파랑
            Color(0xFF96CEB4), // 연두
            Color(0xFFFECA57), // 노랑
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          // 홀로그램 효과를 위한 추가 그림자
          BoxShadow(
            color: Color(0xFFFF6B9D).withOpacity(0.3),
            offset: Offset(-2, -2),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Color(0xFF4ECDC4).withOpacity(0.3),
            offset: Offset(2, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 홀로그램 패턴 효과
          Positioned.fill(
            child: CustomPaint(
              painter: HologramPatternPainter(),
            ),
          ),
          
          // 메인 콘텐츠
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 다이어리 제목
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '💖 나만의 비밀일기 💖',
                        style: FontThemes.getTextStyle(
                          widget.currentFont,
                          fontSize: 16,
                          color: Color(0xFFFF1493),
                        ).copyWith(
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    // 자물쇠 아이콘
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('🔒', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
                
                SizedBox(height: 15),
                
                // 날짜와 기분/날씨 스티커들
                Row(
                  children: [
                    // 날짜 스티커
                    Transform.rotate(
                      angle: -0.02,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          DateFormat('MM/dd (E)', 'ko_KR').format(_selectedDate),
                          style: FontThemes.getTextStyle(
                            widget.currentFont,
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 10),
                    
                    // 기분 스티커
                    Transform.rotate(
                      angle: 0.01,
                      child: GestureDetector(
                        onTap: () => _showMoodSelector(),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(_selectedMood, style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // 날씨 스티커
                    Transform.rotate(
                      angle: -0.01,
                      child: GestureDetector(
                        onTap: () => _showWeatherSelector(),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(_selectedWeather, style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFF8), // 도화지 색
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 도화지 제목
          Transform.rotate(
            angle: -0.01,
            child: Text(
              '🎨 오늘의 그림일기',
              style: FontThemes.getTextStyle(
                widget.currentFont,
                fontSize: 16,
                color: Color(0xFF2E7D32),
              ).copyWith(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4CAF50).withOpacity(0.5),
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // 크레용 그림들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CrayonDrawing(type: 'sun', size: 60),
              CrayonDrawing(type: 'house', size: 70),
              CrayonDrawing(type: 'flower', size: 60),
              if (_selectedImageBytes != null)
                CrayonDrawing(type: 'family', size: 65),
            ],
          ),
          
          SizedBox(height: 20),
          
          // 폴라로이드 사진
          Center(child: _buildPolaroidPhoto()),
        ],
      ),
    );
  }

  Widget _buildNotebookSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFFFFFDF5), // 크림색 종이
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        painter: NotebookPainter(
          lineColor: Color(0xFFE3F2FD),
          marginColor: Color(0xFFFF9999),
          paperColor: Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(80, 30, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 일기 제목
              Transform.rotate(
                angle: -0.01,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    '📝 오늘의 이야기',
                    style: FontThemes.getTextStyle(
                      widget.currentFont,
                      fontSize: 14,
                      color: Color(0xFF2E7D32),
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 25),
              
              // 텍스트 입력 영역
              TextField(
                controller: _textController,
                maxLines: null,
                style: FontThemes.getTextStyle(
                  widget.currentFont,
                  fontSize: 16,
                  color: Color(0xFF1565C0),
                  height: 1.8,
                ).copyWith(
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0.5, 0.5),
                      blurRadius: 0.5,
                    ),
                  ],
                ),
                decoration: InputDecoration(
                  hintText: '오늘 있었던 일을 써보세요...\n\n친구들과 놀았던 이야기나\n맛있게 먹은 음식 이야기도 좋아요! 😊\n\n\n\n',
                  hintStyle: FontThemes.getTextStyle(
                    widget.currentFont,
                    fontSize: 14,
                    color: Colors.grey[500]!,
                    height: 1.8,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              
              SizedBox(height: 20),
              
              // 필터 섹션
              if (_selectedImageBytes != null) _buildRetroFilterSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFFFDF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '😊 오늘 기분은?',
          style: FontThemes.getTextStyle(
            widget.currentFont,
            fontSize: 18,
            color: Color(0xFF2E7D32),
          ),
          textAlign: TextAlign.center,
        ),
        content: Container(
          width: double.maxFinite,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _moods.map((mood) => GestureDetector(
              onTap: () {
                setState(() => _selectedMood = mood);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _selectedMood == mood 
                    ? Colors.pink.withOpacity(0.3) 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: _selectedMood == mood 
                    ? Border.all(color: Colors.pink, width: 2)
                    : Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Center(
                  child: Text(mood, style: TextStyle(fontSize: 24)),
                ),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _showWeatherSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFFFDF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🌤️ 오늘 날씨는?',
          style: FontThemes.getTextStyle(
            widget.currentFont,
            fontSize: 18,
            color: Color(0xFF2E7D32),
          ),
          textAlign: TextAlign.center,
        ),
        content: Container(
          width: double.maxFinite,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _weathers.map((weather) => GestureDetector(
              onTap: () {
                setState(() => _selectedWeather = weather);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _selectedWeather == weather 
                    ? Colors.blue.withOpacity(0.3) 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: _selectedWeather == weather 
                    ? Border.all(color: Colors.blue, width: 2)
                    : Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Center(
                  child: Text(weather, style: TextStyle(fontSize: 24)),
                ),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRetroActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // 메인 액션 버튼들
          Row(
            children: [
              Expanded(
                child: RetroButton(
                  text: _currentDiaryId != null ? '✏️ 수정하기' : '💾 저장하기',
                  color: AppThemes.getPrimaryColor(widget.currentTheme),
                  onPressed: _isLoading ? () {} : _saveDiary,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: RetroButton(
                  text: '📝 일기 목록',
                  color: AppThemes.getAccentColor(widget.currentTheme),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiaryListScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          
          SizedBox(height: 15),
          
          // 보조 버튼들 (작은 스티커 스타일)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniButton('🔍', '검색', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiarySearchScreen()),
                );
              }),
              _buildMiniButton('📅', '캘린더', () async {
                final selectedDate = await Navigator.push<DateTime>(
                  context,
                  MaterialPageRoute(builder: (context) => DiaryCalendarScreen()),
                );
                if (selectedDate != null) {
                  _loadDiaryForDate(selectedDate);
                }
              }),
              _buildMiniButton('🎨', '테마', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThemeSettingsScreen(
                      currentTheme: widget.currentTheme,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
              }),
              _buildMiniButton('✍️', '글씨체', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FontSettingsScreen(
                      currentFont: widget.currentFont,
                      onFontChanged: widget.onFontChanged,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniButton(String emoji, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppThemes.getAccentColor(widget.currentTheme).withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: AppThemes.getPrimaryColor(widget.currentTheme),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetroFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Transform.rotate(
              angle: -0.01,
              child: Text(
                '🎨 그림 필터',
                style: FontThemes.getTextStyle(
                  widget.currentFont,
                  fontSize: 14,
                  color: AppThemes.getPrimaryColor(widget.currentTheme),
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.3),
                ),
              ),
            ),
            if (_filteredImageBytes != null)
              GestureDetector(
                onTap: _resetImageFilter,
                child: RetroSticker(
                  emoji: '🔄',
                  text: '원본',
                  backgroundColor: Colors.grey[600]!,
                  rotation: 0.05,
                ),
              ),
          ],
        ),
        
        SizedBox(height: 10),
        
        if (_isProcessingFilter)
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemes.getAccentColor(widget.currentTheme).withOpacity(0.15),
                  AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.2),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                // 애니메이션 아이콘과 진행률
                TweenAnimationBuilder(
                  duration: Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0.8, end: 1.2),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                              color: AppThemes.getPrimaryColor(widget.currentTheme),
                              backgroundColor: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.2),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppThemes.getPrimaryColor(widget.currentTheme),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.3),
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.palette,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onEnd: () {
                    // 애니메이션이 끝나면 다시 시작 (무한 반복)
                    if (_isProcessingFilter) {
                      setState(() {});
                    }
                  },
                ),
                SizedBox(height: 20),
                
                // 현재 적용 중인 필터 표시
                if (_selectedFilter != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppThemes.getPrimaryColor(widget.currentTheme).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${FilterInfo.allFilters.firstWhere((f) => f.type == _selectedFilter).emoji} ${FilterInfo.allFilters.firstWhere((f) => f.type == _selectedFilter).name}',
                      style: FontThemes.getTextStyle(
                        widget.currentFont,
                        fontSize: 12,
                        color: AppThemes.getPrimaryColor(widget.currentTheme),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
                
                Text(
                  '🎨 마법을 부리는 중...',
                  style: FontThemes.getTextStyle(
                    widget.currentFont,
                    fontSize: 16,
                    color: AppThemes.getPrimaryColor(widget.currentTheme),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '90년대 감성으로 변신시키고 있어요! ✨',
                  style: FontThemes.getTextStyle(
                    widget.currentFont,
                    fontSize: 12,
                    color: Colors.grey[600]!,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '조금만 더 기다려주세요~ 🌈',
                  style: FontThemes.getTextStyle(
                    widget.currentFont,
                    fontSize: 10,
                    color: Colors.grey[500]!,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FilterInfo.allFilters.map((filter) {
              final isSelected = _selectedFilter == filter.type;
              return GestureDetector(
                onTap: _isProcessingFilter ? null : () => _applyImageFilter(filter.type),
                child: Opacity(
                  opacity: _isProcessingFilter ? 0.5 : 1.0,
                  child: RetroSticker(
                    emoji: filter.emoji,
                    text: filter.name,
                    backgroundColor: isSelected 
                      ? AppThemes.getPrimaryColor(widget.currentTheme)
                      : AppThemes.getAccentColor(widget.currentTheme).withOpacity(0.7),
                    rotation: (FilterInfo.allFilters.indexOf(filter) % 3 - 1) * 0.1,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPolaroidPhoto() {
    if (_selectedImageBytes == null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Transform.rotate(
          angle: -0.02,
          child: Container(
            width: 200,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                        SizedBox(height: 8),
                        Text(
                          '사진 추가',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      '오늘의 추억 📸',
                      style: FontThemes.getTextStyle(
                        widget.currentFont,
                        fontSize: 10,
                        color: Colors.grey[600]!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Transform.rotate(
      angle: 0.01,
      child: Container(
        width: 200,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: GestureDetector(
                  onTap: () => _showFullScreenImage(context),
                  child: Image.memory(
                    _filteredImageBytes ?? _selectedImageBytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              padding: EdgeInsets.all(8),
              child: Center(
                child: Text(
                  _selectedFilter != null 
                    ? '${FilterInfo.allFilters.firstWhere((f) => f.type == _selectedFilter).name} 필터'
                    : '오늘의 추억 📸',
                  style: FontThemes.getTextStyle(
                    widget.currentFont,
                    fontSize: 10,
                    color: Colors.grey[700]!,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
