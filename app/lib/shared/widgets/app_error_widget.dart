import 'package:flutter/material.dart';

/// 에러 표시 위젯
class AppErrorWidget extends StatelessWidget {
  final String message;
  final bool isRetryable;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.isRetryable = true,
    this.onRetry,
    this.icon,
    this.iconColor,
  });

  /// 네트워크 에러용 팩토리
  factory AppErrorWidget.network({
    Key? key,
    String message = '네트워크 연결을 확인해주세요',
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      key: key,
      message: message,
      isRetryable: true,
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }

  /// 서버 에러용 팩토리
  factory AppErrorWidget.server({
    Key? key,
    String message = '서버에 문제가 발생했습니다',
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      key: key,
      message: message,
      isRetryable: true,
      onRetry: onRetry,
      icon: Icons.cloud_off,
    );
  }

  /// 데이터 없음 표시
  factory AppErrorWidget.empty({
    Key? key,
    String message = '데이터가 없습니다',
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      key: key,
      message: message,
      isRetryable: onRetry != null,
      onRetry: onRetry,
      icon: Icons.inbox_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 48,
              color: iconColor ?? theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isRetryable && onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 인라인 에러 메시지 (카드 내부용)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// 스낵바 형태 에러 표시
void showErrorSnackBar(
  BuildContext context, {
  required String message,
  VoidCallback? onRetry,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: '다시 시도',
              onPressed: onRetry,
            )
          : null,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// 다이얼로그 형태 에러 표시
Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onRetry,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: const Text('다시 시도'),
          ),
      ],
    ),
  );
}
