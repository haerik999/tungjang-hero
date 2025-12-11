import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/loading/loading_widget.dart';

/// AsyncValue UI 확장
extension AsyncValueUI<T> on AsyncValue<T> {
  /// 스켈레톤 로딩과 함께 사용
  Widget whenOrSkeleton({
    required Widget Function(T data) data,
    required Widget skeleton,
    Widget Function(Object error, StackTrace stack)? error,
    VoidCallback? onRetry,
  }) {
    return when(
      data: data,
      loading: () => skeleton,
      error: (e, stack) =>
          error?.call(e, stack) ??
          AppErrorWidget(
            message: _getErrorMessage(e),
            onRetry: onRetry,
          ),
    );
  }

  /// 메시지 로딩과 함께 사용
  Widget whenOrLoading({
    required Widget Function(T data) data,
    String? loadingMessage,
    Widget Function(Object error, StackTrace stack)? error,
    VoidCallback? onRetry,
  }) {
    return when(
      data: data,
      loading: () => LoadingWidget(message: loadingMessage),
      error: (e, stack) =>
          error?.call(e, stack) ??
          AppErrorWidget(
            message: _getErrorMessage(e),
            onRetry: onRetry,
          ),
    );
  }

  /// 커스텀 로딩 위젯과 함께 사용
  Widget whenOrCustom({
    required Widget Function(T data) data,
    required Widget loading,
    required Widget Function(Object error, StackTrace stack) error,
  }) {
    return when(
      data: data,
      loading: () => loading,
      error: error,
    );
  }

  /// 에러 메시지 추출
  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

/// AsyncValue 리스트 확장
extension AsyncValueListUI<T> on AsyncValue<List<T>> {
  /// 빈 상태 처리 포함
  Widget whenOrEmpty({
    required Widget Function(List<T> data) data,
    required Widget skeleton,
    required Widget emptyWidget,
    Widget Function(Object error, StackTrace stack)? error,
    VoidCallback? onRetry,
  }) {
    return when(
      data: (list) {
        if (list.isEmpty) {
          return emptyWidget;
        }
        return data(list);
      },
      loading: () => skeleton,
      error: (e, stack) =>
          error?.call(e, stack) ??
          AppErrorWidget(
            message: e.toString(),
            onRetry: onRetry,
          ),
    );
  }
}

/// Nullable AsyncValue 확장
extension AsyncValueNullableUI<T> on AsyncValue<T?> {
  /// null 상태 처리 포함
  Widget whenOrNull({
    required Widget Function(T data) data,
    required Widget skeleton,
    required Widget nullWidget,
    Widget Function(Object error, StackTrace stack)? error,
    VoidCallback? onRetry,
  }) {
    return when(
      data: (value) {
        if (value == null) {
          return nullWidget;
        }
        return data(value);
      },
      loading: () => skeleton,
      error: (e, stack) =>
          error?.call(e, stack) ??
          AppErrorWidget(
            message: e.toString(),
            onRetry: onRetry,
          ),
    );
  }
}
