import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_state_service.dart';
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

/// 동기화 결과 상세
class SyncResult {
  final int uploaded;
  final int downloaded;
  final int conflicts;
  final int failed;
  final List<String> errors;

  const SyncResult({
    this.uploaded = 0,
    this.downloaded = 0,
    this.conflicts = 0,
    this.failed = 0,
    this.errors = const [],
  });

  SyncResult copyWith({
    int? uploaded,
    int? downloaded,
    int? conflicts,
    int? failed,
    List<String>? errors,
  }) {
    return SyncResult(
      uploaded: uploaded ?? this.uploaded,
      downloaded: downloaded ?? this.downloaded,
      conflicts: conflicts ?? this.conflicts,
      failed: failed ?? this.failed,
      errors: errors ?? this.errors,
    );
  }

  int get total => uploaded + downloaded;
  bool get hasErrors => errors.isNotEmpty;
}

/// 동기화 상태 클래스
class SyncState {
  final SyncStatusType status;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final int pendingChanges;
  final SyncResult? lastResult;
  final double progress;

  const SyncState({
    this.status = SyncStatusType.idle,
    this.lastSyncTime,
    this.errorMessage,
    this.pendingChanges = 0,
    this.lastResult,
    this.progress = 0.0,
  });

  SyncState copyWith({
    SyncStatusType? status,
    DateTime? lastSyncTime,
    String? errorMessage,
    int? pendingChanges,
    SyncResult? lastResult,
    double? progress,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      lastResult: lastResult ?? this.lastResult,
      progress: progress ?? this.progress,
    );
  }

  bool get isSyncing => status == SyncStatusType.syncing;
  bool get hasError => status == SyncStatusType.error;
  bool get hasPendingChanges => pendingChanges > 0;
}

/// 동기화 설정
class SyncConfig {
  /// 배치 크기
  static const int batchSize = 100;

  /// 최대 재시도 횟수
  static const int maxRetries = 10;

  /// 기본 재시도 대기 시간 (밀리초)
  static const int baseRetryDelayMs = 1000;

