import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ImageFilterService {
  
  /// 수채화 효과 - 부드럽고 몽환적인 느낌 (최적화됨)
  static Future<Uint8List> applyWatercolorEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정 (성능 최적화 - 더 작게)
    final resized = img.copyResize(image, width: 400);
    
    // 2. 가우시안 블러로 부드러운 효과 (반경 축소)
    final blurred = img.gaussianBlur(resized, radius: 2);
    
    // 3. 색상 조정 - 채도 증가, 밝기 조금 증가
    final adjusted = img.adjustColor(blurred, 
      saturation: 1.2, 
      brightness: 1.05,
      contrast: 0.9
    );
    
    return Uint8List.fromList(img.encodePng(adjusted));
  }
  
  /// 만화/애니메이션 효과 - 색상 단순화 (최적화됨)
  static Future<Uint8List> applyCartoonEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 400);
    
    // 2. 색상 단순화 (색상 수 줄임)
    final posterized = img.quantize(resized, numberOfColors: 8);
    
    // 3. 대비 증가
    final contrasted = img.adjustColor(posterized, 
      contrast: 1.2,
      saturation: 1.1
    );
    
    return Uint8List.fromList(img.encodePng(contrasted));
  }
  
  /// 스케치 효과 - 연필 스케치 느낌 (최적화됨)
  static Future<Uint8List> applySketchEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 400);
    
    // 2. 그레이스케일 변환
    final gray = img.grayscale(resized);
    
    // 3. 엣지 검출 (소벨 필터)
    final edges = img.sobel(gray);
    
    // 4. 반전하여 연필 스케치 효과
    final inverted = img.invert(edges);
    
    // 5. 대비 조정
    final adjusted = img.adjustColor(inverted, 
      contrast: 1.3,
      brightness: 1.1
    );
    
    return Uint8List.fromList(img.encodePng(adjusted));
  }
  
  /// 빈티지 효과 - 레트로 감성 (최적화됨)
  static Future<Uint8List> applyVintageEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 400);
    
    // 2. 세피아 톤 효과
    final sepia = img.sepia(resized);
    
    // 3. 색상 조정 - 따뜻한 톤
    final adjusted = img.adjustColor(sepia, 
      saturation: 0.85,
      brightness: 0.98,
      contrast: 1.05
    );
    
    return Uint8List.fromList(img.encodePng(adjusted));
  }
  
  /// 오일페인팅 효과 - 유화 느낌 (최적화됨)
  static Future<Uint8List> applyOilPaintingEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 400);
    
    // 2. 색상 단순화 (색상 수 줄임)
    final quantized = img.quantize(resized, numberOfColors: 12);
    
    // 3. 블러 효과로 붓터치 느낌 (반경 축소)
    final blurred = img.gaussianBlur(quantized, radius: 1);
    
    // 4. 색상 강화
    final enhanced = img.adjustColor(blurred, 
      saturation: 1.3,
      contrast: 1.1,
      brightness: 1.02
    );
    
    return Uint8List.fromList(img.encodePng(enhanced));
  }
  
  /// 팝아트 효과 - 강렬한 색상과 대비 (최적화됨)
  static Future<Uint8List> applyPopArtEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 400);
    
    // 2. 극단적인 색상 단순화 (색상 수 더 줄임)
    final posterized = img.quantize(resized, numberOfColors: 4);
    
    // 3. 극대화된 대비와 채도
    final enhanced = img.adjustColor(posterized, 
      saturation: 1.8,
      contrast: 1.6,
      brightness: 1.05
    );
    
    return Uint8List.fromList(img.encodePng(enhanced));
  }
  
  // 헬퍼 메서드들
  
  /// 비네팅 효과 추가 (새로운 API 버전용)
  static img.Image _applyVignette(img.Image image, {double intensity = 0.2}) {
    final centerX = image.width / 2;
    final centerY = image.height / 2;
    final maxDistance = math.max(centerX, centerY);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final distance = math.sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        final factor = 1.0 - (distance / maxDistance) * intensity;
        
        final pixel = image.getPixel(x, y);
        
        // image 패키지 4.x의 새로운 방식으로 색상 설정
        final newR = (pixel.r * factor).round().clamp(0, 255);
        final newG = (pixel.g * factor).round().clamp(0, 255);
        final newB = (pixel.b * factor).round().clamp(0, 255);
        
        // 새로운 색상 객체 생성
        final newColor = image.getColor(newR, newG, newB);
        image.setPixel(x, y, newColor);
      }
    }
    
    return image;
  }
}

/// 필터 타입 열거형
enum ImageFilterType {
  watercolor,
  cartoon,
  sketch,
  vintage,
  oilPainting,
  popArt,
}

/// 필터 정보 클래스
class FilterInfo {
  final ImageFilterType type;
  final String name;
  final String description;
  final String emoji;
  
  const FilterInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.emoji,
  });
  
  static const List<FilterInfo> allFilters = [
    FilterInfo(
      type: ImageFilterType.watercolor,
      name: '수채화',
      description: '부드럽고 몽환적인 수채화 느낌',
      emoji: '🎨',
    ),
    FilterInfo(
      type: ImageFilterType.cartoon,
      name: '만화',
      description: '애니메이션 스타일의 만화 효과',
      emoji: '🎭',
    ),
    FilterInfo(
      type: ImageFilterType.sketch,
      name: '스케치',
      description: '연필로 그린 듯한 스케치 효과',
      emoji: '✏️',
    ),
    FilterInfo(
      type: ImageFilterType.vintage,
      name: '빈티지',
      description: '레트로 감성의 빈티지 효과',
      emoji: '📷',
    ),
    FilterInfo(
      type: ImageFilterType.oilPainting,
      name: '유화',
      description: '붓터치가 느껴지는 유화 효과',
      emoji: '🖌️',
    ),
    FilterInfo(
      type: ImageFilterType.popArt,
      name: '팝아트',
      description: '강렬한 색상의 팝아트 효과',
      emoji: '🌈',
    ),
  ];
} 