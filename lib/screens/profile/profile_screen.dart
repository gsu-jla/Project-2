import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/art_service.dart';
import '../../services/favorite_service.dart';
import '../../services/cart_service.dart';
import '../../services/collection_service.dart';
import '../../services/user_preferences_service.dart';
import '../../services/currency_service.dart';
import '../../utils/currency_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ArtService _artService;
  late final FavoriteService _favoriteService;
  late final CartService _cartService;
  late final CollectionService _collectionService;
  final UserPreferencesService _prefsService = UserPreferencesService();
  final CurrencyService _currencyService = CurrencyService();
  String _currentCurrency = 'USD';
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _cart = [];
  List<Map<String, dynamic>> _collections = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _artService = await ArtService.create();
    _favoriteService = await FavoriteService.create();
    _cartService = await CartService.create();
    _collectionService = await CollectionService.create();
    await _loadPreferredCurrency();
    await _loadFavorites();
    await _loadCart();
    await _loadCollections();
  }

  Future<void> _loadPreferredCurrency() async {
    final currency = await _prefsService.getPreferredCurrency();
    setState(() {
      _currentCurrency = currency;
    });
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoriteService.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  Future<void> _loadCart() async {
    final cart = await _cartService.getCart();
    setState(() {
      _cart = cart;
    });
  }

  Future<void> _loadCollections() async {
    final collections = await _collectionService.getCollections();
    setState(() {
      _collections = collections;
    });
  }

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

  void _logout() {
    // Clear user data and navigate to login screen
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final artwork = _favorites[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: artwork['imageUrl'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artwork['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Shopping Cart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final artwork = _cart[index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: artwork['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  title: Text(artwork['title']),
                  subtitle: FutureBuilder<String>(
                    future: _getFormattedPrice(artwork['price']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return Text(snapshot.data ?? 'Loading...');
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_shopping_cart),
                    onPressed: () async {
                      _cartService.removeFromCart(artwork['id']);
                      await _loadCart();
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Collections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                final collection = _collections[index];
                return ListTile(
                  title: Text(collection['name']),
                  subtitle: Text('${collection['artworks'].length} artworks'),
                  onTap: () {
                    // Navigate to collection details
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 