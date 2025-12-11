import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

part 'transaction_provider.g.dart';

/// 모든 거래 내역 스트림
@riverpod
Stream<List<Transaction>> allTransactions(AllTransactionsRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions();
}

/// 오늘 거래 내역 스트림
@riverpod
Stream<List<Transaction>> todayTransactions(TodayTransactionsRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTodayTransactions();
}

/// 월별 거래 내역 스트림
@riverpod
Stream<List<Transaction>> monthlyTransactions(
  MonthlyTransactionsRef ref, {
  required int year,
  required int month,
}) {
  final db = ref.watch(databaseProvider);
  return db.watchTransactionsByMonth(year, month);
}

/// 현재 선택된 월
@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  DateTime build() => DateTime.now();

  void setMonth(int year, int month) {
    state = DateTime(year, month);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }
}

/// 월별 통계
@riverpod
class MonthlyStats extends _$MonthlyStats {
  @override
  Future<({int income, int expense, int balance})> build() async {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactions = await ref.watch(
      monthlyTransactionsProvider(
        year: selectedMonth.year,
        month: selectedMonth.month,
      ).future,
    );

    int income = 0;
    int expense = 0;

    for (final t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return (income: income, expense: expense, balance: income - expense);
  }
}

/// 오늘 통계
@riverpod
class TodayStats extends _$TodayStats {
  @override
  Future<({int income, int expense, int balance})> build() async {
    final transactions = await ref.watch(todayTransactionsProvider.future);

    int income = 0;
    int expense = 0;

    for (final t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return (income: income, expense: expense, balance: income - expense);
  }
}

/// 거래 추가/수정/삭제 관리
@riverpod
class TransactionManager extends _$TransactionManager {
  @override
  FutureOr<void> build() {}

  /// 거래 추가
  ///
  /// 게임 보상은 동기화 시점에 서버에서 처리됩니다.
  /// 오프라인에서 추가된 거래는 syncStatus='pending'으로 저장됩니다.
  Future<int> addTransaction({
    required String title,
    required int amount,
    required bool isIncome,
    required String category,
    String? note,
    DateTime? transactionDate,
    String? receiptImagePath,
  }) async {
    final db = ref.read(databaseProvider);
    final deviceId = ref.read(deviceIdProvider);

    // 거래 추가 (pending 상태로)
    final id = await db.insertTransaction(
      TransactionsCompanion.insert(
        title: title,
        amount: amount,
        isIncome: Value(isIncome),
        category: category,
        note: Value(note),
        transactionDate: Value(transactionDate ?? DateTime.now()),
        deviceId: deviceId,
        receiptImagePath: Value(receiptImagePath),
        receiptOcrStatus: Value(
          receiptImagePath != null ? ReceiptOcrStatus.pending : ReceiptOcrStatus.none,
        ),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );

    // 관련 프로바이더 새로고침
    _invalidateAll();

    return id;
  }

  /// 거래 수정
  Future<void> updateTransaction({
    required int id,
    required String title,
    required int amount,
    required bool isIncome,
    required String category,
    String? note,
    DateTime? transactionDate,
    String? receiptImagePath,
  }) async {
    final db = ref.read(databaseProvider);
    final deviceId = ref.read(deviceIdProvider);

    // 기존 거래 조회
    final existing = await (db.select(db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existing == null) return;

    // 수정된 거래 저장
    await db.updateTransaction(
      existing.copyWith(
        title: title,
        amount: amount,
        isIncome: isIncome,
        category: category,
        note: Value(note),
        transactionDate: transactionDate ?? existing.transactionDate,
        receiptImagePath: Value(receiptImagePath),
        receiptOcrStatus: receiptImagePath != null
            ? ReceiptOcrStatus.pending
            : ReceiptOcrStatus.none,
        deviceId: deviceId,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      ),
    );

    _invalidateAll();
  }

  /// 거래 삭제 (soft delete)
  Future<void> deleteTransaction(int id) async {
    final db = ref.read(databaseProvider);
    await db.softDeleteTransaction(id);
    _invalidateAll();
  }

  /// 거래 영구 삭제 (tombstone 정리용)
  Future<void> hardDeleteTransaction(int id) async {
    final db = ref.read(databaseProvider);
    await db.hardDeleteTransaction(id);
    _invalidateAll();
  }

  void _invalidateAll() {
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(todayTransactionsProvider);
    ref.invalidate(monthlyStatsProvider);
    ref.invalidate(todayStatsProvider);
  }
}

/// 동기화 대기 중인 거래 Provider
@riverpod
Future<List<Transaction>> pendingTransactions(PendingTransactionsRef ref) {
  final db = ref.watch(databaseProvider);
  return db.getPendingTransactions();
}

/// 카테고리 목록 Provider
@riverpod
Stream<List<Category>> categories(CategoriesRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllCategories();
}
