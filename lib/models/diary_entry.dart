import 'dart:typed_data';

업ㄹclass DiaryEntry {
  final int? id;
  final String date;
  final String mood;
  final String weather;
  final String content;
  final String? imagePath;
  final String? imageBytes; // Base64 인코딩된 이미지 바이트
  final DateTime createdAt;

  DiaryEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.weather,
    required this.content,
    this.imagePath,
    this.imageBytes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
      'weather': weather,
      'content': content,
      'imagePath': imagePath,
      'imageBytes': imageBytes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      date: map['date'],
      mood: map['mood'],
      weather: map['weather'],
      content: map['content'],
      imagePath: map['imagePath'],
      imageBytes: map['imageBytes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
} 