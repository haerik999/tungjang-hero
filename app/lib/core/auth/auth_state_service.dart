import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database_provider.dart';
import 'token_service.dart';

part 'auth_state_service.g.dart';

/// 앱 인증 상태
enum AppAuthStatus {
  /// 초기 상태 (확인 중)
  unknown,

  /// 게스트 모드 (로컬 데이터만 사용)
  guest,

  /// 로그인 상태 (동기화 가능)
  loggedIn,

  /// 토큰 만료 (재로그인 필요)
  tokenExpired,
}

/// 인증 상태 정보
class AppAuthState {
  final AppAuthStatus status;
  final String? userId;
  final String? email;
  final String? nickname;
  final bool hasLocalData;
  final String? errorMessage;

  const AppAuthState({
    this.status = AppAuthStatus.unknown,
    this.userId,
    this.email,
    this.nickname,
    this.hasLocalData = false,
    this.errorMessage,
  });

  AppAuthState copyWith({
    AppAuthStatus? status,
    String? userId,
    String? email,
    String? nickname,
    bool? hasLocalData,
    String? errorMessage,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      hasLocalData: hasLocalData ?? this.hasLocalData,
      errorMessage: errorMessage,
    );
  }

  bool get isGuest => status == AppAuthStatus.guest;
  bool get isLoggedIn => status == AppAuthStatus.loggedIn;
  bool get needsReLogin => status == AppAuthStatus.tokenExpired;
  bool get canSync => isLoggedIn;
  bool get canAccessGame => isLoggedIn;
}

/// 앱 인증 상태 관리 Provider
@Riverpod(keepAlive: true)
class AppAuth extends _$AppAuth {
  @override
  AppAuthState build() {
    _checkInitialState();
    return const AppAuthState();
  }

  /// 앱 시작 시 인증 상태 확인
  Future<void> _checkInitialState() async {
    // 1. 토큰 캐시 초기화
    await TokenService.initializeCache();

    // 2. 로컬 데이터 존재 여부 확인
    final hasLocalData = await _hasLocalData();

    // 3. 토큰 상태 확인
    final hasToken = await TokenService.hasValidToken();

    if (hasToken) {
      // 유효한 토큰이 있으면 로그인 상태
      state = state.copyWith(
        status: AppAuthStatus.loggedIn,
        hasLocalData: hasLocalData,
      );
    } else {
      // 토큰이 없거나 만료됨
      final hadToken = (await TokenService.getAccessToken()) != null;
      if (hadToken) {
        // 이전에 로그인 했었다면 토큰 만료 상태
        state = state.copyWith(
          status: AppAuthStatus.tokenExpired,
          hasLocalData: hasLocalData,
        );
      } else {
        // 처음부터 토큰이 없으면 게스트 상태
        state = state.copyWith(
          status: AppAuthStatus.guest,
          hasLocalData: hasLocalData,
        );
      }
    }
  }

  /// 로컬 데이터 존재 여부 확인
  Future<bool> _hasLocalData() async {
    try {
      final db = ref.read(databaseProvider);
      final transactions = await db.getAllTransactions();
      return transactions.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 로그인 성공 처리
  Future<void> onLoginSuccess({
    required String accessToken,
    String? refreshToken,
    int? expiresInSeconds,
    String? userId,
    String? email,
    String? nickname,
  }) async {
    // 토큰 저장
    await TokenService.saveAccessToken(accessToken, expiresInSeconds: expiresInSeconds);
    if (refreshToken != null) {
      await TokenService.saveRefreshToken(refreshToken);
    }

    // 상태 업데이트
    state = state.copyWith(
      status: AppAuthStatus.loggedIn,
      userId: userId,
      email: email,
      nickname: nickname,
    );
  }

  /// 로그아웃 처리
  Future<void> logout() async {
    await TokenService.clearAllTokens();
    state = state.copyWith(
      status: AppAuthStatus.guest,
      userId: null,
      email: null,
      nickname: null,
    );
  }

  /// 토큰 만료 처리
  void onTokenExpired() {
    state = state.copyWith(
      status: AppAuthStatus.tokenExpired,
      errorMessage: '로그인이 만료되었습니다. 다시 로그인해주세요.',
    );
  }

  /// 토큰 갱신 성공 처리
  Future<void> onTokenRefreshed({
    required String accessToken,
    int? expiresInSeconds,
  }) async {
    await TokenService.saveAccessToken(accessToken, expiresInSeconds: expiresInSeconds);
    state = state.copyWith(
      status: AppAuthStatus.loggedIn,
      errorMessage: null,
    );
  }

  /// 게스트 모드로 전환
  void enterGuestMode() {
    state = state.copyWith(status: AppAuthStatus.guest);
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 게스트 모드 여부 Provider
@riverpod
bool isGuestMode(IsGuestModeRef ref) {
  final authState = ref.watch(appAuthProvider);
  return authState.isGuest;
}

/// 로그인 상태 여부 Provider
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(appAuthProvider);
  return authState.isLoggedIn;
}

/// 동기화 가능 여부 Provider
@riverpod
bool canSync(CanSyncRef ref) {
  final authState = ref.watch(appAuthProvider);
  return authState.canSync;
}

/// 게임 접근 가능 여부 Provider (온라인 + 로그인 필요)
@riverpod
bool canAccessOnlineFeatures(CanAccessOnlineFeaturesRef ref) {
  final authState = ref.watch(appAuthProvider);
  return authState.canAccessGame;
}
