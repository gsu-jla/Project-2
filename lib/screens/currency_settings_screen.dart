import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import '../services/user_preferences_service.dart';
import '../utils/config.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final UserPreferencesService _prefsService = UserPreferencesService();
  String _selectedCurrency = 'USD';
  List<String> _availableCurrencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _loadPreferredCurrency();
  }

  Future<void> _loadPreferredCurrency() async {
    final currency = await _prefsService.getPreferredCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  Future<void> _loadCurrencies() async {
    try {
      final currencies = await _currencyService.getAvailableCurrencies();
      setState(() {
        _availableCurrencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading currencies: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your preferred currency:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    items: _availableCurrencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        await _prefsService.setPreferredCurrency(value);
                        setState(() {
                          _selectedCurrency = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Currency',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Current Exchange Rates:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, double>>(
                    future: _currencyService.getExchangeRates(
                      baseCurrency: _selectedCurrency,
                      currencies: Config.supportedCurrencies,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No exchange rates available');
                      }

                      final rates = snapshot.data!;
                      return Column(
                        children: rates.entries.map((rate) {
                          return ListTile(
                            title: Text('1 $_selectedCurrency = ${rate.value} ${rate.key}'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
} 