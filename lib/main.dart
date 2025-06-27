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
import 'dart:convert';

void main() {
  runApp(const RememberTodayApp());
}

class RememberTodayApp extends StatefulWidget {
  const RememberTodayApp({super.key});

  @override
  State<RememberTodayApp> createState() => _RememberTodayAppState();
}

class _RememberTodayAppState extends State<RememberTodayApp> {
  AppThemeType _currentTheme = AppThemeType.vintage;
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
          orElse: () => AppThemeType.vintage,
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
      Uint8List? filteredBytes;

      switch (filterType) {
        case ImageFilterType.watercolor:
          filteredBytes = await ImageFilterService.applyWatercolorEffect(_selectedImageBytes!);
          break;
        case ImageFilterType.cartoon:
          filteredBytes = await ImageFilterService.applyCartoonEffect(_selectedImageBytes!);
          break;
        case ImageFilterType.sketch:
          filteredBytes = await ImageFilterService.applySketchEffect(_selectedImageBytes!);
          break;
        case ImageFilterType.vintage:
          filteredBytes = await ImageFilterService.applyVintageEffect(_selectedImageBytes!);
          break;
        case ImageFilterType.oilPainting:
          filteredBytes = await ImageFilterService.applyOilPaintingEffect(_selectedImageBytes!);
          break;
        case ImageFilterType.popArt:
          filteredBytes = await ImageFilterService.applyPopArtEffect(_selectedImageBytes!);
          break;
      }

      if (filteredBytes != null) {
        setState(() {
          _filteredImageBytes = filteredBytes;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${FilterInfo.allFilters.firstWhere((f) => f.type == filterType).name} 필터가 적용되었습니다! ✨'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                _buildHeader(),
                SizedBox(height: 30),
                
                // 날씨와 기분 선택
                _buildMoodWeatherSelector(),
                SizedBox(height: 30),
                
                // 사진 업로드 섹션
                _buildPhotoSection(),
                SizedBox(height: 30),
                
                // 일기 작성 섹션 (손글씨 스타일)
                _buildDiarySection(),
                SizedBox(height: 30),
                
                // 저장 및 목록 버튼
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String selectedDateStr = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(_selectedDate);
    bool isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            AppThemes.getAccentColor(widget.currentTheme),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remember Today',
                style: GoogleFonts.permanentMarker(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isToday)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                      _currentDiaryId = null;
                      _selectedMood = '😊';
                      _selectedWeather = '☀️';
                      _textController.clear();
                      _selectedImage = null;
                      _selectedImageBytes = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '오늘로',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            selectedDateStr,
            style: GoogleFonts.notoSerif(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          if (!isToday) ...[
            SizedBox(height: 4),
            Text(
              _currentDiaryId != null ? '수정 중' : '새 일기 작성',
              style: GoogleFonts.notoSerif(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodWeatherSelector() {
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
            '오늘의 기분',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedMood == _moods[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = _moods[index];
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _moods[index],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            '오늘의 날씨',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weathers.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedWeather == _weathers[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeather = _weathers[index];
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _weathers[index],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
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
          
          // 이미지 표시 영역
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: 400,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: (_selectedImage != null && _selectedImageBytes != null)
                ? Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showFullScreenImage(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _filteredImageBytes ?? _selectedImageBytes!,
                            width: double.infinity,
                            fit: BoxFit.contain, // 전체 이미지 표시
                            errorBuilder: (context, error, stackTrace) {
                              print('이미지 표시 오류: $error');
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, color: Colors.red, size: 40),
                                    SizedBox(height: 10),
                                    Text(
                                      '이미지 표시 오류',
                                      style: GoogleFonts.notoSerif(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // 이미지 변경 버튼
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // 전체화면 보기 힌트
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '탭하여 크게 보기',
                            style: GoogleFonts.notoSerif(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 10),
                          Text(
                            '사진을 추가해보세요',
                            style: GoogleFonts.notoSerif(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '(그림 필터로 변환 가능)',
                            style: GoogleFonts.notoSerif(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          
          // 이미지가 선택된 경우에만 필터 옵션 표시
          if (_selectedImage != null) ...[
            SizedBox(height: 20),
            
            // 필터 섹션 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '그림 필터',
                  style: GoogleFonts.notoSerif(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (_filteredImageBytes != null)
                  TextButton(
                    onPressed: _resetImageFilter,
                    child: Text(
                      '원본으로',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 10),
            
            // 필터 버튼들
            if (_isProcessingFilter)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '필터 적용 중...',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        color: Colors.grey[600],
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
                    onTap: () => _applyImageFilter(filter.type),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter.emoji,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 4),
                          Text(
                            filter.name,
                            style: GoogleFonts.notoSerif(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            SizedBox(height: 10),
            
            // 필터 설명
            if (_selectedFilter != null)
              Text(
                FilterInfo.allFilters.firstWhere((f) => f.type == _selectedFilter).description,
                style: GoogleFonts.notoSerif(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiarySection() {
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
            '오늘의 이야기',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 15),
          TextField(
            maxLines: 8,
            controller: _textController,
            style: FontThemes.getTextStyle(
              widget.currentFont,
              fontSize: 18,
              color: Theme.of(context).primaryColor,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '오늘 하루는 어떠셨나요?\n소중한 추억을 기록해보세요...',
              hintStyle: GoogleFonts.notoSerif(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.all(15),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '* 손글씨 스타일로 표시됩니다',
            style: GoogleFonts.notoSerif(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 저장 버튼
        Container(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveDiary,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    _currentDiaryId != null 
                        ? '${DateFormat('MM월 dd일').format(_selectedDate)} 일기 수정하기'
                        : '${DateFormat('MM월 dd일').format(_selectedDate)} 일기 저장하기',
                    style: GoogleFonts.notoSerif(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 15),
        
        // 기능 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryListScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.book),
                label: Text('일기장'),
                style: OutlinedButton.styleFrom(
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
                onPressed: () async {
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
                icon: Icon(Icons.calendar_month),
                label: Text('캘린더'),
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
    );
  }
}
