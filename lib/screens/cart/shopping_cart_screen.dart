import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/cart_service.dart';
import '../../services/art_service.dart';
import '../../services/user_preferences_service.dart';
import '../../services/currency_service.dart';
import '../../utils/currency_utils.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late final CartService _cartService;
  late final ArtService _artService;
  final UserPreferencesService _prefsService = UserPreferencesService();
  final CurrencyService _currencyService = CurrencyService();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  Future<String> _getFormattedPrice(double price) async {
    try {
      final preferredCurrency = await _prefsService.getPreferredCurrency();
      final symbol = CurrencyUtils.getCurrencySymbol(preferredCurrency);
      final formattedPrice = await CurrencyUtils.formatAndConvertPrice(price, 'USD');
      return formattedPrice;
    } catch (e) {
      print('Error formatting price: $e');
      return CurrencyUtils.formatPrice(price, currency: 'USD');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _cartService = await CartService.create();
    _artService = await ArtService.create();
    await _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      final items = await _cartService.getCart();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cart: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromCart(int artworkId) async {
    try {
      _cartService.removeFromCart(artworkId);
      await _loadCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final artwork = _cartItems[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: artwork['imageUrl'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(Icons.error),
                                  ),
                                ),
                              ),
                              title: Text(
                                artwork['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    artwork['artist'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  FutureBuilder<String>(
                                    future: _getFormattedPrice(artwork['price']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const SizedBox(
                                          height: 20,
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }
                                      return Text(
                                        snapshot.data ?? 'Loading...',
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() {
                                    _cartService.removeFromCart(artwork['id'] as int);
                                  });
                                  _loadCart();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<String>(
                            future: _getFormattedPrice(
                              _cartItems.fold<double>(
                                0,
                                (sum, item) => sum + item['price'],
                              ),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 20,
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return Text(
                                snapshot.data ?? 'Loading...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
} 