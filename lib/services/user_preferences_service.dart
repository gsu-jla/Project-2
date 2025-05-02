import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _currencyKey = 'preferred_currency';
  static const String _defaultCurrency = 'USD';

  Future<String> getPreferredCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? _defaultCurrency;
  }

  Future<void> setPreferredCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }
} 