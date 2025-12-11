// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hero_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$heroStatsHash() => r'869d3472147945adfe5bc80f50ccac3be692a437';

/// 히어로 스탯 스트림
///
/// Copied from [heroStats].
@ProviderFor(heroStats)
final heroStatsProvider =
    AutoDisposeStreamProvider<HeroStatsTableData?>.internal(
  heroStats,
  name: r'heroStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$heroStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HeroStatsRef = AutoDisposeStreamProviderRef<HeroStatsTableData?>;
String _$heroTitleHash() => r'b09a5e5cb5b21a698b41280c7ce458dd23f89196';

/// 히어로 칭호 계산
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
String _$heroManagerHash() => r'3ed3658fbe8c62d7509833af1a2bfbd8a97c6e90';

/// 히어로 관리 (레벨업, XP, HP 관리)
///
/// Copied from [HeroManager].
@ProviderFor(HeroManager)
final heroManagerProvider =
    AutoDisposeAsyncNotifierProvider<HeroManager, void>.internal(
  HeroManager.new,
  name: r'heroManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$heroManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HeroManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
