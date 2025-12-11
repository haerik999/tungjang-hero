// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncSummaryHash() => r'61ec2a0b14793b5c7687201f07529519d1652034';

/// 동기화 상태 요약 Provider
///
/// Copied from [syncSummary].
@ProviderFor(syncSummary)
final syncSummaryProvider = AutoDisposeProvider<
    ({
      bool hasPending,
      int pendingCount,
      DateTime? lastSync,
      bool isSyncing
    })>.internal(
  syncSummary,
  name: r'syncSummaryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncSummaryRef = AutoDisposeProviderRef<
    ({bool hasPending, int pendingCount, DateTime? lastSync, bool isSyncing})>;
String _$syncProgressHash() => r'da87a198dcf4c49ed37b3c20a1405ed8fd76f148';

/// 동기화 진행률 Provider
///
/// Copied from [syncProgress].
@ProviderFor(syncProgress)
final syncProgressProvider = AutoDisposeProvider<double>.internal(
  syncProgress,
  name: r'syncProgressProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncProgressRef = AutoDisposeProviderRef<double>;
String _$syncServiceHash() => r'dacb4ad1d4ac22bd81074e1f17be1212e5c1a92c';

/// 동기화 서비스 Provider
///
/// Copied from [SyncService].
@ProviderFor(SyncService)
final syncServiceProvider = NotifierProvider<SyncService, SyncState>.internal(
  SyncService.new,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncService = Notifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
