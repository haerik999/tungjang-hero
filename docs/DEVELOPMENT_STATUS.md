# 텅장히어로 (TungjangHero) 개발 현황

> 게임화된 가계부 앱 - 가계부를 쓰면서 RPG 게임을 즐기는 앱

## 프로젝트 개요

**텅장히어로**는 지출/수입 기록을 게임 보상과 연결하여 사용자가 재미있게 가계부를 관리할 수 있도록 하는 앱입니다. 거래를 기록하면 경험치, 골드, 아이템 등의 보상을 받고, 캐릭터가 자동으로 사냥하며 성장합니다.

### 핵심 컨셉
- **가계부 기록 → 게임 보상**: 지출/수입을 기록하면 강화석, 스킬북, 가챠 티켓 등 획득
- **방치형 RPG**: 앱을 끄고 있어도 캐릭터가 자동으로 사냥하며 성장
- **이중 성장 시스템**: 가계부 기록 + 게임 플레이 모두 해야 빠른 성장

---

## 개발 진행률

### 전체 진행률: **90%**

| 구분 | 진행률 | 상태 |
|------|--------|------|
| 서버 (Go/Gin) | 100% | ✅ 완료 |
| Flutter 앱 | 85% | 🔄 주요 기능 완료 |
| Docker 구성 | 100% | ✅ 완료 |
| 테스트 | 0% | ⏳ 미진행 |

---

## 서버 구현 현황 (Go/Gin)

### 완료된 기능

#### 1. 인프라 구조
```
server/
├── main.go                          # 앱 엔트리포인트
├── Dockerfile                       # Docker 이미지 빌드
├── docker-compose.yml               # Docker Compose 설정
├── Makefile                         # 편리한 명령어
├── go.mod / go.sum                  # 의존성 관리
├── .env.example                     # 환경변수 템플릿
└── internal/
    ├── config/config.go             # 환경설정
    ├── database/database.go         # DB 연결 및 마이그레이션
    ├── middleware/
    │   ├── auth.go                  # JWT 인증
    │   ├── cors.go                  # CORS 설정
    │   └── ratelimit.go             # Rate Limiting
    ├── domain/models/               # 도메인 모델 (13개)
    └── handlers/                    # API 핸들러 (10개)
```

#### 2. 도메인 모델 (13개)

| 모델 | 파일 | 설명 |
|------|------|------|
| User | `user.go` | 사용자 계정, 인증 |
| Hero | `hero.go` | 캐릭터 스탯, 레벨, 사냥 |
| Transaction | `transaction.go` | 거래 기록, 카테고리 |
| Reward | `reward.go` | 보상 시스템, 확률 테이블 |
| Quest | `quest.go` | 일일/주간/월간 퀘스트 |
| Equipment | `equipment.go` | 장비, 강화 시스템 |
| Item | `item.go` | 소비 아이템, 인벤토리 |
| Stage | `stage.go` | 사냥터, 몬스터 |
| Skill | `skill.go` | 액티브/패시브 스킬 |
| Preset | `preset.go` | 스탯 프리셋 |
| Challenge | `challenge.go` | 개인/커뮤니티 챌린지 |
| Achievement | `achievement.go` | 업적 시스템 |
| Budget | `budget.go` | 예산 관리 |

#### 3. API 엔드포인트

**인증 (Public)**
```
POST /api/v1/auth/register     # 회원가입
POST /api/v1/auth/login        # 로그인
```

**인증 필요 (Protected)**
```
# 사용자
GET  /api/v1/users/me          # 내 정보 조회
PUT  /api/v1/users/me          # 내 정보 수정
GET  /api/v1/users/me/stats    # 통계 조회

# 히어로
POST /api/v1/hero              # 히어로 생성
GET  /api/v1/hero              # 히어로 조회
GET  /api/v1/hero/stats        # 스탯 조회
POST /api/v1/hero/stats/allocate   # 스탯 분배
POST /api/v1/hero/stats/reset      # 스탯 초기화
POST /api/v1/hero/collect-rewards  # 오프라인 보상 수령
GET  /api/v1/hero/stages       # 사냥터 목록
POST /api/v1/hero/stages/change    # 사냥터 변경
POST /api/v1/hero/hunt         # 사냥 시뮬레이션

# 거래
GET  /api/v1/transactions      # 거래 목록
POST /api/v1/transactions      # 거래 생성 (+ 보상 지급)
GET  /api/v1/transactions/:id  # 거래 상세
PUT  /api/v1/transactions/:id  # 거래 수정
DELETE /api/v1/transactions/:id # 거래 삭제
GET  /api/v1/transactions/summary # 요약 통계

# 예산
GET  /api/v1/budgets           # 예산 조회
POST /api/v1/budgets           # 예산 생성
PUT  /api/v1/budgets           # 예산 수정
DELETE /api/v1/budgets         # 예산 삭제

# 퀘스트
GET  /api/v1/quests            # 전체 퀘스트
GET  /api/v1/quests/active     # 활성 퀘스트
POST /api/v1/quests/:id/claim  # 보상 수령

# 업적
GET  /api/v1/achievements      # 업적 목록
POST /api/v1/achievements/:id/claim # 보상 수령

# 챌린지
GET  /api/v1/challenges        # 챌린지 목록
POST /api/v1/challenges/:id/join   # 참가
POST /api/v1/challenges/:id/claim  # 보상 수령

# 인벤토리
GET  /api/v1/inventory         # 인벤토리 조회
POST /api/v1/inventory/use     # 아이템 사용
POST /api/v1/inventory/sell    # 아이템 판매

# 장비
GET  /api/v1/equipment         # 장비 목록
POST /api/v1/equipment/equip   # 장비 장착
POST /api/v1/equipment/:id/unequip # 장착 해제
POST /api/v1/equipment/enhance # 장비 강화
DELETE /api/v1/equipment/:id   # 장비 판매
```

