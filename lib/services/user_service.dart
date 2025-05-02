import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _usernameKey = 'username';
  final SharedPreferences _prefs;

  UserService._(this._prefs);

  static Future<UserService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return UserService._(prefs);
  }

  Future<void> saveUserData({
    required String name,
    required String email,
    required String username,
  }) async {
    await _prefs.setString(_nameKey, name);
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_usernameKey, username);
  }

  String? get name => _prefs.getString(_nameKey);
  String? get email => _prefs.getString(_emailKey);
  String? get username => _prefs.getString(_usernameKey);

  bool get isLoggedIn => name != null && email != null;

  Future<void> logout() async {
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_usernameKey);
  }
} 