# 한 달의 집중 (Monthly Focus)

매월 4가지 목표를 설정하고 일일 체크를 통해 습관을 형성하는 Flutter 앱입니다.

## 📱 앱 개요

### 주요 기능
- **월간 목표 관리**: 매월 4가지 목표를 설정하고 관리
- **일일 체크**: 매일 목표 달성 여부를 체크하여 습관 형성
- **달력 뷰**: 월간 달성 현황을 달력으로 한눈에 확인
- **알림 기능**: 매일 밤 11시에 목표 체크 알림
- **다음 달 준비**: 이번 달 25일부터 다음 달 목표 미리 설정

### 앱 구조
```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── goal.dart            # 목표 모델
│   ├── daily_check.dart     # 일일 체크 모델
│   ├── app_settings.dart    # 앱 설정 모델
│   └── monthly_quote.dart   # 월간 명언 모델
├── providers/               # 상태 관리
│   ├── goal_provider.dart   # 목표 상태 관리
│   └── goals_provider.dart  # 목표 목록 관리
├── screens/                 # 화면
│   ├── splash_screen.dart   # 스플래시 화면
│   ├── main_screen.dart     # 메인 네비게이션
│   ├── home/               # 홈 화면
│   ├── calendar/           # 달력 화면
│   ├── settings/           # 설정 화면
│   └── goal_setting/       # 목표 설정 화면
├── services/               # 서비스
│   ├── database_service.dart    # SQLite 데이터베이스
│   ├── storage_service.dart     # SharedPreferences
│   └── notification_service.dart # 알림 서비스
├── widgets/                # 재사용 위젯
│   └── goal/              # 목표 관련 위젯
└── utils/                 # 유틸리티
    └── app_date_utils.dart # 날짜 처리 유틸
```

## 📋 정리된 주요 내용

### 1. **앱 개요**
- 매월 4가지 목표 설정 및 일일 체크 기능
- 습관 형성에 특화된 앱

### 2. **주요 화면 (5개)**
- **스플래시 화면**: 앱 초기화 및 웰컴 가이드
- **홈 화면**: 현재 월 목표 체크 + 다음 달 목표 설정
- **달력 화면**: 월간 달성 현황 시각화
- **설정 화면**: 알림, 테마, 데이터 관리
- **목표 설정 화면**: 목표 추가/수정/삭제

### 3. **핵심 기능**
- 월간 목표 관리 (최대 4개)
- 일일 체크 토글
- 달력 기반 진행 현황
- 푸시 알림 (매일 밤 11시)
- 다음 달 목표 미리 설정 (25일부터)

### 4. **기술 스택**
- Flutter + Provider (상태 관리)
- SQLite + SharedPreferences (데이터 저장)
- Table Calendar (달력 UI)
- Flutter Local Notifications (알림)

### 5. **데이터 모델**
- Goal: 목표 정보 (제목, 이모지, 순서)
- DailyCheck: 일일 체크 기록

이 README 파일을 통해 앱의 전체적인 구조와 기능을 한눈에 파악할 수 있으며, 개발자나 사용자 모두에게 유용한 정보를 제공합니다.

## 📱 주요 화면 및 기능

### 1. 스플래시 화면 (SplashScreen)
- 앱 로딩 및 초기화
- 웰컴 가이드 표시 (최초 실행 시)
- 데이터베이스 초기화

### 2. 홈 화면 (HomeScreen) - "오늘" 탭
**주요 기능:**
- 현재 월의 4가지 목표 표시
- 각 목표별 일일 체크 토글
- 월간 명언 표시
- 다음 달 목표 설정 섹션 (25일부터 표시)

**UI 구성:**
- 목표 카드 리스트 (이모지 + 제목 + 체크 버튼)
- 체크 완료 시 취소선 표시
- 다음 달 목표 설정 버튼 (그라데이션 배경)

### 3. 달력 화면 (CalendarScreen) - "달력" 탭
**주요 기능:**
- 월간 달력 표시 (table_calendar 패키지 사용)
- 일별 목표 체크 현황 마커 표시
- 선택된 날짜의 상세 체크 목록
- 월 이동 네비게이션
- "Today" 버튼으로 오늘 날짜로 이동

**UI 구성:**
- 달력 위젯 (주말 색상 구분)
- 선택된 날짜의 목표 체크 리스트
- 월간 통계 정보

