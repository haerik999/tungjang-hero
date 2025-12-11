import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/theme/app_theme.dart';
import 'core/database/database_provider.dart';
import 'features/quests/presentation/providers/quest_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Kakao SDK
  // Replace 'YOUR_KAKAO_NATIVE_APP_KEY' with your actual Kakao Native App Key
  // Get this from https://developers.kakao.com/
  KakaoSdk.init(
    nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',
    javaScriptAppKey: 'YOUR_KAKAO_JAVASCRIPT_APP_KEY',
  );

  // 데이터베이스 초기화를 위한 컨테이너 생성
  final container = ProviderContainer();

  // 히어로 초기화
  await container.read(databaseProvider).initializeHeroIfNeeded();

  // 일일 퀘스트 생성
  await container.read(questManagerProvider.notifier).generateDailyQuestsIfNeeded();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TungJangHeroApp(),
    ),
  );
}

class TungJangHeroApp extends ConsumerWidget {
  const TungJangHeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '텅장히어로',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
