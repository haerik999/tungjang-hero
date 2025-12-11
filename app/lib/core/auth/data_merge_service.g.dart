// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_merge_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$needsMergeDecisionHash() =>
    r'52c76e146d7d0356b1ff8ebcb412b8efdf89c71e';

/// 병합 결정 필요 여부 Provider
///
/// Copied from [needsMergeDecision].
@ProviderFor(needsMergeDecision)
final needsMergeDecisionProvider = AutoDisposeProvider<bool>.internal(
  needsMergeDecision,
  name: r'needsMergeDecisionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$needsMergeDecisionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NeedsMergeDecisionRef = AutoDisposeProviderRef<bool>;
String _$localDataSummaryHash() => r'6d7e001303943cef3567af441fe5cb2a39c677b4';

/// 로컬 데이터 요약 Provider
///
/// Copied from [localDataSummary].
@ProviderFor(localDataSummary)
final localDataSummaryProvider = AutoDisposeProvider<DataSummary?>.internal(
  localDataSummary,
  name: r'localDataSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localDataSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LocalDataSummaryRef = AutoDisposeProviderRef<DataSummary?>;
String _$serverDataSummaryHash() => r'304b9d2fddd6a4b5313af66841324d80db847f43';

/// 서버 데이터 요약 Provider
///
/// Copied from [serverDataSummary].
@ProviderFor(serverDataSummary)
final serverDataSummaryProvider = AutoDisposeProvider<DataSummary?>.internal(
  serverDataSummary,
  name: r'serverDataSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serverDataSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ServerDataSummaryRef = AutoDisposeProviderRef<DataSummary?>;
String _$dataMergeServiceHash() => r'2d525bd46e8676f97e2575a73cd7483d7630399d';

/// 데이터 병합 서비스 Provider
///
/// Copied from [DataMergeService].
@ProviderFor(DataMergeService)
final dataMergeServiceProvider =
    NotifierProvider<DataMergeService, MergeState>.internal(
  DataMergeService.new,
  name: r'dataMergeServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dataMergeServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DataMergeService = Notifier<MergeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
