import 'package:flutter/material.dart';

enum LoadingSize { small, medium, large }

class LoadingWidget extends StatelessWidget {
  final LoadingSize size;
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.size = LoadingSize.medium,
    this.message,
    this.color,
  });

  const LoadingWidget.small({super.key, this.message, this.color})
      : size = LoadingSize.small;

  const LoadingWidget.large({super.key, this.message, this.color})
      : size = LoadingSize.large;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = switch (size) {
      LoadingSize.small => 16.0,
      LoadingSize.medium => 24.0,
      LoadingSize.large => 40.0,
    };

    final strokeWidth = switch (size) {
      LoadingSize.small => 2.0,
      LoadingSize.medium => 3.0,
      LoadingSize.large => 4.0,
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 전체 화면 로딩
class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget.large(message: message),
    );
  }
}
