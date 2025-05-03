import 'package:shared_preferences/shared_preferences.dart';
import 'art_service.dart';

class CartService {
  static const String _cartKey = 'cart';
  static const String _purchasedKey = 'purchased';
  final Set<int> _cart = {};
  final Set<int> _purchased = {};
  final SharedPreferences _prefs;
  late final ArtService _artService;

  CartService._(this._prefs) {
    // Load cart and purchased items from storage
    final cartString = _prefs.getString(_cartKey);
    final purchasedString = _prefs.getString(_purchasedKey);
    
    if (cartString != null && cartString.isNotEmpty) {
      try {
        _cart.addAll(cartString.split(',').where((s) => s.isNotEmpty).map(int.parse));
      } catch (e) {
        print('Error parsing cart data: $e');
        _cart.clear();
      }
    }
    
    if (purchasedString != null && purchasedString.isNotEmpty) {
      try {
        _purchased.addAll(purchasedString.split(',').where((s) => s.isNotEmpty).map(int.parse));
      } catch (e) {
        print('Error parsing purchased data: $e');
        _purchased.clear();
      }
    }
  }

  static Future<CartService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = CartService._(prefs);
    service._artService = await ArtService.create();
    return service;
  }

  bool isInCart(int artworkId) {
    return _cart.contains(artworkId);
  }

  bool isPurchased(int artworkId) {
    return _purchased.contains(artworkId);
  }

  void addToCart(int artworkId) {
    _cart.add(artworkId);
    _saveCart();
  }

  void removeFromCart(int artworkId) {
    _cart.remove(artworkId);
    _saveCart();
  }

  void purchase(int artworkId) {
    _cart.remove(artworkId);
    _purchased.add(artworkId);
    _saveCart();
    _savePurchased();
  }

  Set<int> get cart => _cart;
  Set<int> get purchased => _purchased;

  Future<List<Map<String, dynamic>>> getCart() async {
    final artworks = await _artService.getArtworks();
    return artworks.where((artwork) => _cart.contains(artwork['id'])).toList();
  }

  Future<List<Map<String, dynamic>>> getPurchased() async {
    final artworks = await _artService.getArtworks();
    return artworks.where((artwork) => _purchased.contains(artwork['id'])).toList();
  }

  void _saveCart() {
    _prefs.setString(_cartKey, _cart.join(','));
  }

  void _savePurchased() {
    _prefs.setString(_purchasedKey, _purchased.join(','));
  }
} 