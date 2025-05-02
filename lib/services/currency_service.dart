import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

class CurrencyService {
  final String _baseUrl = 'https://api.frankfurter.app';

  Future<Map<String, double>> getExchangeRates({
    required String baseCurrency,
    List<String>? currencies,
  }) async {
    try {
      final targetCurrencies = currencies?.join(',') ?? Config.supportedCurrencies.join(',');
      
      final Uri uri = Uri.parse('$_baseUrl/latest').replace(
        queryParameters: {
          'from': baseCurrency,
          'to': targetCurrencies,
        },
      );

      final response = await http.get(uri);
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, double>.from(data['rates']);
      } else {
        throw Exception('Failed to get exchange rates');
      }
    } catch (e) {
      print('Error getting exchange rates: $e');
      return {};
    }
  }

  Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/latest').replace(
        queryParameters: {
          'from': fromCurrency,
          'to': toCurrency,
          'amount': amount.toString(),
        },
      );

      final response = await http.get(uri);
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates'][toCurrency] * amount;
      } else {
        throw Exception('Failed to convert currency');
      }
    } catch (e) {
      print('Error converting currency: $e');
      return amount; // Return original amount in case of error
    }
  }

  Future<List<String>> getAvailableCurrencies() async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/currencies');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<String>.from(data.keys);
      } else {
        throw Exception('Failed to get currencies');
      }
    } catch (e) {
      throw Exception('Failed to get currencies: $e');
    }
  }

  // Test API
  Future<bool> testApiKey() async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/latest').replace(
        queryParameters: {
          'from': 'USD',
          'to': 'EUR,GBP',
        },
      );

      final response = await http.get(uri);
      print('API Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error testing API: $e');
      return false;
    }
  }
} 