// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isGuestModeHash() => r'75d0e39069abc5d2d0ad23bd7e5ae211b93af8bf';

/// 게스트 모드 여부 Provider
///
/// Copied from [isGuestMode].
@ProviderFor(isGuestMode)
final isGuestModeProvider = AutoDisposeProvider<bool>.internal(
  isGuestMode,
  name: r'isGuestModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isGuestModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsGuestModeRef = AutoDisposeProviderRef<bool>;
String _$isAuthenticatedHash() => r'72a802f9b763e0a905e3d0557cb75c9e908f04cd';

/// 로그인 상태 여부 Provider
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$canSyncHash() => r'bee96dcc3055937b36c81b6ae628abbfb7479bf3';

/// 동기화 가능 여부 Provider
///
/// Copied from [canSync].
@ProviderFor(canSync)
final canSyncProvider = AutoDisposeProvider<bool>.internal(
  canSync,
  name: r'canSyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$canSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CanSyncRef = AutoDisposeProviderRef<bool>;
String _$canAccessOnlineFeaturesHash() =>
    r'6ee22ee3571238bb42bbd4716f0dadbc24541a57';

/// 게임 접근 가능 여부 Provider (온라인 + 로그인 필요)
///
/// Copied from [canAccessOnlineFeatures].
@ProviderFor(canAccessOnlineFeatures)
final canAccessOnlineFeaturesProvider = AutoDisposeProvider<bool>.internal(
  canAccessOnlineFeatures,
  name: r'canAccessOnlineFeaturesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canAccessOnlineFeaturesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CanAccessOnlineFeaturesRef = AutoDisposeProviderRef<bool>;
String _$appAuthHash() => r'64018687e53301d1286c8e438df0658c10cd223b';

/// 앱 인증 상태 관리 Provider
///
/// Copied from [AppAuth].
@ProviderFor(AppAuth)
final appAuthProvider = NotifierProvider<AppAuth, AppAuthState>.internal(
  AppAuth.new,
  name: r'appAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppAuth = Notifier<AppAuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
