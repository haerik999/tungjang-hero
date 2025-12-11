import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../errors/app_exception.dart';
import 'api_client.dart';
import 'connectivity_provider.dart';

part 'sync_service.g.dart';

/// 동기화 상태
enum SyncStatusType {
  idle,
  syncing,
  success,
  error,
}

/// 동기화 상태 클래스
class SyncState {
  final SyncStatusType status;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final int pendingChanges;
  final int syncedChanges;

  const SyncState({
    this.status = SyncStatusType.idle,
    this.lastSyncTime,
    this.errorMessage,
    this.pendingChanges = 0,
    this.syncedChanges = 0,
  });

  SyncState copyWith({
    SyncStatusType? status,
    DateTime? lastSyncTime,
    String? errorMessage,
    int? pendingChanges,
    int? syncedChanges,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      syncedChanges: syncedChanges ?? this.syncedChanges,
    );
  }

  bool get isSyncing => status == SyncStatusType.syncing;
  bool get hasError => status == SyncStatusType.error;
  bool get hasPendingChanges => pendingChanges > 0;
}

/// 동기화 서비스 Provider
@Riverpod(keepAlive: true)
class SyncService extends _$SyncService {
  late AppDatabase _db;
  late ApiClient _apiClient;

  @override
  SyncState build() {
    _db = ref.watch(databaseProvider);
    _apiClient = ref.watch(apiClientProvider);

    // 네트워크 상태 변경 감지
    ref.listen(networkStatusNotifierProvider, (prev, next) {
      if (prev == NetworkStatus.offline && next == NetworkStatus.online) {
        // 온라인 복귀 시 자동 동기화
        syncAll();
      }
    });

    // 초기 pending 수 확인
    _checkPendingChanges();

    return const SyncState();
  }

  /// pending 변경사항 수 확인
  Future<void> _checkPendingChanges() async {
    final pending = await _db.getPendingTransactions();
    state = state.copyWith(pendingChanges: pending.length);
  }

  /// 전체 동기화 실행
  Future<void> syncAll() async {
    // 이미 동기화 중이면 스킵
    if (state.isSyncing) return;

    // 오프라인이면 스킵
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      state = state.copyWith(
        status: SyncStatusType.error,
        errorMessage: '오프라인 상태입니다',
      );
      return;
    }

    state = state.copyWith(status: SyncStatusType.syncing, errorMessage: null);

