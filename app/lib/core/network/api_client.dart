import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import 'retry_interceptor.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;
  String? _authToken;
  bool _isOffline = false;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 재시도 인터셉터 추가
    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    // 인증 및 에러 처리 인터셉터
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 오프라인 체크
        if (_isOffline) {
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'Offline mode',
            ),
          );
        }

        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token expiration
          _authToken = null;
        }
        return handler.next(error);
      },
    ));

    // 디버그 로깅 (개발 환경에서만)
    assert(() {
      _dio.interceptors.add(LoggingInterceptor(enabled: true));
      return true;
    }());
  }

  /// 오프라인 모드 설정
  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  /// 오프라인 모드 여부
  bool get isOffline => _isOffline;

  /// DioException을 AppException으로 변환
  AppException convertException(DioException e) {
    // 서버 응답 에러 파싱
    if (e.response != null) {
      final data = e.response?.data;
      final statusCode = e.response?.statusCode ?? 0;

      // 서버 에러 메시지 파싱
      if (data is Map<String, dynamic>) {
        final errorCode = data['code'] as String?;
        final message = data['message'] as String? ?? e.message ?? 'Unknown error';

        // 인증 관련 에러
        if (statusCode == 401) {
          return AuthException(
            message: message,
            type: errorCode == 'TOKEN_EXPIRED'
                ? AuthErrorType.tokenExpired
                : AuthErrorType.unauthorized,
            code: errorCode,
            originalError: e,
          );
        }

        if (statusCode == 403) {
          return AuthException(
            message: message,
            type: AuthErrorType.unauthorized,
            code: errorCode,
            originalError: e,
          );
        }

        // 에러 코드별 처리
        switch (errorCode) {
          case 'INVALID_CREDENTIALS':
            return AuthException(
              message: message,
              type: AuthErrorType.invalidCredentials,
              code: errorCode,
              originalError: e,
            );
          case 'EMAIL_IN_USE':
            return AuthException(
              message: message,
              type: AuthErrorType.emailInUse,
              code: errorCode,
              originalError: e,
            );
          case 'USER_NOT_FOUND':
            return AuthException(
              message: message,
              type: AuthErrorType.userNotFound,
              code: errorCode,
              originalError: e,
            );
          case 'VALIDATION_ERROR':
            final fieldErrors = data['errors'] as Map<String, dynamic>? ?? {};
            return ValidationException(
              message: message,
              fieldErrors: fieldErrors.map(
                (k, v) => MapEntry(k, (v as List).cast<String>()),
              ),
              originalError: e,
            );
        }
      }
    }

    // 네트워크 에러로 변환
    return NetworkException.fromDioException(e);
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  // Auth
  Future<Response> register(String email, String password, String nickname) {
    return _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'nickname': nickname,
    });
  }

  Future<Response> login(String email, String password) {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> refreshToken() {
    return _dio.post('/auth/refresh');
  }

  Future<Response> loginWithGoogle(String idToken) {
    return _dio.post('/auth/google', data: {
      'id_token': idToken,
    });
  }

  Future<Response> loginWithKakao(String accessToken) {
    return _dio.post('/auth/kakao', data: {
      'access_token': accessToken,
    });
  }

  Future<Response> findEmail(String nickname) {
    return _dio.post('/auth/find-email', data: {
      'nickname': nickname,
    });
  }

  Future<Response> requestPasswordReset(String email) {
    return _dio.post('/auth/password-reset', data: {
      'email': email,
    });
  }

  Future<Response> confirmPasswordReset(String token, String newPassword) {
    return _dio.post('/auth/password-reset/confirm', data: {
      'token': token,
      'new_password': newPassword,
    });
  }

  // User
  Future<Response> getMe() {
    return _dio.get('/users/me');
  }

  Future<Response> updateMe(Map<String, dynamic> data) {
    return _dio.put('/users/me', data: data);
  }

  Future<Response> getUserStats() {
    return _dio.get('/users/me/stats');
  }

  // Hero
  Future<Response> createHero(String name, String buildType) {
    return _dio.post('/hero', data: {
      'name': name,
      'build_type': buildType,
    });
  }

  Future<Response> getHero() {
    return _dio.get('/hero');
  }

  Future<Response> getHeroStats() {
    return _dio.get('/hero/stats');
  }

  Future<Response> allocateStat(String stat, int points) {
    return _dio.post('/hero/stats/allocate', data: {
      'stat': stat,
      'points': points,
    });
  }

  Future<Response> resetStats() {
    return _dio.post('/hero/stats/reset');
  }

  Future<Response> collectOfflineRewards() {
    return _dio.post('/hero/collect-rewards');
  }

  Future<Response> getStages() {
    return _dio.get('/hero/stages');
  }

  Future<Response> changeStage(int stageId) {
    return _dio.post('/hero/stages/change', data: {
      'stage_id': stageId,
    });
  }

  Future<Response> simulateHunting() {
    return _dio.post('/hero/hunt');
  }

  // Transactions
  Future<Response> getTransactions({
    int? year,
    int? month,
    String? type,
    String? category,
    int page = 1,
    int limit = 20,
  }) {
    return _dio.get('/transactions', queryParameters: {
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> createTransaction(Map<String, dynamic> data) {
    return _dio.post('/transactions', data: data);
  }

  Future<Response> getTransaction(int id) {
    return _dio.get('/transactions/$id');
  }

  Future<Response> updateTransaction(int id, Map<String, dynamic> data) {
    return _dio.put('/transactions/$id', data: data);
  }

  Future<Response> deleteTransaction(int id) {
    return _dio.delete('/transactions/$id');
  }

  Future<Response> getTransactionSummary({int? year, int? month}) {
    return _dio.get('/transactions/summary', queryParameters: {
      if (year != null) 'year': year,
      if (month != null) 'month': month,
    });
  }

  // Budget
  Future<Response> getBudget({int? year, int? month}) {
    return _dio.get('/budgets', queryParameters: {
      if (year != null) 'year': year,
      if (month != null) 'month': month,
    });
  }

  Future<Response> createBudget(Map<String, dynamic> data) {
    return _dio.post('/budgets', data: data);
  }

  Future<Response> updateBudget(Map<String, dynamic> data, {int? year, int? month}) {
    return _dio.put('/budgets', data: data, queryParameters: {
      if (year != null) 'year': year,
      if (month != null) 'month': month,
    });
  }

  Future<Response> copyBudget(int year, int month) {
    return _dio.post('/budgets/copy', queryParameters: {
      'year': year,
      'month': month,
    });
  }

  // Quests
  Future<Response> getActiveQuests() {
    return _dio.get('/quests/active');
  }

  Future<Response> getAllQuests() {
    return _dio.get('/quests');
  }

  Future<Response> getQuestHistory({int page = 1, int limit = 20}) {
    return _dio.get('/quests/history', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> claimQuestReward(int questId) {
    return _dio.post('/quests/$questId/claim');
  }

  // Achievements
  Future<Response> getAchievements() {
    return _dio.get('/achievements');
  }

  Future<Response> getAchievementsByCategory(String category) {
    return _dio.get('/achievements/category/$category');
  }

  Future<Response> claimAchievementReward(int achievementId) {
    return _dio.post('/achievements/$achievementId/claim');
  }

  // Challenges
  Future<Response> getChallenges({
    String? type,
    String? status,
    String? category,
    int page = 1,
    int limit = 20,
  }) {
    return _dio.get('/challenges', queryParameters: {
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> createChallenge(Map<String, dynamic> data) {
    return _dio.post('/challenges', data: data);
  }

  Future<Response> getChallenge(int id) {
    return _dio.get('/challenges/$id');
  }

  Future<Response> joinChallenge(int id) {
    return _dio.post('/challenges/$id/join');
  }

  Future<Response> claimChallengeReward(int id) {
    return _dio.post('/challenges/$id/claim');
  }

  Future<Response> getMyChallenges() {
    return _dio.get('/challenges/my');
  }

  // Inventory
  Future<Response> getInventory() {
    return _dio.get('/inventory');
  }

  Future<Response> getItemInfo(String itemType) {
    return _dio.get('/inventory/items/$itemType');
  }

  Future<Response> useItem(String itemType, int quantity) {
    return _dio.post('/inventory/use', data: {
      'item_type': itemType,
      'quantity': quantity,
    });
  }

  Future<Response> sellItems(String itemType, int quantity) {
    return _dio.post('/inventory/sell', data: {
      'item_type': itemType,
      'quantity': quantity,
    });
  }

  // Equipment
  Future<Response> getEquipments() {
    return _dio.get('/equipment');
  }

  Future<Response> getEquipment(int id) {
    return _dio.get('/equipment/$id');
  }

  Future<Response> equipItem(int equipmentId) {
    return _dio.post('/equipment/equip', data: {
      'equipment_id': equipmentId,
    });
  }

  Future<Response> unequipItem(int id) {
    return _dio.post('/equipment/$id/unequip');
  }

  Future<Response> enhanceEquipment(int equipmentId) {
    return _dio.post('/equipment/enhance', data: {
      'equipment_id': equipmentId,
    });
  }

  Future<Response> sellEquipment(int id) {
    return _dio.delete('/equipment/$id');
  }
}
