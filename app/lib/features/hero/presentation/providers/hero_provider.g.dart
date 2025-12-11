// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hero_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$heroStatsHash() => r'ed3a5f3ea81f86981e43f27fd42ccfe36707c9ee';

/// 히어로 스탯 Provider (온라인 전용)
///
/// Copied from [heroStats].
@ProviderFor(heroStats)
final heroStatsProvider = AutoDisposeFutureProvider<HeroStats?>.internal(
  heroStats,
  name: r'heroStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$heroStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HeroStatsRef = AutoDisposeFutureProviderRef<HeroStats?>;
String _$canAccessGameHash() => r'ea112feba01e112c695f648abf9895c70444e66c';

/// 게임 접근 가능 여부 Provider
///
/// Copied from [canAccessGame].
@ProviderFor(canAccessGame)
final canAccessGameProvider = AutoDisposeProvider<bool>.internal(
  canAccessGame,
  name: r'canAccessGameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canAccessGameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CanAccessGameRef = AutoDisposeProviderRef<bool>;
String _$heroTitleHash() => r'62697950ff289e718c0c6179f9baf51564ea3479';

/// 히어로 칭호 Provider
///
/// Copied from [heroTitle].
@ProviderFor(heroTitle)
final heroTitleProvider = AutoDisposeProvider<String>.internal(
  heroTitle,
  name: r'heroTitleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$heroTitleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HeroTitleRef = AutoDisposeProviderRef<String>;
String _$autoHuntResultHash() => r'425f6811a2c4665fdc95c7857e235ff5c94c9f9a';

/// 자동사냥 결과 조회 Provider (온라인 전용)
///
/// Copied from [autoHuntResult].
@ProviderFor(autoHuntResult)
final autoHuntResultProvider =
    AutoDisposeFutureProvider<AutoHuntResult?>.internal(
  autoHuntResult,
  name: r'autoHuntResultProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoHuntResultHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AutoHuntResultRef = AutoDisposeFutureProviderRef<AutoHuntResult?>;
String _$rewardManagerHash() => r'47b15ff1f29dfb22854dde71175f98dfd26bbfdb';

/// 보상 지급 요청 (동기화 시 호출)
///
/// Copied from [RewardManager].
@ProviderFor(RewardManager)
final rewardManagerProvider =
    AutoDisposeAsyncNotifierProvider<RewardManager, void>.internal(
  RewardManager.new,
  name: r'rewardManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rewardManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RewardManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