    try {
      int synced = 0;

      // 1. 로컬 변경사항 서버로 업로드
      synced += await _uploadPendingTransactions();

      // 2. 서버 데이터 로컬로 다운로드
      await _downloadServerTransactions();

      // 3. pending 수 다시 확인
      await _checkPendingChanges();

      state = state.copyWith(
        status: SyncStatusType.success,
        lastSyncTime: DateTime.now(),
        syncedChanges: synced,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: SyncStatusType.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatusType.error,
        errorMessage: '동기화 중 오류가 발생했습니다',
      );
    }
  }

  /// 로컬 pending 거래를 서버로 업로드
  Future<int> _uploadPendingTransactions() async {
    final pending = await _db.getPendingTransactions();
    int synced = 0;

    for (final transaction in pending) {
      try {
        final response = await _apiClient.createTransaction({
          'title': transaction.title,
          'amount': transaction.amount,
          'is_income': transaction.isIncome,
          'category': transaction.category,
          'note': transaction.note,
          'created_at': transaction.createdAt.toIso8601String(),
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data as Map<String, dynamic>;
          final serverId = data['id'] as int? ?? data['transaction']?['id'] as int?;

          if (serverId != null) {
            await _db.markTransactionSynced(transaction.id, serverId);
            synced++;
          }
        }
      } on DioException catch (e) {
        // 409 Conflict - 서버에 이미 존재
        if (e.response?.statusCode == 409) {
          await _db.markTransactionConflict(transaction.id);
        }
        // 다른 에러는 다음 동기화 시 재시도
      }
    }

    return synced;
  }

  /// 서버에서 거래 데이터 다운로드
  Future<void> _downloadServerTransactions() async {
    try {
      final now = DateTime.now();
      final response = await _apiClient.getTransactions(
        year: now.year,
        month: now.month,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final serverTransactions = data['transactions'] as List? ?? [];

        for (final item in serverTransactions) {
          final map = item as Map<String, dynamic>;

          await _db.upsertTransactionFromServer(
            serverId: map['id'] as int,
            title: map['title'] as String,
            amount: map['amount'] as int,
            isIncome: map['is_income'] as bool? ?? false,
            category: map['category'] as String,
            note: map['note'] as String?,
            createdAt: DateTime.parse(map['created_at'] as String),
            updatedAt: DateTime.parse(
              map['updated_at'] as String? ?? map['created_at'] as String,
            ),
          );
        }
      }
    } catch (e) {
      // 다운로드 실패는 무시 (다음 동기화 시 재시도)
    }
  }

  /// 특정 거래만 동기화
  Future<bool> syncTransaction(int localId) async {
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) return false;

    final transactions = await _db.getAllTransactions();
    final transaction = transactions.where((t) => t.id == localId).firstOrNull;
    if (transaction == null) return false;

    try {
      final response = await _apiClient.createTransaction({
        'title': transaction.title,
        'amount': transaction.amount,
        'is_income': transaction.isIncome,
        'category': transaction.category,
        'note': transaction.note,
        'created_at': transaction.createdAt.toIso8601String(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final serverId = data['id'] as int? ?? data['transaction']?['id'] as int?;

        if (serverId != null) {
          await _db.markTransactionSynced(localId, serverId);
          await _checkPendingChanges();
          return true;
        }
      }
    } catch (e) {
      // 실패
    }

    return false;
  }

  /// 충돌 해결 (로컬 우선)
  Future<void> resolveConflictKeepLocal(int localId) async {
    final transactions = await _db.getAllTransactions();
    final transaction = transactions.where((t) => t.id == localId).firstOrNull;
    if (transaction == null) return;

    // 서버에 강제 업데이트 요청
    if (transaction.serverId != null) {
      try {
        await _apiClient.updateTransaction(transaction.serverId!, {
          'title': transaction.title,
          'amount': transaction.amount,
          'is_income': transaction.isIncome,
          'category': transaction.category,
          'note': transaction.note,
        });
        await _db.markTransactionSynced(localId, transaction.serverId!);
      } catch (e) {
        // 실패
      }
    }

    await _checkPendingChanges();
  }

  /// 충돌 해결 (서버 우선)
  Future<void> resolveConflictKeepServer(int localId) async {
    final transactions = await _db.getAllTransactions();
    final transaction = transactions.where((t) => t.id == localId).firstOrNull;
    if (transaction?.serverId == null) return;

    try {
      final response = await _apiClient.getTransaction(transaction!.serverId!);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final serverData = data['transaction'] as Map<String, dynamic>? ?? data;

        await _db.upsertTransactionFromServer(
          serverId: serverData['id'] as int,
          title: serverData['title'] as String,
          amount: serverData['amount'] as int,
          isIncome: serverData['is_income'] as bool? ?? false,
          category: serverData['category'] as String,
          note: serverData['note'] as String?,
          createdAt: DateTime.parse(serverData['created_at'] as String),
          updatedAt: DateTime.parse(
            serverData['updated_at'] as String? ?? serverData['created_at'] as String,
          ),
        );
      }
    } catch (e) {
      // 실패
    }

    await _checkPendingChanges();
  }
}

/// 동기화 상태 요약 Provider
@riverpod
({bool hasPending, int pendingCount, DateTime? lastSync}) syncSummary(
  SyncSummaryRef ref,
) {
  final syncState = ref.watch(syncServiceProvider);
  return (
    hasPending: syncState.hasPendingChanges,
    pendingCount: syncState.pendingChanges,
    lastSync: syncState.lastSyncTime,
  );
}
