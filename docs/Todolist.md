# 텅장히어로 아키텍처 재설계 작업 목록

> ARCHITECTURE_REDESIGN.md 기반 구현 작업 목록
>
> 상태: `[ ]` 미완료 | `[x]` 완료 | `[~]` 진행중

---

## 현재 코드 상태 분석

### 문제점
1. **게임 데이터가 로컬 DB에 저장됨** (아키텍처 위반)
   - `HeroStatsTable`, `Quests`, `Achievements`, `Skills` 테이블이 로컬에 존재
   - 아키텍처: 게임 = 온라인 전용, 서버에서만 처리

2. **SQLite 암호화 미적용**
   - 현재: `drift_flutter` 사용 (암호화 없음)
   - 필요: `sqlcipher` 또는 `drift_sqflite_cipher`

3. **토큰 저장소 미구현**
   - `flutter_secure_storage` 패키지 미설치

4. **동기화 메타데이터 부족**
   - `deleted_at`, `device_id` 컬럼 누락

---

## Phase 1: 가계부 오프라인 (로컬 우선) ✅ 완료

### 1.1 의존성 추가
- [x] `pubspec.yaml`에 패키지 추가
  - [x] `flutter_secure_storage` (토큰/암호화 키 저장)
  - [x] `sqlcipher_flutter_libs` (SQLite 암호화)
  - [x] `uuid` (디바이스 ID 생성)

### 1.2 SQLite 스키마 재설계
- [x] `app/lib/core/database/app_database.dart` 수정
  - [x] 게임 테이블 제거 (서버 전용으로 이동)
    - [x] `HeroStatsTable` 제거
    - [x] `Quests` 제거
    - [x] `Achievements` 제거
    - [x] `Skills` 제거
  - [x] `Transactions` 테이블 수정
    - [x] `deleted_at` 컬럼 추가 (soft delete/tombstone)
    - [x] `device_id` 컬럼 추가 (멀티 디바이스)
    - [x] `receipt_image_path` 컬럼 추가
    - [x] `receipt_ocr_status` 컬럼 추가
  - [x] `CategoryBudgets` 테이블 수정
    - [x] sync 관련 컬럼 추가 (`serverId`, `syncStatus`, `syncedAt`, `updatedAt`, `deleted_at`, `device_id`)
  - [x] `Categories` 테이블 추가 (사용자 정의 카테고리)
    - [x] `id`, `name`, `icon`, `color`
    - [x] sync 관련 컬럼
  - [x] `UserSettings` 테이블 추가 (로컬 설정)
    - [x] `device_id`, `last_sync_at`, `is_guest_mode`
  - [x] 스키마 버전 업그레이드 (3 → 4)
  - [x] 마이그레이션 로직 작성

### 1.3 SQLite 암호화 적용
- [x] `app/lib/core/database/database_encryption.dart` 생성
  - [x] 암호화 키 생성/저장 로직
  - [x] `flutter_secure_storage`에 키 저장
- [x] `app_database.dart`에서 암호화 연결 적용
  - [x] `_openConnection()` 수정

### 1.4 디바이스 ID 관리
- [x] `app/lib/core/utils/device_id.dart` 생성
  - [x] UUID 생성 및 저장
  - [x] `flutter_secure_storage`에 저장

### 1.5 로컬 거래 CRUD 수정
- [x] `app/lib/features/transactions/` 수정
  - [x] soft delete 적용 (`deleted_at` 사용)
  - [x] `device_id` 자동 추가
  - [x] `updatedAt` 자동 갱신

### 1.6 오프라인/온라인 상태 감지
- [x] `app/lib/core/network/connectivity_provider.dart` 확인/수정
  - [x] 상태 변경 시 UI 알림

### 1.7 가계부 UI 업데이트
- [x] 오프라인 상태 표시 추가 (기존 NetworkStatusBanner 사용)
- [x] 게임 화면 온라인 전용 처리 (퀘스트 화면 등)

---

## Phase 2: 인증 & 게스트 ✅ 완료

### 2.1 토큰 관리 서비스
- [x] `app/lib/core/auth/token_service.dart` 생성
  - [x] Access Token 저장/조회
  - [x] Refresh Token 저장/조회
  - [x] 토큰 만료 확인
  - [x] 토큰 갱신 로직

### 2.2 Google OAuth 연동
- [x] `app/lib/features/auth/` 수정
  - [x] `google_sign_in` 연동 완성
  - [x] 로그인 성공 시 토큰 저장
  - [x] 로그아웃 시 토큰 삭제

### 2.3 게스트 모드 구현
- [x] `app/lib/core/auth/auth_state_service.dart` 생성
  - [x] 상태: `guest`, `loggedIn`, `tokenExpired`
  - [x] 상태별 기능 제한 정의
