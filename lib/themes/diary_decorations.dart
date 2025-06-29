import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_themes.dart';

/// 90년대 진짜 공책 스타일의 배경 페인터
class NotebookPainter extends CustomPainter {
  final Color lineColor;
  final Color marginColor;
  final Color paperColor;
  final Color holeColor;
  
  NotebookPainter({
    this.lineColor = const Color(0xFFE0E0E0),
    this.marginColor = const Color(0xFFFF9999),
    this.paperColor = const Color(0xFFFFFDF5), // 약간 크림색 종이
    this.holeColor = const Color(0xFFE0E0E0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 종이 배경 (크림색)
    final paperPaint = Paint()
      ..color = paperColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paperPaint);
    
    // 2. 종이 질감 효과 (미세한 점들)
    _drawPaperTexture(canvas, size);
    
    // 3. 왼쪽 마진선 (빨간색)
    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(60, 0),
      Offset(60, size.height),
      marginPaint,
    );
    
    // 4. 가로줄들 (연한 파란색)
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    
    double lineSpacing = 24.0; // 줄 간격
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
    
    // 5. 바인더 구멍들
    _drawBinderHoles(canvas, size);
    
    // 6. 종이 가장자리 그림자
    _drawPaperShadow(canvas, size);
  }
  
  void _drawPaperTexture(Canvas canvas, Size size) {
    final texturePaint = Paint()
      ..color = Color(0xFFF5F5DC).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // 고정된 시드로 일관된 텍스처
    
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 0.5 + 0.2;
      
      canvas.drawCircle(Offset(x, y), radius, texturePaint);
    }
  }
  
  void _drawBinderHoles(Canvas canvas, Size size) {
    final holePaint = Paint()
      ..color = holeColor
      ..style = PaintingStyle.fill;
    
    final holeOutlinePaint = Paint()
      ..color = Color(0xFFBBBBBB)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    // 3개의 구멍
    final holePositions = [
      size.height * 0.2,
      size.height * 0.5,
      size.height * 0.8,
    ];
    
    for (double y in holePositions) {
      // 구멍 배경
      canvas.drawCircle(Offset(20, y), 6, holePaint);
      // 구멍 테두리
      canvas.drawCircle(Offset(20, y), 6, holeOutlinePaint);
      // 구멍 안쪽 그림자
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(20, y), 4, shadowPaint);
    }
  }
  
  void _drawPaperShadow(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    // 오른쪽 가장자리 그림자
    canvas.drawRect(
      Rect.fromLTWH(size.width - 3, 0, 3, size.height),
      shadowPaint,
    );
    
    // 아래쪽 가장자리 그림자
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 3, size.width, 3),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 90년대 스타일 스티커 위젯
class RetroSticker extends StatelessWidget {
  final String emoji;
  final String text;
  final Color backgroundColor;
  final double rotation;
  final double size;

  const RetroSticker({
    Key? key,
    required this.emoji,
    required this.text,
    required this.backgroundColor,
    this.rotation = 0.0,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: size * 0.3),
            ),
            if (text.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  fontSize: size * 0.15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 90년대 스타일 입체 버튼
class RetroButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const RetroButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    this.width = 80,
    this.height = 35,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 종이 질감 효과 위젯
class PaperTexture extends StatelessWidget {
  final Widget child;
  final double opacity;

  const PaperTexture({
    Key? key,
    required this.child,
    this.opacity = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: CustomPaint(
            painter: PaperTexturePainter(opacity: opacity),
          ),
        ),
      ],
    );
  }
}

class PaperTexturePainter extends CustomPainter {
  final double opacity;

  PaperTexturePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFF5F5DC).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 0.8 + 0.2;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 90년대 크레용 스타일 그림 위젯
class CrayonDrawing extends StatelessWidget {
  final String type; // 'family', 'house', 'sun', 'flower' 등
  final double size;

  const CrayonDrawing({
    Key? key,
    required this.type,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CrayonPainter(type: type),
    );
  }
}

class CrayonPainter extends CustomPainter {
  final String type;

  CrayonPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'family':
        _drawFamily(canvas, size);
        break;
      case 'house':
        _drawHouse(canvas, size);
        break;
      case 'sun':
        _drawSun(canvas, size);
        break;
      case 'flower':
        _drawFlower(canvas, size);
        break;
    }
  }

  void _drawFamily(Canvas canvas, Size size) {
    // 간단한 가족 그림 (막대기 인형 스타일)
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 엄마 (초록색 치마)
    paint.color = Color(0xFF4CAF50);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.3), 
                   Offset(size.width * 0.3, size.height * 0.7), paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.25), 8, paint);
    
    // 아빠 (파란색 바지)
    paint.color = Color(0xFF2196F3);
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.3), 
                   Offset(size.width * 0.7, size.height * 0.7), paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.25), 8, paint);
  }

  void _drawHouse(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..color = Color(0xFFFF5722);

    // 집 모양
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSun(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..color = Color(0xFFFFEB3B);

    // 태양
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 
                     size.width * 0.2, paint);
    
    // 태양 광선
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final startX = size.width * 0.5 + math.cos(angle) * size.width * 0.25;
      final startY = size.height * 0.5 + math.sin(angle) * size.width * 0.25;
      final endX = size.width * 0.5 + math.cos(angle) * size.width * 0.35;
      final endY = size.height * 0.5 + math.sin(angle) * size.width * 0.35;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  void _drawFlower(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // 꽃잎 (분홍색)
    paint.color = Color(0xFFE91E63);
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * (math.pi / 180);
      final x = size.width * 0.5 + math.cos(angle) * size.width * 0.2;
      final y = size.height * 0.4 + math.sin(angle) * size.width * 0.2;
      canvas.drawCircle(Offset(x, y), 8, paint);
    }

    // 꽃 중심 (노란색)
    paint.color = Color(0xFFFFEB3B);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 6, paint);

    // 줄기 (초록색)
    paint.color = Color(0xFF4CAF50);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.5), 
                   Offset(size.width * 0.5, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 홀로그램 패턴 효과를 위한 페인터
class HologramPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 홀로그램 라인 패턴
    for (int i = 0; i < size.height; i += 4) {
      paint.color = Colors.white.withOpacity(0.1);
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // 대각선 패턴
    for (int i = 0; i < size.width + size.height; i += 8) {
      paint.color = Colors.white.withOpacity(0.05);
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }

    // 반짝이는 점들
    final random = math.Random(42);
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      paint.color = Colors.white.withOpacity(random.nextDouble() * 0.4);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2 + 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 