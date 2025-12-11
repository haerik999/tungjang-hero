// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncSummaryHash() => r'760413287852b4b3d1dfbf764051a1ec5deaad43';

/// 동기화 상태 요약 Provider
///
/// Copied from [syncSummary].
@ProviderFor(syncSummary)
final syncSummaryProvider = AutoDisposeProvider<
    ({bool hasPending, int pendingCount, DateTime? lastSync})>.internal(
  syncSummary,
  name: r'syncSummaryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncSummaryRef = AutoDisposeProviderRef<
    ({bool hasPending, int pendingCount, DateTime? lastSync})>;
String _$syncServiceHash() => r'584f2b27a73377afbdddcd972b2e7dc8f9920798';

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
