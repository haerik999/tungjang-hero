import 'package:dio/dio.dart';

/// 앱 전역 예외 기본 클래스
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  /// 사용자 친화적 메시지
  String get userMessage;

  /// 재시도 가능 여부
  bool get isRetryable;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// 네트워크 관련 예외
class NetworkException extends AppException {
  final NetworkErrorType type;

  const NetworkException({
    required super.message,
    required this.type,
    super.code,
    super.originalError,
  });

  @override
  String get userMessage {
    switch (type) {
      case NetworkErrorType.noConnection:
        return '인터넷 연결을 확인해주세요';
      case NetworkErrorType.timeout:
        return '서버 응답이 느립니다. 잠시 후 다시 시도해주세요';
      case NetworkErrorType.serverError:
        return '서버에 문제가 발생했습니다';
      case NetworkErrorType.badRequest:
        return '잘못된 요청입니다';
      case NetworkErrorType.notFound:
        return '요청한 데이터를 찾을 수 없습니다';
      case NetworkErrorType.unknown:
        return '네트워크 오류가 발생했습니다';
    }
  }

  @override
  bool get isRetryable =>
      type == NetworkErrorType.timeout || type == NetworkErrorType.serverError;

  factory NetworkException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: e.message ?? 'Timeout',
          type: NetworkErrorType.timeout,
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: e.message ?? 'No connection',
          type: NetworkErrorType.noConnection,
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode >= 500) {
          return NetworkException(
            message: 'Server error: $statusCode',
            type: NetworkErrorType.serverError,
            code: statusCode.toString(),
            originalError: e,
          );
        }
        if (statusCode == 404) {
          return NetworkException(
            message: 'Not found',
            type: NetworkErrorType.notFound,
            code: statusCode.toString(),
            originalError: e,
          );
        }
        if (statusCode >= 400) {
          return NetworkException(
            message: 'Bad request: $statusCode',
            type: NetworkErrorType.badRequest,
            code: statusCode.toString(),
            originalError: e,
          );
        }
        return NetworkException(
          message: e.message ?? 'Bad response',
          type: NetworkErrorType.unknown,
          code: statusCode.toString(),
          originalError: e,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          type: NetworkErrorType.unknown,
          originalError: e,
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Bad certificate',
          type: NetworkErrorType.unknown,
          originalError: e,
        );
      case DioExceptionType.unknown:
        return NetworkException(
          message: e.message ?? 'Unknown error',
          type: NetworkErrorType.unknown,
          originalError: e,
        );
    }
  }
}

enum NetworkErrorType {
  noConnection,
  timeout,
  serverError,
  badRequest,
  notFound,
  unknown,
}

/// 인증 관련 예외
class AuthException extends AppException {
  final AuthErrorType type;

  const AuthException({
    required super.message,
    required this.type,
    super.code,
    super.originalError,
  });

  @override
  String get userMessage {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return '이메일 또는 비밀번호가 올바르지 않습니다';
      case AuthErrorType.tokenExpired:
        return '세션이 만료되었습니다. 다시 로그인해주세요';
      case AuthErrorType.unauthorized:
        return '접근 권한이 없습니다';
      case AuthErrorType.emailInUse:
        return '이미 사용 중인 이메일입니다';
      case AuthErrorType.weakPassword:
        return '비밀번호가 너무 약합니다';
      case AuthErrorType.userNotFound:
        return '사용자를 찾을 수 없습니다';
    }
  }

  @override
  bool get isRetryable => false;
}

enum AuthErrorType {
  invalidCredentials,
  tokenExpired,
  unauthorized,
  emailInUse,
  weakPassword,
  userNotFound,
}

/// 검증 관련 예외
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors = const {},
    super.originalError,
  });

  @override
  String get userMessage => message;

  @override
  bool get isRetryable => false;

  String? getFieldError(String field) {
    final errors = fieldErrors[field];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }
}

/// 데이터 관련 예외
class DataException extends AppException {
  final DataErrorType type;

  const DataException({
    required super.message,
    this.type = DataErrorType.unknown,
    super.code,
    super.originalError,
  });

  @override
  String get userMessage {
    switch (type) {
      case DataErrorType.notFound:
        return '데이터를 찾을 수 없습니다';
      case DataErrorType.conflict:
        return '데이터 충돌이 발생했습니다';
      case DataErrorType.syncFailed:
        return '동기화에 실패했습니다';
      case DataErrorType.unknown:
        return '데이터 처리 중 오류가 발생했습니다';
    }
  }

  @override
  bool get isRetryable => type == DataErrorType.syncFailed;
}

enum DataErrorType {
  notFound,
  conflict,
  syncFailed,
  unknown,
}

/// 오프라인 예외
class OfflineException extends AppException {
  const OfflineException({
    super.message = 'Offline',
    super.originalError,
  });

  @override
  String get userMessage => '오프라인 상태입니다. 인터넷 연결을 확인해주세요';

  @override
  bool get isRetryable => true;
}

/// 앱 에러 상태 (UI에서 사용)
class AppError {
  final String message;
  final bool isRetryable;
  final AppException? exception;

  const AppError({
    required this.message,
    this.isRetryable = true,
    this.exception,
  });

  factory AppError.fromException(AppException e) {
    return AppError(
      message: e.userMessage,
      isRetryable: e.isRetryable,
      exception: e,
    );
  }

  factory AppError.unknown([dynamic error]) {
    return AppError(
      message: '알 수 없는 오류가 발생했습니다',
      isRetryable: true,
      exception: error is AppException ? error : null,
    );
  }
}
