import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import '../utils/device_id.dart';
import 'app_database.dart';
import 'database_encryption.dart';

/// 암호화된 데이터베이스 연결 생성
Future<QueryExecutor> _openEncryptedConnection() async {
  // 암호화 키 가져오기
  final encryptionKey = await DatabaseEncryption.getOrCreateKey();

  // 데이터베이스 파일 경로
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'tungjang_hero_encrypted.db'));

  // SQLCipher 라이브러리 로드
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      // SQLCipher 암호화 적용
      db.execute("PRAGMA key = '$encryptionKey'");
      // 성능 최적화
      db.execute('PRAGMA cipher_page_size = 4096');
      db.execute('PRAGMA kdf_iter = 256000');
      db.execute('PRAGMA cipher_memory_security = ON');
    },
  );
}

/// 플랫폼별 데이터베이스 연결 생성
Future<AppDatabase> createDatabase() async {
  if (kIsWeb) {
    // 웹에서는 암호화 없이 기본 연결 사용
    return AppDatabase();
  }

  // 모바일/데스크톱에서는 암호화된 연결 사용
  final executor = await _openEncryptedConnection();
  return AppDatabase(executor);
}

/// 데이터베이스 초기화 상태
class DatabaseState {
  final AppDatabase database;
  final String deviceId;
  final bool isInitialized;

  const DatabaseState({
    required this.database,
    required this.deviceId,
    this.isInitialized = false,
  });

  DatabaseState copyWith({
    AppDatabase? database,
    String? deviceId,
    bool? isInitialized,
  }) {
    return DatabaseState(
      database: database ?? this.database,
      deviceId: deviceId ?? this.deviceId,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// 데이터베이스 초기화 Provider
final databaseInitProvider = FutureProvider<DatabaseState>((ref) async {
  // 디바이스 ID 초기화
  final deviceId = await DeviceIdManager.getOrCreateDeviceId();

  // 암호화된 데이터베이스 생성
  final database = await createDatabase();

  // 사용자 설정 초기화 (없으면 생성)
  final settings = await database.getUserSettings();
  if (settings == null) {
    await database.initializeUserSettings(deviceId);
  }

  // 리소스 정리
  ref.onDispose(() => database.close());

  return DatabaseState(
    database: database,
    deviceId: deviceId,
    isInitialized: true,
  );
});

/// 초기화된 데이터베이스 Provider
/// 사용 전 databaseInitProvider가 완료되었는지 확인 필요
final databaseProvider = Provider<AppDatabase>((ref) {
  final state = ref.watch(databaseInitProvider);
  return state.maybeWhen(
    data: (data) => data.database,
    orElse: () => throw StateError(
        'Database not initialized. Ensure databaseInitProvider is loaded first.'),
  );
});

/// 현재 디바이스 ID Provider
final deviceIdProvider = Provider<String>((ref) {
  final state = ref.watch(databaseInitProvider);
  return state.maybeWhen(
    data: (data) => data.deviceId,
    orElse: () => throw StateError(
        'DeviceId not initialized. Ensure databaseInitProvider is loaded first.'),
  );
});

/// 동기화 대기 건수 Provider
final pendingSyncCountProvider = StreamProvider<int>((ref) async* {
  final db = ref.watch(databaseProvider);

  // 초기값
  yield await db.getPendingSyncCount();

  // 주기적 업데이트 (5초마다)
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    yield await db.getPendingSyncCount();
  }
});

/// 게스트 모드 여부 Provider
final isGuestModeProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUserSettings().map((settings) => settings?.isGuestMode ?? true);
});
