import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

part 'budget_provider.g.dart';

/// 현재 월의 예산 목록 스트림
@riverpod
Stream<List<CategoryBudget>> monthlyBudgets(MonthlyBudgetsRef ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  return db.watchBudgetsByMonth(now.year, now.month);
}

/// 예산 관리 Provider
@riverpod
class BudgetManager extends _$BudgetManager {
  @override
  FutureOr<void> build() {}

  /// 예산 설정/수정
  Future<void> setBudget({
    required String category,
    required int amount,
    int? year,
    int? month,
  }) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    // 기존 예산 확인
    final existing = await db.getBudget(category, targetYear, targetMonth);

    if (existing != null) {
      // 업데이트
      await db.updateHeroStats(existing.copyWith(
        amount: amount,
        updatedAt: DateTime.now(),
      ) as HeroStatsTableData);
    } else {
      // 새로 생성
      await db.upsertBudget(CategoryBudgetsCompanion.insert(
        category: category,
        amount: amount,
        year: targetYear,
        month: targetMonth,
      ));
    }

    ref.invalidate(monthlyBudgetsProvider);
  }

  /// 예산 삭제
  Future<void> removeBudget(int budgetId) async {
    final db = ref.read(databaseProvider);
    await db.deleteBudget(budgetId);
    ref.invalidate(monthlyBudgetsProvider);
  }

  /// 카테고리별 예산 정보 조회 (지출 포함)
  Future<BudgetStatus?> getBudgetStatus(String category) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    final budget = await db.getBudget(category, now.year, now.month);
    if (budget == null) return null;

    final spent = await db.getCategorySpentAmount(category, now.year, now.month);
    final remaining = budget.amount - spent;
    final percentage = budget.amount > 0 ? (spent / budget.amount * 100) : 0.0;

    return BudgetStatus(
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      isOverBudget: remaining < 0,
      isWarning: percentage >= 80 && percentage < 100,
    );
  }

  /// 모든 카테고리의 예산 상태 조회
  Future<List<BudgetStatus>> getAllBudgetStatuses() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    final budgets = await db.getBudgetsByMonth(now.year, now.month);
    final statuses = <BudgetStatus>[];

    for (final budget in budgets) {
      final spent =
          await db.getCategorySpentAmount(budget.category, now.year, now.month);
      final remaining = budget.amount - spent;
      final percentage =
          budget.amount > 0 ? (spent / budget.amount * 100) : 0.0;

      statuses.add(BudgetStatus(
        budget: budget,
        spent: spent,
        remaining: remaining,
        percentage: percentage,
        isOverBudget: remaining < 0,
        isWarning: percentage >= 80 && percentage < 100,
      ));
    }

    return statuses;
  }

  /// 총 예산 대비 총 지출 비율
  Future<double> getTotalBudgetProgress() async {
    final statuses = await getAllBudgetStatuses();
    if (statuses.isEmpty) return 0.0;

    final totalBudget =
        statuses.fold<int>(0, (sum, s) => sum + s.budget.amount);
    final totalSpent = statuses.fold<int>(0, (sum, s) => sum + s.spent);

    return totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;
  }
}

/// 예산 상태 정보
class BudgetStatus {
  final CategoryBudget budget;
  final int spent;
  final int remaining;
  final double percentage;
  final bool isOverBudget;
  final bool isWarning;

  BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.isOverBudget,
    required this.isWarning,
  });

  /// 상태 이모지
  String get statusEmoji {
    if (isOverBudget) return '🔴';
    if (isWarning) return '🟡';
    return '🟢';
  }

  /// 상태 텍스트
  String get statusText {
    if (isOverBudget) return '예산 초과';
    if (isWarning) return '예산 주의';
    return '예산 여유';
  }
}

/// 카테고리별 기본 예산 추천
class BudgetRecommendation {
  static Map<String, int> get defaultBudgets => {
        '식비': 300000,
        '교통': 100000,
        '생활': 150000,
        '쇼핑': 100000,
        '문화': 50000,
        '의료': 50000,
        '교육': 100000,
        '기타': 50000,
      };

  static int getRecommendedBudget(String category) {
    return defaultBudgets[category] ?? 100000;
  }
}
