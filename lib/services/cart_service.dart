import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _purchasesKey = 'purchases';
  final Set<int> _purchases = {};
  final SharedPreferences _prefs;

  CartService._(this._prefs) {
    // Load purchases from storage
    final purchasesString = _prefs.getString(_purchasesKey);
    if (purchasesString != null) {
      _purchases.addAll(purchasesString.split(',').map(int.parse));
    }
  }

  static Future<CartService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CartService._(prefs);
  }

  bool isPurchased(int artworkId) {
    return _purchases.contains(artworkId);
  }

  void purchase(int artworkId) {
    _purchases.add(artworkId);
    _savePurchases();
  }

  Set<int> get purchases => _purchases;

  void _savePurchases() {
    _prefs.setString(_purchasesKey, _purchases.join(','));
  }
} 