import 'package:shared_preferences/shared_preferences.dart';
import 'art_service.dart';

class CartService {
  static const String _cartKey = 'cart';
  final Set<int> _cart = {};
  final SharedPreferences _prefs;
  late final ArtService _artService;

  CartService._(this._prefs) {
    // Load cart from storage
    final cartString = _prefs.getString(_cartKey);
    if (cartString != null) {
      _cart.addAll(cartString.split(',').map(int.parse));
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

  void addToCart(int artworkId) {
    _cart.add(artworkId);
    _saveCart();
  }

  void removeFromCart(int artworkId) {
    _cart.remove(artworkId);
    _saveCart();
  }

  Set<int> get cart => _cart;

  Future<List<Map<String, dynamic>>> getCart() async {
    final artworks = await _artService.getArtworks();
    return artworks.where((artwork) => _cart.contains(artwork['id'])).toList();
  }

  void _saveCart() {
    _prefs.setString(_cartKey, _cart.join(','));
  }
} 