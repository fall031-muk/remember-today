import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_themes.dart';

// 줄노트 배경을 그리는 CustomPainter
class NotebookPainter extends CustomPainter {
  final AppThemeType themeType;
  final Color lineColor;
  final Color marginColor;
  final double lineSpacing;

  NotebookPainter({
    required this.themeType,
    required this.lineColor,
    required this.marginColor,
    this.lineSpacing = 30.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 종이 질감 배경
    final backgroundPaint = Paint()
      ..color = AppThemes.getBackgroundColor(themeType)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // 왼쪽 마진선 (바인더 구멍 부분)
    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(60, 0),
      Offset(60, size.height),
      marginPaint,
    );

    // 바인더 구멍들
    final holePaint = Paint()
      ..color = marginColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (double y = 40; y < size.height - 40; y += 80) {
      canvas.drawCircle(Offset(30, y), 8, holePaint);
    }

    // 가로줄들
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(70, y),
        Offset(size.width - 20, y),
        linePaint,
      );
    }

    // 테마별 장식 추가
    _drawThemeDecorations(canvas, size);
  }

  void _drawThemeDecorations(Canvas canvas, Size size) {
    switch (themeType) {
      case AppThemeType.schoolDiary:
        _drawSchoolDecorations(canvas, size);
        break;
      case AppThemeType.candyShop:
        _drawCandyDecorations(canvas, size);
        break;
      case AppThemeType.summerVacation:
        _drawSummerDecorations(canvas, size);
        break;
      case AppThemeType.autumnLeaf:
        _drawAutumnDecorations(canvas, size);
        break;
      case AppThemeType.winterStory:
        _drawWinterDecorations(canvas, size);
        break;
    }
  }

  void _drawSchoolDecorations(Canvas canvas, Size size) {
    // 연필 장식
    final pencilPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    // 오른쪽 상단에 작은 연필 그리기
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 50, 20, 30, 8),
        Radius.circular(4),
      ),
      pencilPaint,
    );
  }

  void _drawCandyDecorations(Canvas canvas, Size size) {
    // 하트 장식들
    final heartPaint = Paint()
      ..color = Colors.pink.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    _drawHeart(canvas, Offset(size.width - 40, 30), 15, heartPaint);
    _drawHeart(canvas, Offset(size.width - 60, size.height - 50), 12, heartPaint);
  }

  void _drawSummerDecorations(Canvas canvas, Size size) {
    // 구름 장식
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    _drawCloud(canvas, Offset(size.width - 80, 40), cloudPaint);
  }

  void _drawAutumnDecorations(Canvas canvas, Size size) {
    // 단풍잎 장식
    final leafPaint = Paint()
      ..color = Colors.orange.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    _drawLeaf(canvas, Offset(size.width - 50, 50), leafPaint);
    _drawLeaf(canvas, Offset(size.width - 30, size.height - 80), leafPaint);
  }

  void _drawWinterDecorations(Canvas canvas, Size size) {
    // 눈송이 장식
    final snowPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    _drawSnowflake(canvas, Offset(size.width - 40, 40), 15, snowPaint);
    _drawSnowflake(canvas, Offset(size.width - 60, size.height - 60), 12, snowPaint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(center.dx - size * 0.5, center.dy - size * 0.3,
                 center.dx - size, center.dy + size * 0.1,
                 center.dx, center.dy + size * 0.7);
    path.cubicTo(center.dx + size, center.dy + size * 0.1,
                 center.dx + size * 0.5, center.dy - size * 0.3,
                 center.dx, center.dy + size * 0.3);
    canvas.drawPath(path, paint);
  }

  void _drawCloud(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(Offset(center.dx - 15, center.dy), 12, paint);
    canvas.drawCircle(Offset(center.dx, center.dy), 15, paint);
    canvas.drawCircle(Offset(center.dx + 15, center.dy), 12, paint);
    canvas.drawCircle(Offset(center.dx + 8, center.dy - 8), 10, paint);
  }

  void _drawLeaf(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - 15);
    path.quadraticBezierTo(center.dx + 10, center.dy - 5, center.dx, center.dy + 15);
    path.quadraticBezierTo(center.dx - 10, center.dy - 5, center.dx, center.dy - 15);
    canvas.drawPath(path, paint);
  }

  void _drawSnowflake(Canvas canvas, Offset center, double size, Paint paint) {
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x1 = center.dx + math.cos(angle) * size;
      final y1 = center.dy + math.sin(angle) * size;
      canvas.drawLine(center, Offset(x1, y1), paint);
      
      // 작은 가지들
      final x2 = center.dx + math.cos(angle) * size * 0.7;
      final y2 = center.dy + math.sin(angle) * size * 0.7;
      final branchAngle1 = angle + math.pi / 6;
      final branchAngle2 = angle - math.pi / 6;
      
      canvas.drawLine(
        Offset(x2, y2),
        Offset(x2 + math.cos(branchAngle1) * size * 0.3, y2 + math.sin(branchAngle1) * size * 0.3),
        paint,
      );
      canvas.drawLine(
        Offset(x2, y2),
        Offset(x2 + math.cos(branchAngle2) * size * 0.3, y2 + math.sin(branchAngle2) * size * 0.3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 90년대 스타일 스티커 위젯들
class RetroSticker extends StatelessWidget {
  final String emoji;
  final String text;
  final Color backgroundColor;
  final double rotation;

  const RetroSticker({
    super.key,
    required this.emoji,
    required this.text,
    required this.backgroundColor,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 16)),
            if (text.isNotEmpty) ...[
              SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 90년대 스타일 버튼
class RetroButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;

  const RetroButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 종이 질감 효과를 위한 위젯
class PaperTexture extends StatelessWidget {
  final Widget child;
  final AppThemeType themeType;

  const PaperTexture({
    super.key,
    required this.child,
    required this.themeType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.getBackgroundColor(themeType),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: NotebookPainter(
          themeType: themeType,
          lineColor: AppThemes.getPrimaryColor(themeType).withOpacity(0.2),
          marginColor: AppThemes.getPrimaryColor(themeType).withOpacity(0.3),
        ),
        child: child,
      ),
    );
  }
} 