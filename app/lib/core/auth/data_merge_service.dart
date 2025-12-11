import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../network/api_client.dart';
import '../network/sync_service.dart';

part 'data_merge_service.g.dart';

/// 데이터 병합 옵션
enum MergeOption {
  /// 로컬 데이터 유지 (서버로 업로드)
  keepLocal,

  /// 서버 데이터 유지 (로컬 삭제 후 다운로드)
  keepServer,

  /// 양쪽 모두 병합
  mergeBoth,
}

/// 데이터 요약 정보
class DataSummary {
  final int transactionCount;
  final int budgetCount;
  final int categoryCount;
  final int totalAmount;

  const DataSummary({
    this.transactionCount = 0,
    this.budgetCount = 0,
    this.categoryCount = 0,
    this.totalAmount = 0,
  });

  bool get isEmpty =>
      transactionCount == 0 && budgetCount == 0 && categoryCount == 0;

  bool get hasData => !isEmpty;
}

/// 병합 상태
class MergeState {
  final bool isLoading;
  final DataSummary? localData;
  final DataSummary? serverData;
  final String? errorMessage;
  final bool needsMergeDecision;

  const MergeState({
    this.isLoading = false,
    this.localData,
    this.serverData,
    this.errorMessage,
    this.needsMergeDecision = false,
  });

  MergeState copyWith({
    bool? isLoading,
    DataSummary? localData,
    DataSummary? serverData,
    String? errorMessage,
    bool? needsMergeDecision,
  }) {
    return MergeState(
      isLoading: isLoading ?? this.isLoading,
      localData: localData ?? this.localData,
      serverData: serverData ?? this.serverData,
      errorMessage: errorMessage,
      needsMergeDecision: needsMergeDecision ?? this.needsMergeDecision,
    );
  }
}

/// 데이터 병합 서비스 Provider
@Riverpod(keepAlive: true)
class DataMergeService extends _$DataMergeService {
  late AppDatabase _db;
  late ApiClient _apiClient;

  @override
  MergeState build() {
    _db = ref.watch(databaseProvider);
    _apiClient = ref.watch(apiClientProvider);
    return const MergeState();
  }

  /// 로컬 데이터 요약 조회
  Future<DataSummary> getLocalDataSummary() async {
    try {
      final transactions = await _db.getAllTransactions();
      final now = DateTime.now();
      final budgets = await _db.getBudgetsByMonth(now.year, now.month);
      final categories = await _db.getAllCategories();

      // 비기본 카테고리만 카운트
      final customCategories =
          categories.where((c) => !c.isDefault).toList();

      int totalAmount = 0;
      for (final t in transactions) {
        if (!t.isIncome) {
          totalAmount += t.amount;
        }
      }

      return DataSummary(
        transactionCount: transactions.length,
        budgetCount: budgets.length,
        categoryCount: customCategories.length,
        totalAmount: totalAmount,
      );
    } catch (e) {
      return const DataSummary();
    }
  }

  /// 서버 데이터 요약 조회
  Future<DataSummary> getServerDataSummary() async {
    try {
      final response = await _apiClient.getTransactions();
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final transactions = data['transactions'] as List? ?? [];
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        final total = pagination['total'] as int? ?? transactions.length;

        // 지출 합계 계산 (첫 페이지만)
        int totalAmount = 0;
        for (final t in transactions) {
          final map = t as Map<String, dynamic>;
          final isIncome = map['is_income'] as bool? ?? false;
          if (!isIncome) {
            totalAmount += (map['amount'] as int?) ?? 0;
          }
        }

        return DataSummary(
          transactionCount: total,
          budgetCount: 0, // TODO: 서버에서 예산 개수 조회
          categoryCount: 0, // TODO: 서버에서 카테고리 개수 조회
          totalAmount: totalAmount,
        );
      }
      return const DataSummary();
    } catch (e) {
      return const DataSummary();
    }
  }

  /// 로그인 후 병합 필요 여부 확인
  Future<bool> checkMergeNeeded() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final localSummary = await getLocalDataSummary();
      final serverSummary = await getServerDataSummary();

      state = state.copyWith(
        isLoading: false,
        localData: localSummary,
        serverData: serverSummary,
      );

      // 로컬에 데이터가 있고, 서버에도 데이터가 있으면 병합 선택 필요
      if (localSummary.hasData && serverSummary.hasData) {
        state = state.copyWith(needsMergeDecision: true);
        return true;
      }

      // 로컬에만 데이터가 있으면 자동으로 서버에 업로드
      if (localSummary.hasData && !serverSummary.hasData) {
        await executeMerge(MergeOption.keepLocal);
        return false;
      }

      // 서버에만 데이터가 있으면 자동으로 다운로드
      if (!localSummary.hasData && serverSummary.hasData) {
        await executeMerge(MergeOption.keepServer);
        return false;
      }

      // 둘 다 데이터가 없으면 병합 불필요
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '데이터 확인 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  /// 병합 실행
  Future<bool> executeMerge(MergeOption option) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      switch (option) {
        case MergeOption.keepLocal:
          // 로컬 데이터를 서버로 업로드
          await ref.read(syncServiceProvider.notifier).syncAll();
          break;

        case MergeOption.keepServer:
          // 로컬 데이터 삭제 후 서버에서 다운로드
          await _clearLocalData();
          await ref.read(syncServiceProvider.notifier).syncAll();
          break;

        case MergeOption.mergeBoth:
          // 양쪽 데이터 병합 (동기화 실행)
          await ref.read(syncServiceProvider.notifier).syncAll();
          break;
      }

      state = state.copyWith(
        isLoading: false,
        needsMergeDecision: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '데이터 병합 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  /// 로컬 데이터 삭제
  Future<void> _clearLocalData() async {
    // 모든 거래 삭제
    final transactions = await _db.getAllTransactions();
    for (final t in transactions) {
      await _db.hardDeleteTransaction(t.id);
    }

    // 삭제된 거래(tombstone)도 삭제
    final deleted = await _db.getDeletedTransactions();
    for (final t in deleted) {
      await _db.hardDeleteTransaction(t.id);
    }

    // TODO: 예산, 카테고리 삭제
  }

  /// 병합 결정 취소 (병합 없이 진행)
  void cancelMergeDecision() {
    state = state.copyWith(needsMergeDecision: false);
  }

  /// 상태 리셋
  void reset() {
    state = const MergeState();
  }
}

/// 병합 결정 필요 여부 Provider
@riverpod
bool needsMergeDecision(NeedsMergeDecisionRef ref) {
  return ref.watch(dataMergeServiceProvider).needsMergeDecision;
}

/// 로컬 데이터 요약 Provider
@riverpod
DataSummary? localDataSummary(LocalDataSummaryRef ref) {
  return ref.watch(dataMergeServiceProvider).localData;
}

/// 서버 데이터 요약 Provider
@riverpod
DataSummary? serverDataSummary(ServerDataSummaryRef ref) {
  return ref.watch(dataMergeServiceProvider).serverData;
}
