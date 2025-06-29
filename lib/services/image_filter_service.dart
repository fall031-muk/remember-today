import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ImageFilterService {
  
  /// 인스턴트 카메라 효과 - 폴라로이드 느낌의 빈티지 (최적화됨)
  static Future<Uint8List> applyInstantCameraEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 성능 최적화 - 더 작은 크기로 조정
    final resized = img.copyResize(image, width: 200);
    
    // 2. 따뜻한 톤 조정 (노란빛)
    final warmed = img.adjustColor(resized, 
      saturation: 0.9,
      brightness: 1.08,
      contrast: 1.15,
      gamma: 1.1
    );
    
    // 3. 약간의 블러로 부드러운 느낌
    final softened = img.gaussianBlur(warmed, radius: 1);
    
    // 4. 비네팅 효과 (테두리 어둡게)
    final vignette = _applyVignette(softened, intensity: 0.25);
    
    return Uint8List.fromList(img.encodePng(vignette));
  }
  
  /// 필름 카메라 효과 - 필름 그레인과 색감 왜곡 (최적화됨)
  static Future<Uint8List> applyFilmCameraEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 200);
    
    // 2. 필름 특유의 색감 (청록색 그림자, 주황색 하이라이트)
    final filmTone = img.adjustColor(resized,
      saturation: 1.2,
      brightness: 0.95,
      contrast: 1.25
    );
    
    // 3. 필름 그레인 효과 (노이즈 추가)
    final grainy = _addFilmGrain(filmTone);
    
    // 4. 약간의 색상 시프트
    final shifted = _applyColorShift(grainy);
    
    return Uint8List.fromList(img.encodePng(shifted));
  }
  
  /// 무지개 프리즘 효과 - 90년대 홀로그램 스티커 느낌 (최적화됨)
  static Future<Uint8List> applyRainbowPrismEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 200);
    
    // 2. 채도 극대화
    final saturated = img.adjustColor(resized,
      saturation: 1.8,
      brightness: 1.1,
      contrast: 1.3
    );
    
    // 3. 무지개 색상 오버레이
    final rainbow = _applyRainbowOverlay(saturated);
    
    // 4. 홀로그램 효과 (색상 분리)
    final hologram = _applyHologramEffect(rainbow);
    
    return Uint8List.fromList(img.encodePng(hologram));
  }
  
  /// 반짝이 효과 - 글리터와 하이라이트 추가 (최적화됨)
  static Future<Uint8List> applyGlitterEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 200);
    
    // 2. 밝기와 대비 증가
    final brightened = img.adjustColor(resized,
      saturation: 1.3,
      brightness: 1.15,
      contrast: 1.2
    );
    
    // 3. 반짝이 점들 추가
    final glittery = _addGlitterSpots(brightened);
    
    // 4. 전체적인 글로우 효과
    final glowing = img.gaussianBlur(glittery, radius: 1);
    
    return Uint8List.fromList(img.encodePng(glowing));
  }
  
  /// 크레용 효과 - 어린 시절 크레용으로 그린 느낌 (최적화됨)
  static Future<Uint8List> applyCrayonEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 200);
    
    // 2. 색상 단순화 (크레용처럼)
    final simplified = img.quantize(resized, numberOfColors: 16);
    
    // 3. 부드러운 질감
    final softened = img.gaussianBlur(simplified, radius: 2);
    
    // 4. 크레용 질감 효과
    final textured = _applyCrayonTexture(softened);
    
    // 5. 약간의 채도 증가
    final enhanced = img.adjustColor(textured,
      saturation: 1.4,
      brightness: 1.05,
      contrast: 0.9
    );
    
    return Uint8List.fromList(img.encodePng(enhanced));
  }
  
  /// 브라운관 TV 효과 - 스캔라인과 색번짐 효과 (최적화됨)
  static Future<Uint8List> applyCRTEffect(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');
    
    // 1. 크기 조정
    final resized = img.copyResize(image, width: 200);
    
    // 2. 색상 번짐 효과
    final blurred = img.gaussianBlur(resized, radius: 1);
    
    // 3. 대비와 채도 조정 (브라운관 특성)
    final adjusted = img.adjustColor(blurred,
      saturation: 1.1,
      brightness: 0.95,
      contrast: 1.3,
      gamma: 1.2
    );
    
    // 4. 스캔라인 효과 추가
    final scanlined = _addScanlines(adjusted);
    
    // 5. 약간의 비네팅
    final vignette = _applyVignette(scanlined, intensity: 0.15);
    
    return Uint8List.fromList(img.encodePng(vignette));
  }
  
  // 헬퍼 메서드들
  
  /// 비네팅 효과 추가
  static img.Image _applyVignette(img.Image image, {double intensity = 0.2}) {
    final centerX = image.width / 2;
    final centerY = image.height / 2;
    final maxDistance = math.sqrt(centerX * centerX + centerY * centerY);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final distance = math.sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        final factor = 1.0 - (distance / maxDistance) * intensity;
        
        final pixel = image.getPixel(x, y);
        final newR = (pixel.r * factor).round().clamp(0, 255);
        final newG = (pixel.g * factor).round().clamp(0, 255);
        final newB = (pixel.b * factor).round().clamp(0, 255);
        
        final newColor = image.getColor(newR, newG, newB);
        image.setPixel(x, y, newColor);
      }
    }
    
    return image;
  }
  
  /// 필름 그레인 효과 추가
  static img.Image _addFilmGrain(img.Image image) {
    final random = math.Random();
    
    for (int y = 0; y < image.height; y += 3) { // 성능 최적화: 3픽셀마다
      for (int x = 0; x < image.width; x += 3) {
        if (random.nextDouble() < 0.2) { // 20% 확률로 노이즈 추가
          final pixel = image.getPixel(x, y);
          final noise = (random.nextDouble() - 0.5) * 30;
          
          final newR = (pixel.r + noise).round().clamp(0, 255);
          final newG = (pixel.g + noise).round().clamp(0, 255);
          final newB = (pixel.b + noise).round().clamp(0, 255);
          
          final newColor = image.getColor(newR, newG, newB);
          image.setPixel(x, y, newColor);
        }
      }
    }
    
    return image;
  }
  
  /// 색상 시프트 효과
  static img.Image _applyColorShift(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        // 필름 특유의 색상 시프트 (청록색 그림자, 주황색 하이라이트)
        final brightness = (pixel.r + pixel.g + pixel.b) / 3;
        
        int newR, newG, newB;
        if (brightness < 128) { // 어두운 부분은 청록색으로
          newR = (pixel.r * 0.9).round();
          newG = (pixel.g * 1.1).round();
          newB = (pixel.b * 1.2).round();
        } else { // 밝은 부분은 주황색으로
          newR = (pixel.r * 1.1).round();
          newG = (pixel.g * 1.05).round();
          newB = (pixel.b * 0.9).round();
        }
        
        final newColor = image.getColor(
          newR.clamp(0, 255), 
          newG.clamp(0, 255), 
          newB.clamp(0, 255)
        );
        image.setPixel(x, y, newColor);
      }
    }
    
    return image;
  }
  
  /// 무지개 오버레이 효과
  static img.Image _applyRainbowOverlay(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        // 위치에 따른 무지개 색상 계산
        final hue = ((x + y) / (image.width + image.height)) * 360;
        final rainbowColor = _hsvToRgb(hue, 0.3, 1.0);
        
        // 원본과 무지개 색상 블렌딩
        final newR = ((pixel.r + rainbowColor[0]) / 2).round().clamp(0, 255);
        final newG = ((pixel.g + rainbowColor[1]) / 2).round().clamp(0, 255);
        final newB = ((pixel.b + rainbowColor[2]) / 2).round().clamp(0, 255);
        
        final newColor = image.getColor(newR, newG, newB);
        image.setPixel(x, y, newColor);
      }
    }
    
    return image;
  }
  
  /// 홀로그램 효과
  static img.Image _applyHologramEffect(img.Image image) {
    // 색상 채널을 약간씩 분리하여 홀로그램 효과 생성
    final shifted = img.Image(width: image.width, height: image.height);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        // R 채널을 왼쪽으로, B 채널을 오른쪽으로 약간 이동
        final rPixel = x > 1 ? image.getPixel(x - 1, y) : pixel;
        final bPixel = x < image.width - 2 ? image.getPixel(x + 1, y) : pixel;
        
        final newColor = image.getColor(
          rPixel.r.round(), 
          pixel.g.round(), 
          bPixel.b.round()
        );
        shifted.setPixel(x, y, newColor);
      }
    }
    
    return shifted;
  }
  
  /// 글리터 점들 추가
  static img.Image _addGlitterSpots(img.Image image) {
    final random = math.Random();
    
    // 랜덤한 위치에 반짝이는 점들 추가
    for (int i = 0; i < 30; i++) { // 30개의 글리터 점 (성능 최적화)
      final x = random.nextInt(image.width);
      final y = random.nextInt(image.height);
      final size = random.nextInt(3) + 1;
      
      // 밝은 점 그리기
      for (int dy = -size; dy <= size; dy++) {
        for (int dx = -size; dx <= size; dx++) {
          final nx = x + dx;
          final ny = y + dy;
          
          if (nx >= 0 && nx < image.width && ny >= 0 && ny < image.height) {
            final distance = math.sqrt(dx * dx + dy * dy);
            if (distance <= size) {
              final intensity = (1.0 - distance / size) * 255;
              final glitterColor = image.getColor(
                intensity.round(), 
                intensity.round(), 
                intensity.round()
              );
              image.setPixel(nx, ny, glitterColor);
            }
          }
        }
      }
    }
    
    return image;
  }
  
  /// 크레용 질감 효과
  static img.Image _applyCrayonTexture(img.Image image) {
    final random = math.Random();
    
    for (int y = 0; y < image.height; y += 3) {
      for (int x = 0; x < image.width; x += 3) {
        if (random.nextDouble() < 0.3) { // 30% 확률로 질감 추가
          final pixel = image.getPixel(x, y);
          final variation = (random.nextDouble() - 0.5) * 20;
          
          final newR = (pixel.r + variation).round().clamp(0, 255);
          final newG = (pixel.g + variation).round().clamp(0, 255);
          final newB = (pixel.b + variation).round().clamp(0, 255);
          
          final newColor = image.getColor(newR, newG, newB);
          image.setPixel(x, y, newColor);
        }
      }
    }
    
    return image;
  }
  
  /// 스캔라인 효과 추가
  static img.Image _addScanlines(img.Image image) {
    for (int y = 0; y < image.height; y += 3) { // 3픽셀마다 스캔라인
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        // 스캔라인은 약간 어둡게
        final newR = (pixel.r * 0.8).round().clamp(0, 255);
        final newG = (pixel.g * 0.8).round().clamp(0, 255);
        final newB = (pixel.b * 0.8).round().clamp(0, 255);
        
        final newColor = image.getColor(newR, newG, newB);
        image.setPixel(x, y, newColor);
      }
    }
    
    return image;
  }
  
  /// HSV를 RGB로 변환
  static List<int> _hsvToRgb(double h, double s, double v) {
    final c = v * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = v - c;
    
    double r, g, b;
    
    if (h < 60) {
      r = c; g = x; b = 0;
    } else if (h < 120) {
      r = x; g = c; b = 0;
    } else if (h < 180) {
      r = 0; g = c; b = x;
    } else if (h < 240) {
      r = 0; g = x; b = c;
    } else if (h < 300) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }
    
    return [
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
    ];
  }
}

