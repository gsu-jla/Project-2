import 'package:flutter/material.dart';
import '../services/pixabay_service.dart';
import '../services/currency_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final PixabayService _pixabayService = PixabayService();
  final CurrencyService _currencyService = CurrencyService();
  bool _isLoading = false;
  String _pixabayStatus = 'Not tested yet';
  String _currencyStatus = 'Not tested yet';

  Future<void> _testPixabayApi() async {
    setState(() {
      _isLoading = true;
      _pixabayStatus = 'Testing...';
    });

    try {
      final bool isConnected = await _pixabayService.testApiConnection();
      setState(() {
        _pixabayStatus = isConnected ? 'API Connection Successful!' : 'API Connection Failed';
      });
    } catch (e) {
      setState(() {
        _pixabayStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCurrencyApi() async {
    setState(() {
      _isLoading = true;
      _currencyStatus = 'Testing API key...';
    });

    try {
      // First test the API key
      final bool isKeyValid = await _currencyService.testApiKey();
      if (!isKeyValid) {
        setState(() {
          _currencyStatus = 'API Key is invalid. Please check your key and try again.';
        });
        return;
      }

      setState(() {
        _currencyStatus = 'API Key valid. Fetching rates...';
      });

      final rates = await _currencyService.getExchangeRates(
        baseCurrency: 'USD',
        currencies: ['EUR', 'GBP'],
      );
      
      if (rates.isEmpty) {
        setState(() {
          _currencyStatus = 'API Connection Failed: No rates returned';
        });
        return;
      }

      final rateDetails = rates.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
      
      setState(() {
        _currencyStatus = 'API Connection Successful!\n\nCurrent Rates:\n$rateDetails';
      });
    } catch (e) {
      setState(() {
        _currencyStatus = 'Error: $e\n\nPlease check:\n1. Your API key\n2. Internet connection\n3. API endpoint availability';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Tests'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pixabay Test
            const Text(
              'Pixabay API:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _pixabayStatus,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testPixabayApi,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Pixabay API'),
            ),
            
            const SizedBox(height: 40),
            
            // CurrencyLayer Test
            const Text(
              'CurrencyLayer API:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _currencyStatus,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCurrencyApi,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test CurrencyLayer API'),
            ),
          ],
        ),
      ),
    );
  }
} 