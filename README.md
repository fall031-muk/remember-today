# 📖 Remember Today

> **30-40대를 위한 레트로 감성 일기장 앱**  
> 소중한 하루하루를 기록하고, 추억을 아름답게 보관하세요.

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

</div>

## 🌟 주요 특징

### 💝 **레트로 감성 디자인**
- 30-40대 타겟층을 위한 따뜻하고 감성적인 UI/UX
- 6가지 레트로 테마 (빈티지 브라운, 석양 오렌지, 숲속 그린, 바다 블루, 라벤더 퍼플, 로즈 핑크)
- 부드러운 그래디언트와 그림자 효과

### ✍️ **한글 손글씨 폰트 지원**
- 6가지 한글 손글씨 폰트 선택 가능
- 나눔손글씨, 주아체, 감자꽃체, 해바라기체, 스타일리시체, 귀여운체
- 실시간 폰트 미리보기 기능

### 📅 **유연한 일기 작성**
- **당일 일기**: 오늘 날짜로 일기 작성
- **과거/미래 일기**: 캘린더에서 원하는 날짜 선택하여 작성
- 기분과 날씨를 이모티콘으로 간편하게 선택
- 사진 첨부 기능 (향후 그림체 변환 예정)

## 🚀 주요 기능

### 📝 **일기 작성 & 관리**
- **감정 기록**: 8가지 기분 이모티콘 선택
- **날씨 기록**: 8가지 날씨 이모티콘 선택
- **텍스트 입력**: 선택한 손글씨 폰트로 자연스러운 일기 작성
- **사진 첨부**: 갤러리에서 이미지 선택 및 첨부

### 📚 **일기 보기 & 검색**
- **일기 목록**: 작성된 모든 일기를 시간순으로 정렬
- **상세 보기**: 개별 일기의 전체 내용과 메타데이터 확인
- **검색 기능**: 내용, 날짜, 기분, 날씨로 일기 검색
- **캘린더 뷰**: 월별 캘린더에서 일기 작성 현황 한눈에 확인

### 🎨 **개인화 설정**
- **테마 변경**: 6가지 레트로 테마 중 선택
- **폰트 변경**: 6가지 한글 손글씨 폰트 중 선택
- **설정 저장**: 사용자 선택사항 자동 저장

### 📤 **공유 기능**
- **텍스트 공유**: 일기 내용을 다른 앱으로 공유
- **클립보드 복사**: 일기 내용을 클립보드에 복사

## 🛠️ 기술 스택

### **Frontend**
- **Flutter 3.x**: 크로스 플랫폼 모바일 앱 개발
- **Dart**: 메인 프로그래밍 언어
- **Google Fonts**: 다양한 한글 폰트 지원

### **Backend & Storage**
- **SQLite**: 모바일 로컬 데이터베이스
- **SharedPreferences**: 웹 환경 데이터 저장
- **조건부 저장소**: 플랫폼별 최적화된 저장 방식

### **주요 패키지**
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0           # 폰트 지원
  sqflite: ^2.3.0               # SQLite 데이터베이스
  shared_preferences: ^2.2.2     # 설정 저장
  image_picker: ^1.0.4          # 이미지 선택
  table_calendar: ^3.0.9        # 캘린더 위젯
  share_plus: ^7.2.1            # 공유 기능
  intl: ^0.18.1                 # 국제화 및 날짜 포맷
  path_provider: ^2.1.1         # 파일 경로 관리
```

## 📱 지원 플랫폼

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11.0+)
- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Windows** (Windows 10+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🏗️ 설치 및 실행

### **사전 요구사항**
- Flutter SDK 3.0 이상
- Dart SDK 2.17 이상
- Android Studio / VS Code
- iOS 개발시: Xcode 13.0 이상

### **설치 방법**

1. **저장소 클론**
```bash
git clone https://github.com/fall031-muk/remember-today.git
cd remember-today
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **앱 실행**
```bash
# 디버그 모드
flutter run

# 특정 플랫폼
flutter run -d chrome        # 웹
flutter run -d macos         # macOS
flutter run -d windows       # Windows
```

4. **빌드**
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release

# 웹
flutter build web --release
```

## 📊 프로젝트 구조

```
lib/
├── main.dart                 # 메인 앱 진입점
├── models/
│   └── diary_entry.dart      # 일기 데이터 모델
├── services/
│   ├── database_service.dart # 데이터베이스 서비스
│   └── share_service.dart    # 공유 기능 서비스
├── screens/
│   ├── diary_list_screen.dart      # 일기 목록 화면
│   ├── diary_detail_screen.dart    # 일기 상세 화면
│   ├── diary_search_screen.dart    # 일기 검색 화면
│   ├── diary_calendar_screen.dart  # 캘린더 화면
│   ├── theme_settings_screen.dart  # 테마 설정 화면
│   └── font_settings_screen.dart   # 폰트 설정 화면
└── themes/
    ├── app_themes.dart       # 앱 테마 정의
    └── font_themes.dart      # 폰트 테마 정의
```

## 🎯 사용법

### **1. 일기 작성**
1. 메인 화면에서 오늘의 기분과 날씨 선택
2. 사진 추가 (선택사항)
3. 일기 내용 작성
4. "일기 저장하기" 버튼 클릭

### **2. 다른 날짜 일기 작성**
1. "캘린더" 버튼 클릭
2. 원하는 날짜 선택
3. "이 날 일기 쓰기" 버튼 클릭
4. 일기 작성 후 저장

### **3. 일기 관리**
- **목록 보기**: "일기장" 버튼으로 모든 일기 확인
- **검색**: 메뉴 → "일기 검색"으로 특정 일기 찾기
- **공유**: 일기 상세화면에서 공유 버튼 클릭

### **4. 개인화 설정**
- **테마 변경**: 메뉴 → "테마 설정"
- **폰트 변경**: 메뉴 → "글씨체 설정"

## 🔮 향후 계획

### **Phase 1 (완료)**
- ✅ 기본 일기 작성 기능
- ✅ 레트로 테마 시스템
- ✅ 한글 손글씨 폰트
- ✅ 캘린더 기반 날짜 선택
- ✅ 검색 및 공유 기능

### **Phase 2 (개발 예정)**
- 🔄 **AI 그림체 변환**: 사진을 그림체로 자동 변환
- 🔄 **손글씨 변환**: 텍스트를 실제 손글씨 이미지로 변환
- 🔄 **클라우드 동기화**: 여러 기기 간 일기 동기화
- 🔄 **감정 분석**: AI 기반 일기 감정 분석 및 통계

### **Phase 3 (계획 중)**
- 📝 **일기 템플릿**: 다양한 일기 작성 템플릿
- 🏆 **성취 시스템**: 일기 작성 습관 형성 도움
- 🎵 **BGM 기능**: 일기 작성시 감성적인 배경음악
- 📊 **통계 대시보드**: 월별/연별 일기 작성 통계

## 🤝 기여하기

이 프로젝트에 기여하고 싶으시다면:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 👨‍💻 개발자

**fall031-muk**
- GitHub: [@fall031-muk](https://github.com/fall031-muk)
- Email: fall900802@gmail.com

## 🙏 감사의 말

- **Flutter 팀**: 훌륭한 크로스 플랫폼 프레임워크 제공
- **Google Fonts**: 아름다운 한글 폰트 지원
- **모든 오픈소스 기여자들**: 사용된 패키지들의 개발자분들

---

<div align="center">

**Remember Today로 소중한 하루를 기록하세요! 📖✨**

[⭐ Star this project](https://github.com/fall031-muk/remember-today) if you like it!

</div>
