import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class AuthLocalService {
  static const String _tokenKey = 'auth_token';
  static const String _rememberMeKey = 'remember_me';
  static const String _userIdKey = 'user_id';

  final SharedPreferences _prefs;

  AuthLocalService(this._prefs);

  Future<void> storeToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
  }

  Future<void> setRememberMe(bool rememberMe) async {
    await _prefs.setBool(_rememberMeKey, rememberMe);
  }

  Future<bool> getRememberMe() async {
    return _prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> storeUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  Future<bool> hasStoredCredentials() async {
    final token = await getToken();
    final rememberMe = await getRememberMe();
    return token != null && rememberMe;
  }

  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_rememberMeKey);
    await _prefs.remove(_userIdKey);
  }
}