---

## Flutter 앱 구현 현황

### 완료된 기능

#### 1. 프로젝트 구조
```
app/lib/
├── main.dart                        # 앱 엔트리포인트
├── router/app_router.dart           # GoRouter 라우팅
├── core/
│   ├── theme/app_theme.dart         # 테마 설정
│   ├── constants/app_constants.dart # 상수 정의
│   ├── database/
│   │   ├── app_database.dart        # Drift 로컬 DB
│   │   └── database_provider.dart   # DB Provider
│   └── network/
│       ├── api_client.dart          # API 클라이언트
│       └── dio_client.dart          # Dio 설정
├── shared/widgets/
│   ├── widgets.dart                 # 위젯 export
│   ├── hero_character.dart          # 캐릭터 위젯
│   ├── level_up_dialog.dart         # 레벨업 다이얼로그
│   ├── reward_popup.dart            # 보상 팝업
│   ├── game_effect_overlay.dart     # 게임 이펙트
│   └── number_keypad.dart           # 숫자 키패드
└── features/
    ├── auth/                        # 인증
    ├── onboarding/                  # 온보딩
    ├── home/                        # 홈
    ├── hero/                        # 히어로
    ├── transactions/                # 거래
    ├── budget/                      # 예산
    ├── quests/                      # 퀘스트
    ├── achievements/                # 업적
    ├── challenges/                  # 챌린지
    ├── inventory/                   # 인벤토리
    └── settings/                    # 설정
```

#### 2. 화면 구현 현황

| 화면 | 경로 | 상태 | 설명 |
|------|------|------|------|
| 온보딩 | `/onboarding` | ✅ 완료 | 4페이지 앱 소개 |
| 로그인 | `/login` | ✅ 완료 | 이메일/비밀번호 + 게스트 |
| 회원가입 | `/register` | ✅ 완료 | 이메일/비밀번호/닉네임 |
| 히어로 생성 | `/create-hero` | ✅ 완료 | 빌드 선택 (물리/마법/탱커/밸런스) |
| 홈 | `/` | ✅ 완료 | 요약, 퀘스트, 최근 거래 |
| 히어로 | `/hero` | ✅ 완료 | 스탯, 레벨, 장비 |
| 거래 목록 | `/transactions` | ✅ 완료 | 거래 내역 |
| 거래 추가 | `/transactions/add` | ✅ 완료 | 수입/지출 입력 |
| 예산 | `/budget` | ✅ 완료 | 카테고리별 예산 설정 |
| 퀘스트 | `/quests` | ✅ 완료 | 일일/주간/월간 퀘스트 |
| 업적 | `/achievements` | ✅ 완료 | 업적 목록 |
| 챌린지 | `/challenges` | ✅ 완료 | 개인/커뮤니티 챌린지 |
| 인벤토리 | `/inventory` | ✅ 완료 | 아이템/장비 관리 |
| 설정 | `/settings` | ✅ 완료 | 앱 설정 |

#### 3. 상태 관리 (Riverpod Providers)

| Provider | 파일 | 설명 |
|----------|------|------|
| authProvider | `auth_provider.dart` | 인증 상태 |
| heroStatsProvider | `hero_provider.dart` | 히어로 스탯 |
| transactionProvider | `transaction_provider.dart` | 거래 관리 |
| questManagerProvider | `quest_provider.dart` | 퀘스트 관리 |
| budgetManagerProvider | `budget_provider.dart` | 예산 관리 |
| challengeNotifierProvider | `challenge_provider.dart` | 챌린지 관리 |
| inventoryNotifierProvider | `inventory_provider.dart` | 인벤토리 관리 |

#### 4. 공유 위젯

| 위젯 | 설명 |
|------|------|
| HeroCharacter | 캐릭터 표시 (상태별 애니메이션) |
| LevelUpDialog | 레벨업 축하 팝업 |
| RewardPopup | 보상 획득 팝업 |
| RewardToast | 보상 토스트 알림 |
| GameEffectOverlay | 게임 이펙트 오버레이 |
| NumberKeypad | 금액 입력용 숫자 키패드 |

