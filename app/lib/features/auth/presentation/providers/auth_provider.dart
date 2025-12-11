import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
      final data = response.data;

      _apiClient.setAuthToken(data['token']);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: data['token'],
        user: data['user'],
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
      final data = response.data;

      _apiClient.setAuthToken(data['token']);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: data['token'],
        user: data['user'],
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

  void logout() {
    _apiClient.setAuthToken(null);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshToken() async {
    try {
      final response = await _apiClient.refreshToken();
      final token = response.data['token'];
      _apiClient.setAuthToken(token);
      state = state.copyWith(token: token);
    } catch (e) {
      logout();
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final response = await _apiClient.loginWithGoogle(idToken);
      final data = response.data;

      _apiClient.setAuthToken(data['token']);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: data['token'],
        user: data['user'],
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
