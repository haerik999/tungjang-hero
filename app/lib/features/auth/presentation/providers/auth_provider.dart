import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/auth_state_service.dart';
import '../../../../core/auth/token_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';

part 'auth_provider.g.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? token;
  final AppError? error;
  final Map<String, dynamic>? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.error,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    AppError? error,
    Map<String, dynamic>? user,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      error: clearError ? null : (error ?? this.error),
      user: user ?? this.user,
    );
  }

  bool get hasError => error != null;
  String? get errorMessage => error?.message;
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    return const AuthState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<bool> register(String email, String password, String nickname) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final response = await _apiClient.register(email, password, nickname);
      final data = response.data as Map<String, dynamic>;

      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final expiresIn = data['expires_in'] as int?;

      if (token != null) {
        // 토큰 저장
        await TokenService.saveAccessToken(token, expiresInSeconds: expiresIn);
        if (refreshToken != null) {
          await TokenService.saveRefreshToken(refreshToken);
        }

        _apiClient.setAuthToken(token);

        // AppAuth 상태 업데이트
        final user = data['user'] as Map<String, dynamic>?;
        await ref.read(appAuthProvider.notifier).onLoginSuccess(
              accessToken: token,
              refreshToken: refreshToken,
              expiresInSeconds: expiresIn,
              userId: user?['id']?.toString(),
              email: user?['email'] as String?,
              nickname: user?['nickname'] as String?,
            );
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: data['user'] as Map<String, dynamic>?,
      );

      return true;
    } on DioException catch (e) {
      final appError = AppError.fromException(_apiClient.convertException(e));
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: appError,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: AppError.unknown(e),
      );
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final response = await _apiClient.login(email, password);
      final data = response.data as Map<String, dynamic>;

      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final expiresIn = data['expires_in'] as int?;

      if (token != null) {
        // 토큰 저장
        await TokenService.saveAccessToken(token, expiresInSeconds: expiresIn);
        if (refreshToken != null) {
          await TokenService.saveRefreshToken(refreshToken);
        }

        _apiClient.setAuthToken(token);

        // AppAuth 상태 업데이트
        final user = data['user'] as Map<String, dynamic>?;
        await ref.read(appAuthProvider.notifier).onLoginSuccess(
              accessToken: token,
              refreshToken: refreshToken,
              expiresInSeconds: expiresIn,
              userId: user?['id']?.toString(),
              email: user?['email'] as String?,
              nickname: user?['nickname'] as String?,
            );
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: data['user'] as Map<String, dynamic>?,
      );

      return true;
    } on DioException catch (e) {
      final appError = AppError.fromException(_apiClient.convertException(e));
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: appError,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: AppError.unknown(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    // 토큰 삭제
    await TokenService.clearAllTokens();
    _apiClient.setAuthToken(null);

    // AppAuth 상태 업데이트
    await ref.read(appAuthProvider.notifier).logout();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshToken() async {
    try {
      final response = await _apiClient.refreshToken();
      final data = response.data as Map<String, dynamic>;

      final token = data['token'] as String?;
      final expiresIn = data['expires_in'] as int?;

      if (token != null) {
        await TokenService.saveAccessToken(token, expiresInSeconds: expiresIn);
        _apiClient.setAuthToken(token);
        await ref.read(appAuthProvider.notifier).onTokenRefreshed(
              accessToken: token,
              expiresInSeconds: expiresIn,
            );
        state = state.copyWith(token: token);
      }
    } catch (e) {
      await logout();
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final response = await _apiClient.loginWithGoogle(idToken);
      final data = response.data as Map<String, dynamic>;

      final token = data['token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final expiresIn = data['expires_in'] as int?;

      if (token != null) {
        // 토큰 저장
        await TokenService.saveAccessToken(token, expiresInSeconds: expiresIn);
        if (refreshToken != null) {
          await TokenService.saveRefreshToken(refreshToken);
        }

        _apiClient.setAuthToken(token);

        // AppAuth 상태 업데이트
        final user = data['user'] as Map<String, dynamic>?;
        await ref.read(appAuthProvider.notifier).onLoginSuccess(
              accessToken: token,
              refreshToken: refreshToken,
              expiresInSeconds: expiresIn,
              userId: user?['id']?.toString(),
              email: user?['email'] as String?,
              nickname: user?['nickname'] as String?,
            );
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: data['user'] as Map<String, dynamic>?,
      );

      return true;
    } on DioException catch (e) {
      final appError = AppError.fromException(_apiClient.convertException(e));
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: appError,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: AppError.unknown(e),
      );
      return false;
    }
  }

  Future<String?> findEmail(String nickname) async {
    try {
      final response = await _apiClient.findEmail(nickname);
      return response.data['masked_email'] as String?;
    } on DioException catch (e) {
      final appError = AppError.fromException(_apiClient.convertException(e));
      state = state.copyWith(error: appError);
      return null;
    } catch (e) {
      state = state.copyWith(error: AppError.unknown(e));
      return null;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      await _apiClient.requestPasswordReset(email);
      return true;
    } on DioException catch (e) {
      final appError = AppError.fromException(_apiClient.convertException(e));
      state = state.copyWith(error: appError);
      return false;
    } catch (e) {
      state = state.copyWith(error: AppError.unknown(e));
      return false;
    }
  }

  Future<bool> confirmPasswordReset(String token, String newPassword) async {
    try {
      await _apiClient.confirmPasswordReset(token, newPassword);
      return true;
    } on DioException catch (e) {
      final appError = AppError.fromException(_apiClient.convertException(e));
      state = state.copyWith(error: appError);
      return false;
    } catch (e) {
      state = state.copyWith(error: AppError.unknown(e));
      return false;
    }
  }
}