- [x] 앱 시작 플로우 수정
  - [x] 토큰 캐시 초기화 (main.dart)
  - [x] 게스트 모드 선택 시 상태 업데이트

### 2.4 로그인 유도 UI
- [x] 게스트 모드 경고 배너
  - [x] `GuestModeBanner` 위젯 생성
  - [x] `GuestModeCard` 위젯 생성
  - [x] `LoginRequiredOverlay` 위젯 생성
- [x] 게임 탭 접근 시 로그인 유도 (온라인 체크로 처리)

### 2.5 인증 미들웨어
- [x] `app/lib/core/network/auth_interceptor.dart` 생성
  - [x] API 클라이언트에 토큰 자동 첨부
  - [x] 401 응답 시 토큰 갱신 시도
  - [x] 갱신 실패 시 `tokenExpired` 상태로 전환

---

## Phase 3: 동기화 ✅ 완료

### 3.1 동기화 서비스 재설계
- [x] `app/lib/core/network/sync_service.dart` 수정
  - [x] LWW (Last-Write-Wins) 충돌 해결
  - [x] Tombstone 처리 (삭제된 레코드)
  - [x] 배치 처리 (100건씩)
  - [x] 개별 레코드 성공/실패 처리

### 3.2 동기화 API 연동
- [x] 서버 API 엔드포인트 연동 (기존 API 활용)
  - [x] `POST /transactions` (업로드)
  - [x] `GET /transactions` (다운로드)
  - [x] `POST /budgets` (예산 동기화)

### 3.3 동기화 타이밍
- [x] 앱 시작 시 (온라인이면) - `main.dart`
- [x] WiFi 연결 시 자동 - `sync_service.dart` 네트워크 리스너
- [x] 수동 동기화 버튼 - `more_screen.dart` 설정 패널
- [ ] 백그라운드 주기적 동기화 (Phase 5)

### 3.4 재시도 로직
- [x] 실패 건 재시도 로직 구현
- [x] 지수 백오프 (1초 → 2초 → 4초, 최대 30초)
- [x] 최대 10회 재시도
- [x] 사용자 알림 (SnackBar)

### 3.5 다중 기기 동기화
- [x] `device_id` 기반 충돌 감지
- [x] LWW 자동 해결
- [ ] 로그아웃 전 강제 동기화 (Phase 5)

### 3.6 게스트 → 로그인 전환
- [x] `data_merge_service.dart` 생성
- [x] 신규 계정: 자동 연결
- [x] 기존 계정: 선택 UI (`DataMergeDialog`)
  - [x] "이 기기 데이터 유지"
  - [x] "서버 데이터 가져오기"
  - [x] "양쪽 병합"
  - [x] 데이터 개수 표시
  - [x] 경고 메시지

---

## Phase 4: 게임 연동 (온라인 전용) ~진행중

### 4.1 게임 데이터 서버 전용화
- [x] 로컬 게임 테이블 제거 (Phase 1에서 완료)
- [x] 게임 API 클라이언트 구현 (api_client.dart에 기존 구현됨)
  - [x] `GET /hero` (히어로 정보)
  - [x] `GET /inventory` (인벤토리)
  - [x] `POST /hero/collect-rewards` (자동사냥 보상)
  - [x] `GET /challenges` (챌린지)

### 4.2 게임 UI 수정
- [x] 오프라인 시 게임 탭 비활성화 (`game_screen.dart`)
  - [x] "인터넷 연결이 필요합니다" 메시지
  - [x] "로그인이 필요합니다" 메시지 (게스트 모드)
  - [x] "가계부로 이동" 버튼
  - [x] "로그인하기" 버튼 (게스트 모드)
- [ ] 게임 데이터 캐싱 금지 (변조 방지) - 현재 로컬 더미 데이터 사용중

### 4.3 자동사냥 시스템
- [ ] 서버 API 연동
  - [ ] 앱 실행 시 자동 호출
  - [ ] 마지막 접속 시간 기반 보상 계산
  - [ ] 최대 24시간분 보상
- [ ] 중복 보상 방지 (서버 측 Row Lock)

### 4.4 보상 시스템 (가계부 → 게임)
- [ ] 동기화 시 보상 요청
  - [ ] `POST /api/v1/rewards/claim`
  - [ ] 거래 기록 ID 목록 전송
- [ ] 서버 검증
  - [ ] 일일 한도 (10건/5영수증)
  - [ ] 날짜 제한 (2일 이상 과거 = 보상 없음)
- [ ] 보상 결과 UI 표시
  - [ ] "동기화 완료! 경험치 +150 획득"

### 4.5 영수증 OCR 검증
- [ ] 영수증 이미지 업로드 API
  - [ ] `POST /api/v1/receipts/upload`
