import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import 'diary_detail_screen.dart';

class DiarySearchScreen extends StatefulWidget {
  const DiarySearchScreen({super.key});

  @override
  State<DiarySearchScreen> createState() => _DiarySearchScreenState();
}

class _DiarySearchScreenState extends State<DiarySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DiaryEntry> _searchResults = [];
  List<DiaryEntry> _allDiaries = [];
  bool _isLoading = false;
  bool _isSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllDiaries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllDiaries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final diaries = await DatabaseService.getAllDiaries();
      setState(() {
        _allDiaries = diaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearched = false;
      });
      return;
    }

    setState(() {
      _isSearched = true;
      _searchResults = _allDiaries.where((diary) {
        return diary.content.toLowerCase().contains(query.toLowerCase()) ||
               diary.date.contains(query) ||
               _getMoodText(diary.mood).contains(query) ||
               _getWeatherText(diary.weather).contains(query);
      }).toList();
    });
  }

  String _getMoodText(String mood) {
    const moodMap = {
      '😊': '기쁨 행복 좋음',
      '😢': '슬픔 우울 눈물',
      '😴': '피곤 졸림 잠',
      '😍': '사랑 좋아 설렘',
      '😤': '화남 짜증 분노',
      '🤔': '고민 생각 궁금',
      '😎': '멋짐 쿨 자신감',
      '🥳': '파티 축하 신남',
    };
    return moodMap[mood] ?? '';
  }

  String _getWeatherText(String weather) {
    const weatherMap = {
      '☀️': '맑음 해 화창',
      '⛅': '구름 약간흐림',
      '☁️': '흐림 구름많음',
      '🌧️': '비 우천 장마',
      '⛈️': '폭우 천둥 번개',
      '🌈': '무지개 개임',
      '❄️': '눈 설경 추위',
      '🌪️': '바람 태풍 강풍',
    };
    return weatherMap[weather] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '일기 검색',
          style: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            padding: EdgeInsets.all(20),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: GoogleFonts.notoSerif(fontSize: 16),
              decoration: InputDecoration(
                hintText: '일기 내용, 날짜, 기분, 날씨로 검색해보세요...',
                hintStyle: GoogleFonts.notoSerif(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
            ),
          ),
          
          // 검색 결과
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearched) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final diary = _searchResults[index];
        return _buildSearchResultCard(diary);
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            '일기를 검색해보세요',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '총 ${_allDiaries.length}개의 일기가 있어요',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 30),
          _buildSearchTips(),
        ],
      ),
    );
  }

  Widget _buildSearchTips() {
    return Container(
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
            '검색 팁 💡',
            style: GoogleFonts.notoSerif(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 10),
          ...[
            '• 일기 내용의 단어나 문장으로 검색',
            '• 날짜로 검색 (예: 2024-01-15)',
            '• 기분으로 검색 (예: 기쁨, 슬픔, 화남)',
            '• 날씨로 검색 (예: 맑음, 비, 눈)',
          ].map((tip) => Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              tip,
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            '검색 결과가 없어요',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '다른 키워드로 다시 검색해보세요',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(DiaryEntry diary) {
    DateTime date = DateTime.parse(diary.date);
    String formattedDate = DateFormat('MM월 dd일 (E)', 'ko_KR').format(date);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: GoogleFonts.notoSerif(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
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
                 _highlightSearchText(
                   diary.content.length > 100 
                       ? '${diary.content.substring(0, 100)}...'
                       : diary.content,
                 ),
                 style: GoogleFonts.caveat( // 손글씨 스타일 폰트로 변경
                   fontSize: 16,
                   color: Colors.grey[700],
                   height: 1.5,
                 ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (diary.imagePath != null) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.photo,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '사진 포함',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _highlightSearchText(String text) {
    // 간단한 텍스트 반환 (실제 하이라이트 기능은 RichText로 구현 가능)
    return text;
  }
} 