---

## 게임 시스템 상세

### 1. 보상 시스템

거래 기록 시 확률에 따라 보상 지급:

| 아이템 | 확률 | 용도 |
|--------|------|------|
| 강화석 | 60% | 장비 강화 |
| 스킬북 | 20% | 스킬 레벨업 |
| 가챠 티켓 | 10% | 장비 뽑기 |
| 펫 먹이 | 5% | 펫 성장 |
| HP 포션 | 3% | HP 회복 |
| 경험치 포션 | 2% | 경험치 획득 |

### 2. 스탯 시스템

| 스탯 | 약어 | 효과 |
|------|------|------|
| 체력 | HP | 최대 체력 |
| 마나 | MP | 스킬 사용 |
| 공격력 | ATK | 물리 데미지 |
| 마법력 | MAG | 마법 데미지 |
| 방어력 | DEF | 물리 방어 |
| 마법방어 | MDF | 마법 방어 |
| 속도 | SPD | 공격 속도 |
| 행운 | LUK | 크리티컬, 드롭률 |

### 3. 장비 시스템

**등급**: Common → Uncommon → Rare → Epic → Legendary

**슬롯**: 무기, 방어구, 장신구

**강화**: 강화석 소모, 실패 시 레벨 유지 또는 하락

### 4. 퀘스트 시스템

| 유형 | 갱신 주기 | 예시 |
|------|----------|------|
| 일일 | 매일 00시 | 거래 3회 기록, 5만원 이하 지출 |
| 주간 | 매주 월요일 | 예산 80% 이내 유지 |
| 월간 | 매월 1일 | 저축 목표 달성 |

---

## 실행 방법

### 1. 서버 실행 (Docker)

```bash
cd server

# 환경변수 설정 (선택사항)
cp .env.example .env
# .env 파일에서 JWT_SECRET 등 수정

# 서비스 시작
make up

# 상태 확인
make ps
make health

# 로그 확인
make logs
```

### 2. 서버 실행 (로컬)

```bash
cd server

# PostgreSQL 실행 필요
# .env 파일 설정

go mod download
go run main.go
```

### 3. Flutter 앱 실행

```bash
cd app

# 의존성 설치
flutter pub get

# 코드 생성 (Freezed, Riverpod, Drift)
flutter pub run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

### 4. Docker 명령어 요약

| 명령어 | 설명 |
|--------|------|
| `make up` | 서비스 시작 (백그라운드) |
| `make up-logs` | 서비스 시작 (로그 출력) |
| `make down` | 서비스 중지 |
| `make restart` | 서비스 재시작 |
| `make logs` | 전체 로그 |
| `make logs-api` | API 로그만 |
| `make db-shell` | PostgreSQL 쉘 접속 |
| `make clean` | 전체 삭제 (볼륨 포함) |
| `make dev` | 개발용 재빌드 |
| `make prod` | 프로덕션 모드 |

---

## 환경 변수

### 서버 (.env)

```env
# Server
SERVER_PORT=8080
GIN_MODE=debug          # debug | release

# Database
DB_HOST=localhost       # Docker: db
DB_PORT=5432
DB_USER=tungjang
DB_PASSWORD=heropassword
DB_NAME=tungjang_hero
DB_SSLMODE=disable

# JWT
JWT_SECRET=your-super-secret-key-change-in-production
JWT_EXPIRY_HOURS=24

# Timezone
TZ=Asia/Seoul
```

---

## 기술 스택

### 서버
- **언어**: Go 1.21+
- **프레임워크**: Gin
- **ORM**: GORM
- **데이터베이스**: PostgreSQL 16
- **인증**: JWT
- **컨테이너**: Docker, Docker Compose

### Flutter 앱
- **프레임워크**: Flutter 3.9+
- **상태관리**: Riverpod
- **라우팅**: GoRouter
- **로컬DB**: Drift (SQLite)
- **HTTP**: Dio
- **코드생성**: Freezed, json_serializable

---

## 남은 작업

### 필수
- [ ] 온라인/오프라인 모드 전환 로직
- [ ] 서버 API와 앱 연동 테스트
- [ ] 에러 핸들링 개선
- [ ] 로딩 상태 UI 개선

### 선택
- [ ] 단위 테스트 작성
- [ ] E2E 테스트 작성
- [ ] CI/CD 파이프라인 구성
- [ ] 푸시 알림 (퀘스트 리마인더)
- [ ] 소셜 로그인 (Google, Apple)
- [ ] 다크/라이트 테마 전환
- [ ] 다국어 지원

---

## 참고 문서

- [RPG 시스템 설계](./RPG_SYSTEM_DESIGN.md)
- [앱 화면 설계](./APP_SCREEN_DESIGN.md)

---

*마지막 업데이트: 2025-12-10*
