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
    
    print('Loading cart data: $cartString');
    print('Loading purchased data: $purchasedString');
    
    if (cartString != null && cartString.isNotEmpty) {
      try {
        final cartIds = cartString.split(',').where((s) => s.isNotEmpty).map(int.parse).toSet();
        _cart.addAll(cartIds);
        print('Loaded cart items: $_cart');
      } catch (e) {
        print('Error parsing cart data: $e');
        _cart.clear();
      }
    }
    
    if (purchasedString != null && purchasedString.isNotEmpty) {
      try {
        final purchasedIds = purchasedString.split(',').where((s) => s.isNotEmpty).map(int.parse).toSet();
        _purchased.addAll(purchasedIds);
        print('Loaded purchased items: $_purchased');
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
    print('Added to cart: $artworkId');
  }

  void removeFromCart(int artworkId) {
    _cart.remove(artworkId);
    _saveCart();
    print('Removed from cart: $artworkId');
  }

  void purchase(int artworkId) {
    if (!_purchased.contains(artworkId)) {
      _cart.remove(artworkId);
      _purchased.add(artworkId);
      _saveCart();
      _savePurchased();
      print('Purchased artwork: $artworkId');
      print('Current purchased items: $_purchased');
    } else {
      print('Artwork $artworkId is already purchased');
    }
  }

  Set<int> get cart => _cart;
  Set<int> get purchased => _purchased;

  Future<List<Map<String, dynamic>>> getCart() async {
    final artworks = await _artService.getArtworks();
    return artworks.where((artwork) => _cart.contains(artwork['id'])).toList();
  }

  Future<List<Map<String, dynamic>>> getPurchased() async {
    final artworks = await _artService.getArtworks();
    final purchasedArtworks = artworks.where((artwork) => _purchased.contains(artwork['id'])).toList();
    print('Retrieved purchased artworks: ${purchasedArtworks.map((a) => a['id']).toList()}');
    return purchasedArtworks;
  }

  void _saveCart() {
    final cartString = _cart.join(',');
    _prefs.setString(_cartKey, cartString);
    print('Saved cart: $cartString');
  }

  void _savePurchased() {
    final purchasedString = _purchased.join(',');
    _prefs.setString(_purchasedKey, purchasedString);
    print('Saved purchased: $purchasedString');
  }

  // Add a method to clear all data (for testing)
  void clearAllData() {
    _cart.clear();
    _purchased.clear();
    _saveCart();
    _savePurchased();
    print('Cleared all cart and purchase data');
  }
} 