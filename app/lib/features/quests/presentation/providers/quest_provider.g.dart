// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyQuestsHash() => r'c7792a6d8e50659a1d62b469a287427c5baa9cc2';

/// 오늘의 일일 퀘스트 스트림
///
/// Copied from [dailyQuests].
@ProviderFor(dailyQuests)
final dailyQuestsProvider = AutoDisposeStreamProvider<List<Quest>>.internal(
  dailyQuests,
  name: r'dailyQuestsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dailyQuestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DailyQuestsRef = AutoDisposeStreamProviderRef<List<Quest>>;
String _$activeQuestsHash() => r'a5ce956d38443354fe77ccd1e79b1d1e5a417309';

/// 진행중인 퀘스트 스트림
///
/// Copied from [activeQuests].
@ProviderFor(activeQuests)
final activeQuestsProvider = AutoDisposeStreamProvider<List<Quest>>.internal(
  activeQuests,
  name: r'activeQuestsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeQuestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveQuestsRef = AutoDisposeStreamProviderRef<List<Quest>>;
String _$completedQuestsHash() => r'ba7595ce5d8b14966acd6235022c6bcfd10ad49d';

/// 완료된 퀘스트 스트림
///
/// Copied from [completedQuests].
@ProviderFor(completedQuests)
final completedQuestsProvider = AutoDisposeStreamProvider<List<Quest>>.internal(
  completedQuests,
  name: r'completedQuestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedQuestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CompletedQuestsRef = AutoDisposeStreamProviderRef<List<Quest>>;
String _$questManagerHash() => r'83d17a5d4d9b4c1acf83afd2cb161ce122a9dec7';

/// 퀘스트 관리자
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