/// 필터 타입 열거형 - 90년대 감성으로 업데이트
enum ImageFilterType {
  instantCamera,
  filmCamera,
  rainbowPrism,
  glitter,
  crayon,
  crtTV,
}

/// 필터 정보 클래스 - 90년대 감성 필터들
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
      type: ImageFilterType.instantCamera,
      name: '인스턴트 카메라',
      description: '폴라로이드 사진처럼 따뜻한 빈티지 느낌',
      emoji: '📸',
    ),
    FilterInfo(
      type: ImageFilterType.filmCamera,
      name: '필름 카메라',
      description: '필름 그레인과 색감이 살아있는 추억의 사진',
      emoji: '🎞️',
    ),
    FilterInfo(
      type: ImageFilterType.rainbowPrism,
      name: '무지개 프리즘',
      description: '90년대 홀로그램 스티커 같은 신비한 효과',
      emoji: '🌈',
    ),
    FilterInfo(
      type: ImageFilterType.glitter,
      name: '반짝이',
      description: '글리터와 반짝임이 가득한 마법 같은 효과',
      emoji: '✨',
    ),
    FilterInfo(
      type: ImageFilterType.crayon,
      name: '크레용',
      description: '어린 시절 크레용으로 그린 듯한 따뜻한 느낌',
      emoji: '🖍️',
    ),
    FilterInfo(
      type: ImageFilterType.crtTV,
      name: '브라운관 TV',
      description: '옛날 TV 화면처럼 스캔라인이 있는 레트로 효과',
      emoji: '📺',
    ),
  ];
  
  /// 필터 타입에 따른 처리 함수 호출
  static Future<Uint8List> applyFilter(ImageFilterType type, Uint8List imageBytes) {
    switch (type) {
      case ImageFilterType.instantCamera:
        return ImageFilterService.applyInstantCameraEffect(imageBytes);
      case ImageFilterType.filmCamera:
        return ImageFilterService.applyFilmCameraEffect(imageBytes);
      case ImageFilterType.rainbowPrism:
        return ImageFilterService.applyRainbowPrismEffect(imageBytes);
      case ImageFilterType.glitter:
        return ImageFilterService.applyGlitterEffect(imageBytes);
      case ImageFilterType.crayon:
        return ImageFilterService.applyCrayonEffect(imageBytes);
      case ImageFilterType.crtTV:
        return ImageFilterService.applyCRTEffect(imageBytes);
    }
  }
} 