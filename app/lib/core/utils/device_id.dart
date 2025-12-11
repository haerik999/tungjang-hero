import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// 디바이스 고유 ID 관리
class DeviceIdManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _deviceIdKey = 'tungjang_hero_device_id';
  static const _uuid = Uuid();

  static String? _cachedDeviceId;

  /// 디바이스 ID 조회 (없으면 생성)
  static Future<String> getOrCreateDeviceId() async {
    // 캐시된 값이 있으면 반환
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // 저장된 값 확인
    String? existingId = await _storage.read(key: _deviceIdKey);

    if (existingId != null && existingId.isNotEmpty) {
      _cachedDeviceId = existingId;
      return existingId;
    }

    // 새 UUID 생성
    final newId = _uuid.v4();
    await _storage.write(key: _deviceIdKey, value: newId);
    _cachedDeviceId = newId;
    return newId;
  }

  /// 디바이스 ID 존재 여부 확인
  static Future<bool> hasDeviceId() async {
    final id = await _storage.read(key: _deviceIdKey);
    return id != null && id.isNotEmpty;
  }

  /// 캐시된 디바이스 ID 반환 (동기)
  /// 반드시 getOrCreateDeviceId()를 먼저 호출해야 함
  static String? get cachedDeviceId => _cachedDeviceId;

  /// 디바이스 ID 삭제 (앱 초기화용)
  static Future<void> deleteDeviceId() async {
    await _storage.delete(key: _deviceIdKey);
    _cachedDeviceId = null;
  }
}
