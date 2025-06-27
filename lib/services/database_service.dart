import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/diary_entry.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'diary_entries';
  static const String webStorageKey = 'diary_entries_web';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'diary.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            mood TEXT NOT NULL,
            weather TEXT NOT NULL,
            content TEXT NOT NULL,
            imagePath TEXT,
            imageBytes TEXT,
            createdAt INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          return db.execute('ALTER TABLE $tableName ADD COLUMN imageBytes TEXT');
        }
      },
    );
  }

  static Future<int> insertDiary(DiaryEntry entry) async {
    if (kIsWeb) {
      return await _insertDiaryWeb(entry);
    }
    
    final db = await database;
    return await db.insert(tableName, entry.toMap());
  }

  static Future<List<DiaryEntry>> getAllDiaries() async {
    if (kIsWeb) {
      return await _getAllDiariesWeb();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  static Future<DiaryEntry?> getDiaryByDate(String date) async {
    if (kIsWeb) {
      return await _getDiaryByDateWeb(date);
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return DiaryEntry.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> updateDiary(DiaryEntry entry) async {
    if (kIsWeb) {
      return await _updateDiaryWeb(entry);
    }
    
    final db = await database;
    return await db.update(
      tableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<int> deleteDiary(int id) async {
    if (kIsWeb) {
      return await _deleteDiaryWeb(id);
    }
    
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 웹용 저장소 메서드들
  static Future<int> _insertDiaryWeb(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<DiaryEntry> diaries = await _getAllDiariesWeb();
    
    // 새로운 ID 생성
    int newId = diaries.isEmpty ? 1 : diaries.map((d) => d.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    
    DiaryEntry newEntry = DiaryEntry(
      id: newId,
      date: entry.date,
      mood: entry.mood,
      weather: entry.weather,
      content: entry.content,
      imagePath: entry.imagePath,
      imageBytes: entry.imageBytes,
      createdAt: entry.createdAt,
    );
    
    diaries.add(newEntry);
    
    List<String> diariesJson = diaries.map((d) => jsonEncode(d.toMap())).toList();
    await prefs.setStringList(webStorageKey, diariesJson);
    
    return newId;
  }

  static Future<List<DiaryEntry>> _getAllDiariesWeb() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? diariesJson = prefs.getStringList(webStorageKey);
    
    if (diariesJson == null) return [];
    
    List<DiaryEntry> diaries = diariesJson
        .map((json) => DiaryEntry.fromMap(jsonDecode(json)))
        .toList();
    
    // 날짜 순으로 정렬
    diaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return diaries;
  }

  static Future<DiaryEntry?> _getDiaryByDateWeb(String date) async {
    List<DiaryEntry> diaries = await _getAllDiariesWeb();
    
    try {
      return diaries.firstWhere((diary) => diary.date == date);
    } catch (e) {
      return null;
    }
  }

  static Future<int> _updateDiaryWeb(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<DiaryEntry> diaries = await _getAllDiariesWeb();
    
    int index = diaries.indexWhere((d) => d.id == entry.id);
    if (index != -1) {
      diaries[index] = entry;
      
      List<String> diariesJson = diaries.map((d) => jsonEncode(d.toMap())).toList();
      await prefs.setStringList(webStorageKey, diariesJson);
      
      return 1;
    }
    
    return 0;
  }

  static Future<int> _deleteDiaryWeb(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<DiaryEntry> diaries = await _getAllDiariesWeb();
    
    int initialLength = diaries.length;
    diaries.removeWhere((d) => d.id == id);
    
    if (diaries.length < initialLength) {
      List<String> diariesJson = diaries.map((d) => jsonEncode(d.toMap())).toList();
      await prefs.setStringList(webStorageKey, diariesJson);
      
      return 1;
    }
    
    return 0;
  }
} 