import 'dart:async';
import 'package:dio/dio.dart';
import '../auth/token_service.dart';

/// 인증 인터셉터
/// - 요청에 자동으로 토큰 첨부
/// - 401 응답 시 토큰 갱신 시도
/// - 갱신 실패 시 콜백 호출
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Future<Response<dynamic>> Function()? refreshTokenCallback;
  final void Function()? onTokenExpired;

  bool _isRefreshing = false;
  final List<_RequestRetryInfo> _pendingRequests = [];

  AuthInterceptor({
    required this.dio,
    this.refreshTokenCallback,
    this.onTokenExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰 갱신 요청이나 로그인 요청은 토큰 없이 진행
    if (_isAuthRequest(options.path)) {
      return handler.next(options);
    }

    // 토큰 자동 첨부
    final token = await TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 응답이 아니면 그대로 전달
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 이미 인증 요청이면 그대로 에러 반환
    if (_isAuthRequest(err.requestOptions.path)) {
      return handler.next(err);
    }

    // 토큰 갱신 콜백이 없으면 토큰 만료 처리
    if (refreshTokenCallback == null) {
      onTokenExpired?.call();
      return handler.next(err);
    }

    // 이미 토큰 갱신 중이면 대기열에 추가
    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingRequests.add(_RequestRetryInfo(
        requestOptions: err.requestOptions,
        completer: completer,
      ));

      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // 토큰 갱신 시도
    _isRefreshing = true;

    try {
      final refreshResponse = await refreshTokenCallback!();
      final data = refreshResponse.data as Map<String, dynamic>?;

      // 새 토큰 저장
      final newToken = data?['access_token'] ?? data?['token'];
      if (newToken != null) {
        final expiresIn = data?['expires_in'] as int?;
        await TokenService.saveAccessToken(newToken, expiresInSeconds: expiresIn);

        // 대기 중인 요청들 재시도
        await _retryPendingRequests(newToken);

        // 원래 요청 재시도
        final retryResponse = await _retryRequest(err.requestOptions, newToken);
        return handler.resolve(retryResponse);
      } else {
        throw Exception('Invalid refresh response');
      }
    } catch (e) {
      // 갱신 실패 - 모든 대기 요청 실패 처리
      _failPendingRequests();
      onTokenExpired?.call();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// 인증 관련 요청인지 확인
  bool _isAuthRequest(String path) {
    return path.contains('/auth/') ||
        path.contains('/login') ||
        path.contains('/register') ||
        path.contains('/refresh');
  }

  /// 요청 재시도
  Future<Response> _retryRequest(RequestOptions options, String token) async {
    final newOptions = options.copyWith();
    newOptions.headers['Authorization'] = 'Bearer $token';
    return dio.fetch(newOptions);
  }

  /// 대기 중인 요청들 재시도
  Future<void> _retryPendingRequests(String token) async {
    for (final info in _pendingRequests) {
      try {
        final response = await _retryRequest(info.requestOptions, token);
        info.completer.complete(response);
      } catch (e) {
        info.completer.completeError(e);
      }
    }
    _pendingRequests.clear();
  }

  /// 대기 중인 요청들 실패 처리
  void _failPendingRequests() {
    for (final info in _pendingRequests) {
      info.completer.completeError(
        DioException(
          requestOptions: info.requestOptions,
          type: DioExceptionType.cancel,
          message: 'Token refresh failed',
        ),
      );
    }
    _pendingRequests.clear();
  }
}

/// 재시도 대기 중인 요청 정보
class _RequestRetryInfo {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _RequestRetryInfo({
    required this.requestOptions,
    required this.completer,
  });
}
