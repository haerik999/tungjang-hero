import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SQLite 암호화 키 관리
class DatabaseEncryption {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyName = 'tungjang_hero_db_key';
  static const _keyLength = 32; // 256-bit key

  /// 암호화 키 조회 (없으면 생성)
  static Future<String> getOrCreateKey() async {
    String? existingKey = await _storage.read(key: _keyName);

    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    // 새 키 생성
    final newKey = _generateSecureKey();
    await _storage.write(key: _keyName, value: newKey);
    return newKey;
  }

  /// 안전한 랜덤 키 생성
  static String _generateSecureKey() {
    final random = Random.secure();
    final bytes = Uint8List(_keyLength);

    for (int i = 0; i < _keyLength; i++) {
      bytes[i] = random.nextInt(256);
    }

    return base64Url.encode(bytes);
  }

  /// 키 존재 여부 확인
  static Future<bool> hasKey() async {
    final key = await _storage.read(key: _keyName);
    return key != null && key.isNotEmpty;
  }

  /// 키 삭제 (앱 초기화용)
  static Future<void> deleteKey() async {
    await _storage.delete(key: _keyName);
  }

  /// 모든 보안 데이터 삭제
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
