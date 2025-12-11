// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allTransactionsHash() => r'75e8f00f0efd686ae43ff631bd55488ab91de04e';

/// 모든 거래 내역 스트림
///
/// Copied from [allTransactions].
@ProviderFor(allTransactions)
final allTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
  allTransactions,
  name: r'allTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllTransactionsRef = AutoDisposeStreamProviderRef<List<Transaction>>;
String _$todayTransactionsHash() => r'0d5f964e1d0cd76e5e0251eb7e9641747377e57a';

/// 오늘 거래 내역 스트림
///
/// Copied from [todayTransactions].
@ProviderFor(todayTransactions)
final todayTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
  todayTransactions,
  name: r'todayTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayTransactionsRef = AutoDisposeStreamProviderRef<List<Transaction>>;
String _$monthlyTransactionsHash() =>
    r'4525197c9cdeeaece041f159b10814a264aced0d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 월별 거래 내역 스트림
///
/// Copied from [monthlyTransactions].
@ProviderFor(monthlyTransactions)
const monthlyTransactionsProvider = MonthlyTransactionsFamily();

/// 월별 거래 내역 스트림
///
/// Copied from [monthlyTransactions].
class MonthlyTransactionsFamily extends Family<AsyncValue<List<Transaction>>> {
  /// 월별 거래 내역 스트림
  ///
  /// Copied from [monthlyTransactions].
  const MonthlyTransactionsFamily();

  /// 월별 거래 내역 스트림
  ///
  /// Copied from [monthlyTransactions].
  MonthlyTransactionsProvider call({
    required int year,
    required int month,
  }) {
    return MonthlyTransactionsProvider(
      year: year,
      month: month,
    );
  }

  @override
  MonthlyTransactionsProvider getProviderOverride(
    covariant MonthlyTransactionsProvider provider,
  ) {
    return call(
      year: provider.year,
      month: provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyTransactionsProvider';
}

/// 월별 거래 내역 스트림
///
/// Copied from [monthlyTransactions].
class MonthlyTransactionsProvider
    extends AutoDisposeStreamProvider<List<Transaction>> {
  /// 월별 거래 내역 스트림
  ///
  /// Copied from [monthlyTransactions].
  MonthlyTransactionsProvider({
    required int year,
    required int month,
  }) : this._internal(
          (ref) => monthlyTransactions(
            ref as MonthlyTransactionsRef,
            year: year,
            month: month,
          ),
          from: monthlyTransactionsProvider,
          name: r'monthlyTransactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyTransactionsHash,
          dependencies: MonthlyTransactionsFamily._dependencies,
          allTransitiveDependencies:
              MonthlyTransactionsFamily._allTransitiveDependencies,
          year: year,
          month: month,
        );

  MonthlyTransactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    Stream<List<Transaction>> Function(MonthlyTransactionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyTransactionsProvider._internal(
        (ref) => create(ref as MonthlyTransactionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Transaction>> createElement() {
    return _MonthlyTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyTransactionsProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonthlyTransactionsRef
    on AutoDisposeStreamProviderRef<List<Transaction>> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _MonthlyTransactionsProviderElement
    extends AutoDisposeStreamProviderElement<List<Transaction>>
    with MonthlyTransactionsRef {
  _MonthlyTransactionsProviderElement(super.provider);

  @override
  int get year => (origin as MonthlyTransactionsProvider).year;
  @override
  int get month => (origin as MonthlyTransactionsProvider).month;
}

String _$pendingTransactionsHash() =>
    r'0ddef54427f6b4480387f7ede7d12b1d17291c58';

/// 동기화 대기 중인 거래 Provider
///
/// Copied from [pendingTransactions].
@ProviderFor(pendingTransactions)
final pendingTransactionsProvider =
    AutoDisposeFutureProvider<List<Transaction>>.internal(
  pendingTransactions,
  name: r'pendingTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingTransactionsRef
    = AutoDisposeFutureProviderRef<List<Transaction>>;
String _$categoriesHash() => r'86015b1e68053aa615bc72202eb8ebd5a55a1a0e';

/// 카테고리 목록 Provider
///
/// Copied from [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeStreamProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef = AutoDisposeStreamProviderRef<List<Category>>;
String _$selectedMonthHash() => r'88b5027d5fcd1d548ed8ad62f6a955f1e2734243';

/// 현재 선택된 월
///
/// Copied from [SelectedMonth].
@ProviderFor(SelectedMonth)
final selectedMonthProvider =
    AutoDisposeNotifierProvider<SelectedMonth, DateTime>.internal(
  SelectedMonth.new,
  name: r'selectedMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedMonth = AutoDisposeNotifier<DateTime>;
String _$monthlyStatsHash() => r'19c2bf618e7f0330ffc91cdadaa7f0cee03c8105';

/// 월별 통계
///
/// Copied from [MonthlyStats].
@ProviderFor(MonthlyStats)
final monthlyStatsProvider = AutoDisposeAsyncNotifierProvider<MonthlyStats,
    ({int income, int expense, int balance})>.internal(
  MonthlyStats.new,
  name: r'monthlyStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$monthlyStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MonthlyStats
    = AutoDisposeAsyncNotifier<({int income, int expense, int balance})>;
String _$todayStatsHash() => r'8617e5cc59bbd83714459262e9a7a37ba2f6bb85';

/// 오늘 통계
///
/// Copied from [TodayStats].
@ProviderFor(TodayStats)
final todayStatsProvider = AutoDisposeAsyncNotifierProvider<TodayStats,
    ({int income, int expense, int balance})>.internal(
  TodayStats.new,
  name: r'todayStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodayStats
    = AutoDisposeAsyncNotifier<({int income, int expense, int balance})>;
String _$transactionManagerHash() =>
    r'3df63be128b70bed77f9c046a13b6edec2987d99';

/// 거래 추가/수정/삭제 관리
///
/// Copied from [TransactionManager].
@ProviderFor(TransactionManager)
final transactionManagerProvider =
    AutoDisposeAsyncNotifierProvider<TransactionManager, void>.internal(
  TransactionManager.new,
  name: r'transactionManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
