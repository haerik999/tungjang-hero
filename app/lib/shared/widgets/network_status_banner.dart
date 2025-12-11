import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_provider.dart';

/// 네트워크 상태 배너 위젯
/// 오프라인 시 화면 상단에 표시됨
class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusNotifierProvider);

    // 온라인이면 표시 안함
    if (status == NetworkStatus.online) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: status == NetworkStatus.offline
            ? Colors.orange.shade700
            : Colors.grey.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == NetworkStatus.offline ? Icons.wifi_off : Icons.sync,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              status == NetworkStatus.offline
                  ? '오프라인 모드 - 데이터가 로컬에 저장됩니다'
                  : '연결 확인 중...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -1, end: 0);
  }
}

/// 네트워크 상태를 감싸는 래퍼 위젯
/// Scaffold body에서 사용
class NetworkAwareScaffold extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const NetworkAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: Column(
        children: [
          const NetworkStatusBanner(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// 동기화 상태 인디케이터
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? '동기화됨' : '오프라인',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isOnline ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 네트워크 상태 아이콘 (앱바 액션용)
class NetworkStatusIcon extends ConsumerWidget {
  const NetworkStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusNotifierProvider);

    return IconButton(
      onPressed: () {
        _showNetworkStatusDialog(context, status);
      },
      icon: Icon(
        status == NetworkStatus.online ? Icons.cloud_done : Icons.cloud_off,
        color: status == NetworkStatus.online
            ? Colors.green
            : status == NetworkStatus.offline
                ? Colors.orange
                : Colors.grey,
      ),
      tooltip: status == NetworkStatus.online
          ? '온라인'
          : status == NetworkStatus.offline
              ? '오프라인'
              : '연결 확인 중',
    );
  }

  void _showNetworkStatusDialog(BuildContext context, NetworkStatus status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              status == NetworkStatus.online ? Icons.cloud_done : Icons.cloud_off,
              color: status == NetworkStatus.online ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(status == NetworkStatus.online ? '온라인' : '오프라인'),
          ],
        ),
        content: Text(
          status == NetworkStatus.online
              ? '서버와 연결되어 있습니다. 모든 데이터가 자동으로 동기화됩니다.'
              : '인터넷에 연결되어 있지 않습니다. 데이터는 로컬에 저장되며, 온라인 복귀 시 자동으로 동기화됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