- [ ] OCR 결과 처리
  - [ ] 성공: 추가 보상
  - [ ] 실패: 기본 보상만
  - [ ] 사용자 알림
- [ ] 영수증 재촬영 기능

---

## Phase 5: 마무리

### 5.1 FCM 알림
- [ ] `firebase_messaging` 연동
- [ ] 서버에 FCM 토큰 등록
- [ ] 알림 시나리오
  - [ ] 동기화 완료
  - [ ] 보상 지급
  - [ ] 챌린지 알림

### 5.2 백그라운드 동기화
- [ ] `workmanager` 패키지 추가
- [ ] 주기적 동기화 (15분~1시간)
- [ ] 배터리/네트워크 조건 확인

### 5.3 Tombstone 정리
- [ ] 서버: 30일 경과 후 물리 삭제 배치 작업
- [ ] 클라이언트: 동기화 시 서버 정책 따름

### 5.4 QA 테스트 시나리오
- [ ] 오프라인 테스트
  - [ ] 가계부 CRUD
  - [ ] 온라인 전환 시 동기화
  - [ ] 게임 탭 접근 차단
- [ ] 동기화 테스트
  - [ ] 다중 기기 충돌
  - [ ] 네트워크 불안정 시뮬레이션
  - [ ] 대량 데이터 동기화
- [ ] 보상 테스트
  - [ ] 일일 한도 초과
  - [ ] 과거 날짜 거래
  - [ ] 영수증 중복 감지
- [ ] 인증 테스트
  - [ ] 토큰 만료 후 재로그인
  - [ ] 게스트 → 로그인 전환

### 5.5 성능 최적화
- [ ] 대량 데이터 페이지네이션
- [ ] 이미지 압축 (영수증)
- [ ] 쿼리 인덱싱 확인

### 5.6 배포 준비
- [ ] 환경 변수 설정 (dev/staging/prod)
- [ ] 앱 서명 설정
- [ ] 스토어 등록 준비

---

## 서버 작업 목록 (Go)

### S1. 동기화 API
- [ ] `POST /api/v1/sync/transactions` 구현
  - [ ] 배치 업로드 처리
  - [ ] LWW 충돌 해결
  - [ ] Tombstone 처리
- [ ] `GET /api/v1/sync/transactions` 구현
  - [ ] `since` 파라미터로 변경분만 조회
- [ ] 예산/카테고리 동기화 API

### S2. 보상 API
- [ ] `POST /api/v1/rewards/claim` 구현
  - [ ] 일일 한도 체크
  - [ ] 날짜 유효성 체크
  - [ ] 보상 계산 및 지급
- [ ] 동시 요청 중복 방지 (Row Lock)

### S3. 자동사냥 API
- [ ] `GET /api/v1/auto-hunt/claim` 구현
  - [ ] 마지막 접속 시간 기반 계산
  - [ ] 최대 24시간 제한
  - [ ] Row Lock으로 중복 방지
  - [ ] `last_reward_claimed_at` 컬럼 추가

### S4. 영수증 OCR API
- [ ] `POST /api/v1/receipts/upload` 구현
  - [ ] 이미지 저장
  - [ ] OCR 서비스 연동 (Google Vision 등)
  - [ ] 결과 저장 및 반환

### S5. 게스트 → 로그인 병합 API
- [ ] `POST /api/v1/auth/merge` 구현
  - [ ] 기존 데이터 조회
  - [ ] 선택에 따른 처리

### S6. Tombstone 정리 배치
- [ ] 30일 경과 레코드 물리 삭제
- [ ] 매일 새벽 실행 (cron job)

### S7. 보안 강화
- [ ] HTTPS 강제
- [ ] CORS 설정 수정 (`*` 제거)
- [ ] JWT Secret 환경 변수화

---

## 우선순위 요약

| 순서 | 작업 | 예상 복잡도 |
|------|------|-------------|
| 1 | Phase 1.2 스키마 재설계 (게임 테이블 제거) | 높음 |
| 2 | Phase 1.3 SQLite 암호화 | 중간 |
| 3 | Phase 2.1-2.2 토큰 관리 & OAuth | 중간 |
| 4 | Phase 2.3 게스트 모드 | 중간 |
| 5 | Phase 3.1-3.2 동기화 서비스 | 높음 |
| 6 | Phase 4.1-4.2 게임 서버 전용화 | 중간 |
| 7 | Phase 4.4 보상 시스템 | 높음 |
| 8 | Phase 5 마무리 | 중간 |

---

## 체크리스트 사용법

1. 작업 시작 전 해당 항목을 `[~]`로 변경
2. 작업 완료 후 `[x]`로 변경
3. 관련 커밋 메시지에 항목 번호 포함 (예: `feat: Phase 1.2 - 게임 테이블 제거`)
