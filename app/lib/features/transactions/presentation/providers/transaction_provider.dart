import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../hero/presentation/providers/hero_provider.dart';
import '../../../quests/presentation/providers/quest_provider.dart';

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

  /// 거래 추가 및 레벨업 결과 반환 (구버전 - 하위호환용)
  Future<LevelUpResult?> addTransaction({
    required String title,
    required int amount,
    required bool isIncome,
    required String category,
    String? note,
  }) async {
    final db = ref.read(databaseProvider);

    // 거래 추가
    await db.insertTransaction(
      TransactionsCompanion.insert(
        title: title,
        amount: amount,
        isIncome: Value(isIncome),
        category: category,
        note: Value(note),
      ),
    );

    // 히어로 스탯 업데이트 및 레벨업 결과 받기 (구버전)
    final levelUpResult = await ref.read(heroManagerProvider.notifier).processTransactionLegacy(
          amount: amount,
          isIncome: isIncome,
        );

    // 퀘스트 진행도 업데이트
    await ref.read(questManagerProvider.notifier).updateQuestProgress(
          amount: amount,
          isIncome: isIncome,
        );

    // 관련 프로바이더 새로고침
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(todayTransactionsProvider);
    ref.invalidate(monthlyStatsProvider);
    ref.invalidate(todayStatsProvider);

    return levelUpResult;
  }

  /// 예산 기반 거래 추가 (새 시스템)
  Future<TransactionResult> addTransactionWithBudget({
    required String title,
    required int amount,
    required bool isIncome,
    required String category,
    String? note,
    DateTime? date,
  }) async {
    final db = ref.read(databaseProvider);

    // 거래 추가
    await db.insertTransaction(
      TransactionsCompanion.insert(
        title: title,
        amount: amount,
        isIncome: Value(isIncome),
        category: category,
        note: Value(note),
        createdAt: Value(date ?? DateTime.now()),
      ),
    );

    // 예산 기반 히어로 스탯 업데이트
    final result = await ref.read(heroManagerProvider.notifier).processTransaction(
          amount: amount,
          isIncome: isIncome,
          category: category,
        );

    // 퀘스트 진행도 업데이트
    await ref.read(questManagerProvider.notifier).updateQuestProgress(
          amount: amount,
          isIncome: isIncome,
        );

    // 관련 프로바이더 새로고침
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(todayTransactionsProvider);
    ref.invalidate(monthlyStatsProvider);
    ref.invalidate(todayStatsProvider);

    return result;
  }

  Future<void> deleteTransaction(int id) async {
    final db = ref.read(databaseProvider);
    await db.deleteTransaction(id);

    ref.invalidate(allTransactionsProvider);
    ref.invalidate(todayTransactionsProvider);
    ref.invalidate(monthlyStatsProvider);
    ref.invalidate(todayStatsProvider);
  }
}
