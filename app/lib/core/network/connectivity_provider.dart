import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// 네트워크 상태 enum
enum NetworkStatus {
  online,
  offline,
  unknown,
}

/// 네트워크 상태 관리 Notifier
@Riverpod(keepAlive: true)
class NetworkStatusNotifier extends _$NetworkStatusNotifier {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Connectivity _connectivity = Connectivity();

  @override
  NetworkStatus build() {
    // 연결 상태 변화 구독
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);

    // 리소스 정리
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // 초기 상태 확인
    _checkInitialStatus();

    return NetworkStatus.unknown;
  }

  /// 초기 연결 상태 확인
  Future<void> _checkInitialStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      state = NetworkStatus.unknown;
    }
  }

  /// 연결 상태 업데이트
  void _updateStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      state = NetworkStatus.offline;
    } else {
      state = NetworkStatus.online;
    }
  }

  /// 수동으로 연결 상태 확인
  Future<void> checkStatus() async {
    await _checkInitialStatus();
  }

  /// 현재 온라인 상태인지 확인
  bool get isOnline => state == NetworkStatus.online;

  /// 현재 오프라인 상태인지 확인
  bool get isOffline => state == NetworkStatus.offline;
}

/// 온라인 상태 여부 Provider (편의용)
@riverpod
bool isOnline(IsOnlineRef ref) {
  final status = ref.watch(networkStatusNotifierProvider);
  return status == NetworkStatus.online;
}

/// 오프라인 상태 여부 Provider (편의용)
@riverpod
bool isOffline(IsOfflineRef ref) {
  final status = ref.watch(networkStatusNotifierProvider);
  return status == NetworkStatus.offline;
}

/// 네트워크 상태 스트림 Provider
@riverpod
Stream<NetworkStatus> networkStatusStream(NetworkStatusStreamRef ref) async* {
  final connectivity = Connectivity();

  // 초기 상태
  final initial = await connectivity.checkConnectivity();
  yield _resultToStatus(initial);

  // 변화 감지
  await for (final results in connectivity.onConnectivityChanged) {
    yield _resultToStatus(results);
  }
}

NetworkStatus _resultToStatus(List<ConnectivityResult> results) {
  if (results.isEmpty || results.contains(ConnectivityResult.none)) {
    return NetworkStatus.offline;
  }
  return NetworkStatus.online;
}