  /// 최대 재시도 대기 시간 (밀리초)
  static const int maxRetryDelayMs = 30000;
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
        // 온라인 복귀 시 자동 동기화 (로그인 상태일 때만)
        final canSync = ref.read(canSyncProvider);
        if (canSync) {
          syncAll();
        }
      }
    });

    // 초기 pending 수 확인
    _checkPendingChanges();

    return const SyncState();
  }

  /// pending 변경사항 수 확인
  Future<void> _checkPendingChanges() async {
    try {
      final pendingTransactions = await _db.getPendingTransactions();
      final pendingBudgets = await _db.getPendingBudgets();
      state = state.copyWith(
        pendingChanges: pendingTransactions.length + pendingBudgets.length,
      );
    } catch (e) {
      // 무시
    }
  }

  /// 전체 동기화 실행
  Future<SyncResult> syncAll() async {
    // 이미 동기화 중이면 스킵
    if (state.isSyncing) {
      return const SyncResult();
    }

    // 로그인 상태 확인
    final canSync = ref.read(canSyncProvider);
    if (!canSync) {
      state = state.copyWith(
        status: SyncStatusType.error,
        errorMessage: '로그인이 필요합니다',
      );
      return const SyncResult();
    }

    // 오프라인이면 스킵
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      state = state.copyWith(
        status: SyncStatusType.error,
        errorMessage: '오프라인 상태입니다',
      );
      return const SyncResult();
    }

    state = state.copyWith(
      status: SyncStatusType.syncing,
      errorMessage: null,
      progress: 0.0,
    );

    var result = const SyncResult();
    final errors = <String>[];

    try {
      // 1. 거래 업로드 (30%)
      state = state.copyWith(progress: 0.1);
      final uploadResult = await _uploadPendingTransactions();
      result = result.copyWith(
        uploaded: uploadResult.uploaded,
        failed: uploadResult.failed,
        errors: [...result.errors, ...uploadResult.errors],
      );

      // 2. 예산 업로드 (50%)
      state = state.copyWith(progress: 0.3);
      await _uploadPendingBudgets();

      // 3. 삭제된 데이터 동기화 (60%)
      state = state.copyWith(progress: 0.5);
      await _syncDeletedRecords();

      // 4. 서버에서 거래 다운로드 (80%)
      state = state.copyWith(progress: 0.6);
      final downloadResult = await _downloadServerTransactions();
      result = result.copyWith(
        downloaded: downloadResult.downloaded,
        conflicts: downloadResult.conflicts,
      );

      // 5. 서버에서 예산 다운로드 (90%)
      state = state.copyWith(progress: 0.8);
      await _downloadServerBudgets();

      // 6. pending 수 확인 (100%)
      state = state.copyWith(progress: 0.9);
      await _checkPendingChanges();

      state = state.copyWith(
        status: SyncStatusType.success,
        lastSyncTime: DateTime.now(),
        lastResult: result,
        progress: 1.0,
      );

      // 마지막 동기화 시간 저장
      await _db.updateLastSyncTime(DateTime.now());

      return result;
    } on AppException catch (e) {
      errors.add(e.userMessage);
      state = state.copyWith(
        status: SyncStatusType.error,
        errorMessage: e.userMessage,
        lastResult: result.copyWith(errors: errors),
      );
      return result.copyWith(errors: errors);
    } catch (e) {
      errors.add('동기화 중 오류가 발생했습니다');
      state = state.copyWith(
        status: SyncStatusType.error,
        errorMessage: '동기화 중 오류가 발생했습니다',
        lastResult: result.copyWith(errors: errors),
      );
      return result.copyWith(errors: errors);
    }
  }

  /// 로컬 pending 거래를 서버로 업로드 (배치 처리)
  Future<({int uploaded, int failed, List<String> errors})> _uploadPendingTransactions() async {
    final pending = await _db.getPendingTransactions();
    int uploaded = 0;
    int failed = 0;
    final errors = <String>[];

    // 배치로 나누어 처리
    for (var i = 0; i < pending.length; i += SyncConfig.batchSize) {
      final batch = pending.skip(i).take(SyncConfig.batchSize).toList();

      for (final transaction in batch) {
        try {
          final success = await _uploadTransactionWithRetry(transaction);
          if (success) {
            uploaded++;
          } else {
            failed++;
          }
        } catch (e) {
          failed++;
          errors.add('거래 #${transaction.id} 업로드 실패');
        }
      }
    }

    return (uploaded: uploaded, failed: failed, errors: errors);
  }

  /// 단일 거래 업로드 (재시도 포함)
  Future<bool> _uploadTransactionWithRetry(Transaction transaction) async {
    for (var attempt = 0; attempt < SyncConfig.maxRetries; attempt++) {
      try {
        // 삭제된 거래인 경우
        if (transaction.deletedAt != null) {
          if (transaction.serverId != null) {
            await _apiClient.deleteTransaction(transaction.serverId!);
            await _db.hardDeleteTransaction(transaction.id);
          }
          return true;
        }

        // 새 거래 또는 수정된 거래
        final Map<String, dynamic> payload = {
          'title': transaction.title,
          'amount': transaction.amount,
          'is_income': transaction.isIncome,
          'category': transaction.category,
          'note': transaction.note,
          'device_id': transaction.deviceId,
          'transaction_date': transaction.transactionDate.toIso8601String(),
          'created_at': transaction.createdAt.toIso8601String(),
          'updated_at': transaction.updatedAt.toIso8601String(),
        };

        Response response;
        if (transaction.serverId != null) {
          // 업데이트
          response = await _apiClient.updateTransaction(
            transaction.serverId!,
            payload,
          );
        } else {
          // 새로 생성
          response = await _apiClient.createTransaction(payload);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data as Map<String, dynamic>;
          final serverId = data['id'] as int? ??
              data['transaction']?['id'] as int? ??
              transaction.serverId;

          if (serverId != null) {
            await _db.markTransactionSynced(transaction.id, serverId);
            return true;
          }
        }

        // 409 Conflict - LWW로 해결
        if (response.statusCode == 409) {
          await _resolveConflictLWW(transaction, response.data);
          return true;
        }

        return false;
      } on DioException catch (e) {
        // 네트워크 에러면 재시도
        if (_isRetryableError(e)) {
          await _waitForRetry(attempt);
          continue;
        }
        return false;
      }
    }
    return false;
  }

  /// LWW (Last-Write-Wins) 충돌 해결
  Future<void> _resolveConflictLWW(
    Transaction local,
    Map<String, dynamic>? serverData,
  ) async {
    if (serverData == null) return;

    final serverUpdatedAt = DateTime.tryParse(
      serverData['updated_at'] as String? ?? '',
    );

    if (serverUpdatedAt == null) return;

    // 로컬이 더 최신이면 서버에 강제 업데이트
    if (local.updatedAt.isAfter(serverUpdatedAt)) {
      if (local.serverId != null) {
        await _apiClient.updateTransaction(local.serverId!, {
          'title': local.title,
          'amount': local.amount,
          'is_income': local.isIncome,
          'category': local.category,
          'note': local.note,
          'device_id': local.deviceId,
          'transaction_date': local.transactionDate.toIso8601String(),
          'updated_at': local.updatedAt.toIso8601String(),
          'force': true, // 서버에서 강제 업데이트 플래그
        });
      }
    } else {
      // 서버가 더 최신이면 로컬 업데이트
      final serverId = serverData['id'] as int;
      await _db.upsertTransactionFromServer(
        serverId: serverId,
        title: serverData['title'] as String,
        amount: serverData['amount'] as int,
        isIncome: serverData['is_income'] as bool? ?? false,
        category: serverData['category'] as String,
        deviceId: serverData['device_id'] as String? ?? 'server',
        note: serverData['note'] as String?,
        transactionDate: DateTime.tryParse(
              serverData['transaction_date'] as String? ?? '',
            ) ??
            DateTime.now(),
        createdAt: DateTime.parse(serverData['created_at'] as String),
        updatedAt: serverUpdatedAt,
      );
    }
  }

  /// 삭제된 레코드 동기화 (Tombstone)
  Future<void> _syncDeletedRecords() async {
    try {
      final deletedTransactions = await _db.getDeletedTransactions();

      for (final transaction in deletedTransactions) {
        if (transaction.serverId != null) {
          try {
            await _apiClient.deleteTransaction(transaction.serverId!);
          } catch (e) {
            // 이미 삭제되었거나 없는 경우 무시
          }
        }
        // 30일 이상 된 tombstone은 물리 삭제
        if (transaction.deletedAt != null &&
            DateTime.now().difference(transaction.deletedAt!).inDays > 30) {
          await _db.hardDeleteTransaction(transaction.id);
        }
      }
    } catch (e) {
      // 무시
    }
  }

  /// 예산 업로드
  Future<void> _uploadPendingBudgets() async {
    try {
      final pendingBudgets = await _db.getPendingBudgets();

      for (final budget in pendingBudgets) {
        try {
          if (budget.deletedAt != null) {
            // 삭제된 예산 처리
            // TODO: 서버 API 구현 후 연동
            continue;
          }

          final response = await _apiClient.createBudget({
            'category': budget.category,
            'amount': budget.amount,
            'year': budget.year,
            'month': budget.month,
            'device_id': budget.deviceId,
          });

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = response.data as Map<String, dynamic>;
            final serverId = data['id'] as int?;
            if (serverId != null) {
              await _db.markBudgetSynced(budget.id, serverId);
            }
          }
        } catch (e) {
          // 개별 실패는 무시
        }
      }
    } catch (e) {
      // 무시
    }
  }

  /// 서버에서 거래 다운로드
  Future<({int downloaded, int conflicts})> _downloadServerTransactions() async {
    int downloaded = 0;
    int conflicts = 0;

    try {
      // TODO: 마지막 동기화 시간 이후 변경분만 가져오기 (서버 since 파라미터 지원 시)
      // final lastSync = await _db.getLastSyncTime();
      final response = await _apiClient.getTransactions();

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final serverTransactions = data['transactions'] as List? ?? [];

        for (final item in serverTransactions) {
          final map = item as Map<String, dynamic>;
          final serverId = map['id'] as int;
          final serverUpdatedAt = DateTime.parse(
            map['updated_at'] as String? ?? map['created_at'] as String,
          );

          // 로컬에 같은 serverId가 있는지 확인
          final localTransaction = await _db.getTransactionByServerId(serverId);

          if (localTransaction != null) {
            // LWW: 서버가 더 최신이면 업데이트
            if (serverUpdatedAt.isAfter(localTransaction.updatedAt)) {
              await _updateLocalFromServer(map);
              downloaded++;
            } else if (localTransaction.updatedAt.isAfter(serverUpdatedAt)) {
              conflicts++;
            }
          } else {
            // 새 레코드
            await _updateLocalFromServer(map);
            downloaded++;
          }
        }
      }
    } catch (e) {
      // 다운로드 실패는 무시
    }

    return (downloaded: downloaded, conflicts: conflicts);
  }

  /// 서버 데이터로 로컬 업데이트
  Future<void> _updateLocalFromServer(Map<String, dynamic> serverData) async {
    final createdAt = DateTime.parse(serverData['created_at'] as String);
    final updatedAt = DateTime.parse(
      serverData['updated_at'] as String? ?? serverData['created_at'] as String,
    );

    // 삭제된 레코드인 경우
    if (serverData['deleted_at'] != null) {
      final serverId = serverData['id'] as int;
      final local = await _db.getTransactionByServerId(serverId);
      if (local != null) {
        await _db.softDeleteTransaction(local.id);
      }
      return;
    }

    await _db.upsertTransactionFromServer(
      serverId: serverData['id'] as int,
      title: serverData['title'] as String,
      amount: serverData['amount'] as int,
      isIncome: serverData['is_income'] as bool? ?? false,
      category: serverData['category'] as String,
      deviceId: serverData['device_id'] as String? ?? 'server',
      note: serverData['note'] as String?,
      transactionDate: DateTime.tryParse(
            serverData['transaction_date'] as String? ?? '',
          ) ??
          createdAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 서버에서 예산 다운로드
  Future<void> _downloadServerBudgets() async {
    try {
      final now = DateTime.now();
      final response = await _apiClient.getBudget(
        year: now.year,
        month: now.month,
      );

      if (response.statusCode == 200) {
        // TODO: 서버 응답 구조에 맞게 구현
      }
    } catch (e) {
      // 무시
    }
  }

  /// 재시도 가능한 에러인지 확인
  bool _isRetryableError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response?.statusCode ?? 0) >= 500;
  }

  /// 지수 백오프로 재시도 대기
  Future<void> _waitForRetry(int attempt) async {
    final delay = min(
      SyncConfig.baseRetryDelayMs * pow(2, attempt).toInt(),
      SyncConfig.maxRetryDelayMs,
    );
    // 약간의 랜덤 지터 추가
    final jitter = Random().nextInt(delay ~/ 4);
    await Future.delayed(Duration(milliseconds: delay + jitter));
  }

  /// 수동 동기화 요청
  Future<SyncResult> manualSync() async {
    return syncAll();
  }

  /// 특정 거래만 동기화
  Future<bool> syncTransaction(int localId) async {
    final canSync = ref.read(canSyncProvider);
    if (!canSync) return false;

    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) return false;

    final transaction = await _db.getTransactionById(localId);
    if (transaction == null) return false;

    final success = await _uploadTransactionWithRetry(transaction);
    if (success) {
      await _checkPendingChanges();
    }
    return success;
  }
}

/// 동기화 상태 요약 Provider
@riverpod
({bool hasPending, int pendingCount, DateTime? lastSync, bool isSyncing}) syncSummary(
  SyncSummaryRef ref,
) {
  final syncState = ref.watch(syncServiceProvider);
  return (
    hasPending: syncState.hasPendingChanges,
    pendingCount: syncState.pendingChanges,
    lastSync: syncState.lastSyncTime,
    isSyncing: syncState.isSyncing,
  );
}

/// 동기화 진행률 Provider
@riverpod
double syncProgress(SyncProgressRef ref) {
  final syncState = ref.watch(syncServiceProvider);
  return syncState.progress;
}
