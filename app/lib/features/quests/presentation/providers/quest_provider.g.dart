// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyQuestsHash() => r'719a8fbae5a83d08e2a33f0552469a288c085115';

/// 일일 퀘스트 Provider (온라인 전용)
///
/// Copied from [dailyQuests].
@ProviderFor(dailyQuests)
final dailyQuestsProvider = AutoDisposeFutureProvider<List<Quest>>.internal(
  dailyQuests,
  name: r'dailyQuestsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dailyQuestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DailyQuestsRef = AutoDisposeFutureProviderRef<List<Quest>>;
String _$activeQuestsHash() => r'012fe3b528db04686ecda85306918e7740a67fdd';

/// 진행중인 퀘스트 Provider (온라인 전용)
///
/// Copied from [activeQuests].
@ProviderFor(activeQuests)
final activeQuestsProvider = AutoDisposeFutureProvider<List<Quest>>.internal(
  activeQuests,
  name: r'activeQuestsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeQuestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveQuestsRef = AutoDisposeFutureProviderRef<List<Quest>>;
String _$completedQuestsHash() => r'3b7c173c1e71a933292b3f1e28e87cdce871bfda';

/// 완료된 퀘스트 Provider (온라인 전용)
///
/// Copied from [completedQuests].
@ProviderFor(completedQuests)
final completedQuestsProvider = AutoDisposeFutureProvider<List<Quest>>.internal(
  completedQuests,
  name: r'completedQuestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedQuestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CompletedQuestsRef = AutoDisposeFutureProviderRef<List<Quest>>;
String _$questManagerHash() => r'd88e3a689d0ecf86ee2f86e4b85d00b6b7addc23';

/// 퀘스트 관리자 (온라인 전용)
///
/// Copied from [QuestManager].
@ProviderFor(QuestManager)
final questManagerProvider =
    AutoDisposeAsyncNotifierProvider<QuestManager, void>.internal(
  QuestManager.new,
  name: r'questManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$questManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuestManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
