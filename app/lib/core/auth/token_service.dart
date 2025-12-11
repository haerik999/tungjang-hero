import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 토큰 관리 서비스
/// Access Token과 Refresh Token을 안전하게 저장/조회/삭제합니다.
class TokenService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  // 캐시 (메모리)
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;
  static DateTime? _cachedExpiry;

  /// Access Token 저장
  static Future<void> saveAccessToken(String token, {int? expiresInSeconds}) async {
    await _storage.write(key: _accessTokenKey, value: token);
    _cachedAccessToken = token;

    if (expiresInSeconds != null) {
      final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
      await _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
      _cachedExpiry = expiry;
    }
  }

  /// Refresh Token 저장
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
    _cachedRefreshToken = token;
  }

  /// Access Token 조회
  static Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: _accessTokenKey);
    return _cachedAccessToken;
  }

  /// Refresh Token 조회
  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    _cachedRefreshToken = await _storage.read(key: _refreshTokenKey);
    return _cachedRefreshToken;
  }

  /// 토큰 만료 시간 조회
  static Future<DateTime?> getTokenExpiry() async {
    if (_cachedExpiry != null) return _cachedExpiry;
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr != null) {
      _cachedExpiry = DateTime.tryParse(expiryStr);
    }
    return _cachedExpiry;
  }

  /// Access Token 만료 여부 확인
  static Future<bool> isAccessTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;

    // 만료 5분 전부터 만료 처리 (갱신 여유 시간)
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }

  /// 토큰 존재 여부 확인 (로그인 상태 확인용)
  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;
    return !(await isAccessTokenExpired());
  }

  /// 모든 토큰 삭제 (로그아웃)
  static Future<void> clearAllTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenExpiryKey),
    ]);
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedExpiry = null;
  }

  /// 캐시 초기화 (앱 시작 시 사용)
  static Future<void> initializeCache() async {
    _cachedAccessToken = await _storage.read(key: _accessTokenKey);
    _cachedRefreshToken = await _storage.read(key: _refreshTokenKey);
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr != null) {
      _cachedExpiry = DateTime.tryParse(expiryStr);
    }
  }
}
