import 'package:intl/intl.dart';
import '../services/currency_service.dart';
import '../services/user_preferences_service.dart';

class CurrencyUtils {
  static final CurrencyService _currencyService = CurrencyService();
  static final UserPreferencesService _prefsService = UserPreferencesService();

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'Fr',
    'CNY': '¥',
    'INR': '₹',
  };

  static String getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }

  static Future<String> formatPrice(double price, {String? currency}) async {
    final preferredCurrency = currency ?? await _prefsService.getPreferredCurrency();
    final symbol = getCurrencySymbol(preferredCurrency);
    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    );
    return format.format(price);
  }

  static Future<double> convertPrice(double price, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return price;
    
    try {
      return await _currencyService.convertCurrency(
        amount: price,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    } catch (e) {
      print('Error converting price: $e');
      return price; // Return original price in case of error
    }
  }

  static Future<String> formatAndConvertPrice(double price, String fromCurrency, {String? toCurrency}) async {
    final targetCurrency = toCurrency ?? await _prefsService.getPreferredCurrency();
    final convertedPrice = await convertPrice(price, fromCurrency, targetCurrency);
    return formatPrice(convertedPrice, currency: targetCurrency);
  }
} 