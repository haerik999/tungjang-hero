// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isOnlineHash() => r'4646ae83e25e84ec20fea638d4d68d639f1986e4';

/// 온라인 상태 여부 Provider (편의용)
///
/// Copied from [isOnline].
@ProviderFor(isOnline)
final isOnlineProvider = AutoDisposeProvider<bool>.internal(
  isOnline,
  name: r'isOnlineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isOnlineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsOnlineRef = AutoDisposeProviderRef<bool>;
String _$isOfflineHash() => r'934c517e3fd94ae5a8a4eca3643e335689ef4c96';

/// 오프라인 상태 여부 Provider (편의용)
///
/// Copied from [isOffline].
@ProviderFor(isOffline)
final isOfflineProvider = AutoDisposeProvider<bool>.internal(
  isOffline,
  name: r'isOfflineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isOfflineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsOfflineRef = AutoDisposeProviderRef<bool>;
String _$networkStatusStreamHash() =>
    r'4fbc427ceb984a52bd50b737f65cbcd53cc80454';

/// 네트워크 상태 스트림 Provider
///
/// Copied from [networkStatusStream].
@ProviderFor(networkStatusStream)
final networkStatusStreamProvider =
    AutoDisposeStreamProvider<NetworkStatus>.internal(
  networkStatusStream,
  name: r'networkStatusStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkStatusStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NetworkStatusStreamRef = AutoDisposeStreamProviderRef<NetworkStatus>;
String _$networkStatusNotifierHash() =>
    r'1b5cf07a0adb953fa3c572a9067d1077819b106d';

/// 네트워크 상태 관리 Notifier
///
/// Copied from [NetworkStatusNotifier].
@ProviderFor(NetworkStatusNotifier)
final networkStatusNotifierProvider =
    NotifierProvider<NetworkStatusNotifier, NetworkStatus>.internal(
  NetworkStatusNotifier.new,
  name: r'networkStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NetworkStatusNotifier = Notifier<NetworkStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