### 4. 설정 화면 (SettingsScreen) - "설정" 탭
**주요 기능:**
- 알림 설정 (활성화/비활성화, 시간 설정)
- 테마 설정 (라이트/다크 모드)
- 앱 정보 표시
- 데이터 초기화
- 개발자 설정 (테스트 모드)

**UI 구성:**
- 설정 항목 리스트
- 스위치 및 버튼 컨트롤
- 개발자 설정 (AppBar 길게 누르기)

### 5. 목표 설정 화면 (GoalSettingScreen)
**주요 기능:**
- 새 목표 추가 (최대 4개)
- 기존 목표 수정
- 이모지 선택기
- 목표 순서 관리
- 목표 삭제

**UI 구성:**
- 목표 입력 필드 (이모지 + 텍스트)
- 이모지 선택 다이얼로그
- 저장/취소 버튼

## 🗄️ 데이터 모델

### Goal (목표)
```dart
class Goal {
  final int? id;           // 고유 식별자
  final DateTime month;     // 목표가 속한 월
  final int position;       // 표시 순서
  final String title;       // 목표 제목
  final String? emoji;      // 목표 이모지
  final DateTime createdAt; // 생성일시
}
```

### DailyCheck (일일 체크)
```dart
class DailyCheck {
  final int? id;           // 고유 식별자
  final int goalId;        // 연관된 목표 ID
  final DateTime date;      // 체크한 날짜
  final bool isCompleted;   // 완료 여부
  final DateTime checkedAt; // 체크한 시간
}
```

## 📚 기술 스택

### 프레임워크 & 라이브러리
- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **Provider**: 상태 관리
- **SQLite (sqflite)**: 로컬 데이터베이스
- **SharedPreferences**: 앱 설정 저장
- **Flutter Local Notifications**: 푸시 알림
- **Table Calendar**: 달력 위젯
- **Intl**: 날짜/시간 처리

### 주요 패키지
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.1
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^16.3.0
  table_calendar: ^3.0.9
  intl: ^0.19.0
```

## 📚 데이터 저장 구조

### SQLite 데이터베이스
- **goals 테이블**: 목표 정보 저장
- **daily_checks 테이블**: 일일 체크 기록 저장

### SharedPreferences
- 앱 설정 (알림, 테마 등)
- 웰컴 가이드 표시 여부
- 테스트 모드 설정

## 🎨 UI/UX 특징

### 디자인 원칙
- **Material Design 3** 적용
- **직관적인 네비게이션** (하단 탭)
- **시각적 피드백** (체크 상태, 애니메이션)
- **접근성 고려** (색상 대비, 터치 영역)

### 색상 체계
- **Primary**: 파란색 계열
- **주말 색상**: 토요일(파스텔 블루), 일요일(빨간색)
- **체크 완료**: 회색 + 취소선
- **다음 달 섹션**: 그라데이션 배경

## 🚀 앱 플로우

### 목표 설정 플로우
1. 앱 최초 실행 → 웰컴 가이드
2. 이번 달 목표 설정 (1일~24일)
3. 다음 달 목표 설정 (25일~말일)
4. 일일 체크 시작

### 일일 사용 플로우
1. 앱 실행 → 홈 화면
2. 목표 체크 토글
3. 달력에서 월간 현황 확인
4. 설정에서 알림 관리

## 🚀 실행 방법

### 개발 환경 설정
```bash
# Flutter SDK 설치 확인
flutter doctor

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 빌드
```bash
# Android APK 빌드
flutter build apk

# iOS 빌드
flutter build ios
```

## 📱 지원 플랫폼

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Chrome, Safari, Firefox
- **Desktop**: Windows, macOS, Linux

## 🔮 향후 개발 계획

### 예정 기능
- [ ] 목표 카테고리 분류
- [ ] 목표 달성 통계 차트
- [ ] 목표 공유 기능
- [ ] 백업/복원 기능
- [ ] 다크 모드 지원
- [ ] 다국어 지원

### 개선 사항
- [ ] 성능 최적화
- [ ] 접근성 개선
- [ ] 테스트 코드 추가
- [ ] CI/CD 파이프라인 구축

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 🧑‍💻 개발팀

- **개발자**: [개발자명]
- **디자인**: [디자이너명]
- **기획**: [기획자명]

---

**한 달의 집중**으로 매월의 목표를 달성하고 습관을 형성해보세요! 🎯