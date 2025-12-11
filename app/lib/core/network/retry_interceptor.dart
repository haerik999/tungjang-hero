import 'package:dio/dio.dart';

/// 재시도 인터셉터
/// timeout, 5xx 에러 발생 시 자동으로 재시도
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final Dio dio;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] as int? ?? 0;

    // 재시도 가능 여부 확인
    if (!_shouldRetry(err) || retryCount >= maxRetries) {
      return handler.next(err);
    }

    // 지수 백오프 지연
    final delay = baseDelay * (1 << retryCount); // 1초, 2초, 4초...
    await Future.delayed(delay);

    // 재시도 횟수 증가
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // 요청 재시도
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // 재시도 실패 시 다시 onError 호출됨
      return handler.next(e);
    }
  }

  /// 재시도 가능한 에러인지 확인
  bool _shouldRetry(DioException err) {
    // 요청이 취소된 경우 재시도 안함
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // 타임아웃 에러는 재시도
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // 연결 에러는 재시도
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // 5xx 서버 에러는 재시도
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    return false;
  }
}

/// 로깅 인터셉터 (디버그용)
class LoggingInterceptor extends Interceptor {
  final bool enabled;

  LoggingInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      print('🌐 [REQUEST] ${options.method} ${options.uri}');
      if (options.data != null) {
        print('📦 [BODY] ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      print('✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      print('❌ [ERROR] ${err.type} ${err.requestOptions.uri}');
      print('📍 [MESSAGE] ${err.message}');
      if (err.response != null) {
        print('📄 [RESPONSE] ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}
