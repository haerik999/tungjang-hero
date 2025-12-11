// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyBudgetsHash() => r'0c36735e88cc281d841212842f12db06fbdf183c';

/// 현재 월의 예산 목록 스트림
///
/// Copied from [monthlyBudgets].
@ProviderFor(monthlyBudgets)
final monthlyBudgetsProvider =
    AutoDisposeStreamProvider<List<CategoryBudget>>.internal(
  monthlyBudgets,
  name: r'monthlyBudgetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyBudgetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyBudgetsRef = AutoDisposeStreamProviderRef<List<CategoryBudget>>;
String _$budgetManagerHash() => r'11c0ac76f20460a8d1c28ecbe3090392ac701a87';

/// 예산 관리 Provider
///
/// Copied from [BudgetManager].
@ProviderFor(BudgetManager)
final budgetManagerProvider =
    AutoDisposeAsyncNotifierProvider<BudgetManager, void>.internal(
  BudgetManager.new,
  name: r'budgetManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BudgetManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
