import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_state_service.dart';
import 'core/auth/token_service.dart';
import 'core/database/database_provider.dart';
import 'core/network/connectivity_provider.dart';
import 'core/network/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 토큰 캐시 초기화
  await TokenService.initializeCache();

  // 데이터베이스 초기화를 위한 컨테이너 생성
  final container = ProviderContainer();

  // 암호화된 데이터베이스 및 디바이스 ID 초기화
  await container.read(databaseInitProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TungJangHeroApp(),
    ),
  );
}

class TungJangHeroApp extends ConsumerStatefulWidget {
  const TungJangHeroApp({super.key});

  @override
  ConsumerState<TungJangHeroApp> createState() => _TungJangHeroAppState();
}

class _TungJangHeroAppState extends ConsumerState<TungJangHeroApp> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 동기화 트리거
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerStartupSync();
    });
  }

  Future<void> _triggerStartupSync() async {
    // 로그인 상태이고 온라인이면 동기화 시작
    final canSync = ref.read(canSyncProvider);
    final isOnline = ref.read(isOnlineProvider);

    if (canSync && isOnline) {
      await ref.read(syncServiceProvider.notifier).syncAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '텅장히어로',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
