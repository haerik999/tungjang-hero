# 텅장히어로 (TungJang Hero)

RPG 스타일 게이미피케이션 가계부 앱

## 프로젝트 구조

```
텅장히어로/
├── app/                    # Flutter 모바일 앱
│   ├── lib/
│   │   ├── core/          # 공통 모듈
│   │   │   ├── constants/ # 상수
│   │   │   ├── database/  # Drift 데이터베이스
│   │   │   ├── network/   # Dio 네트워크
│   │   │   └── theme/     # 앱 테마
│   │   ├── features/      # 기능별 모듈
│   │   │   ├── auth/      # 인증
│   │   │   ├── home/      # 홈 화면
│   │   │   ├── hero/      # 히어로 상태
│   │   │   ├── transactions/ # 거래 내역
│   │   │   ├── quests/    # 퀘스트
│   │   │   ├── achievements/ # 업적
│   │   │   └── settings/  # 설정
│   │   └── router/        # GoRouter 라우팅
│   └── pubspec.yaml
│
└── server/                 # Go 백엔드 서버
    ├── main.go
    ├── Dockerfile
    ├── docker-compose.yml
    └── go.mod
```

## 기술 스택

### Flutter App
- **상태관리**: flutter_riverpod
- **라우팅**: go_router
- **네트워크**: dio, retrofit
- **로컬 DB**: drift
- **데이터 클래스**: freezed
- **UI 컴포넌트**: getwidget
- **애니메이션**: flutter_animate, rive, lottie

### Go Server
- **프레임워크**: Gin
- **데이터베이스**: PostgreSQL
- **컨테이너**: Docker

## 시작하기

### Flutter App

```bash
cd app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Go Server

```bash
cd server
docker-compose up -d
```

서버가 `http://localhost:8080`에서 실행됩니다.

## API 엔드포인트

- `GET /health` - 서버 상태 확인
- `POST /api/v1/auth/register` - 회원가입
- `POST /api/v1/auth/login` - 로그인
- `GET /api/v1/users/me` - 내 정보
- `GET /api/v1/hero` - 히어로 상태
- `GET /api/v1/transactions` - 거래 목록
- `POST /api/v1/transactions` - 거래 추가
- `GET /api/v1/quests` - 퀘스트 목록
- `GET /api/v1/achievements` - 업적 목록

## 게임 시스템

### XP 시스템
- 저축 1,000원 = 10 XP
- 퀘스트 완료 = 보너스 XP
- 연속 기록 = 추가 XP

### HP 시스템
- 과소비 1,000원 = 5 데미지
- HP가 0이 되면 레벨 다운

### 퀘스트
- 일일 퀘스트: 매일 갱신
- 주간 퀘스트: 주 단위 목표
- 챌린지: 특별 미션

### 업적
- 저축 마일스톤
- 연속 기록 달성
- 레벨 달성
- 퀘스트 완료 횟수
