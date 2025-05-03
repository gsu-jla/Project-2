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
  late final CartService _cartService;
  final UserPreferencesService _prefsService = UserPreferencesService();
  final CurrencyService _currencyService = CurrencyService();
  String _currentCurrency = 'USD';
  List<Map<String, dynamic>> _purchasedArtworks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _artService = await ArtService.create();
    _cartService = await CartService.create();
    await _loadPreferredCurrency();
    await _loadPurchasedArtworks();
  }

  Future<void> _loadPreferredCurrency() async {
    final currency = await _prefsService.getPreferredCurrency();
    setState(() {
      _currentCurrency = currency;
    });
  }

  Future<void> _loadPurchasedArtworks() async {
    try {
      final purchased = await _cartService.getPurchased();
      setState(() {
        _purchasedArtworks = purchased;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading purchased artworks: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Purchased Artworks',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_purchasedArtworks.isEmpty)
                          const Center(
                            child: Text('No purchased artworks yet'),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _purchasedArtworks.length,
                              itemBuilder: (context, index) {
                                final artwork = _purchasedArtworks[index];
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 