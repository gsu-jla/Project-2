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

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  late final ArtService _artService;
  late final CartService _cartService;
  final UserPreferencesService _prefsService = UserPreferencesService();
  final CurrencyService _currencyService = CurrencyService();
  String _currentCurrency = 'USD';
  List<Map<String, dynamic>> _purchasedArtworks = [];
  bool _isLoading = true;
  bool _servicesInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      _artService = await ArtService.create();
      _cartService = await CartService.create();
      await _loadPreferredCurrency();
      setState(() {
        _servicesInitialized = true;
      });
      await _loadPurchasedArtworks();
    } catch (e) {
      print('Error initializing services: $e');
      _showErrorSnackBar('Error initializing services: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPreferredCurrency() async {
    final currency = await _prefsService.getPreferredCurrency();
    setState(() {
      _currentCurrency = currency;
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  Future<void> _loadPurchasedArtworks() async {
    if (!_servicesInitialized) {
      print('Services not initialized yet');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      
      // Debug: Print purchased IDs from CartService
      print('Purchased IDs from CartService: ${_cartService.purchased}');
      
      final purchased = await _cartService.getPurchased();
      print('Loaded ${purchased.length} purchased artworks');
      print('Purchased artwork IDs: ${purchased.map((a) => a['id']).toList()}');
      
      if (mounted) {
        setState(() {
          _purchasedArtworks = purchased;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading purchased artworks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Error loading purchased artworks: ${e.toString()}');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_servicesInitialized) {
      _loadPurchasedArtworks();
    }
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_servicesInitialized) {
      _loadPurchasedArtworks();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _servicesInitialized) {
      _loadPurchasedArtworks();
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
    super.build(context);
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _purchasedArtworks.length,
                            itemBuilder: (context, index) {
                              final artwork = _purchasedArtworks[index];
                              print('Displaying artwork: ${artwork['title']} (ID: ${artwork['id']})');
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: artwork['imageUrl'],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              artwork['title'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
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
                                                    color: Colors.deepPurple,
                                                    fontSize: 16,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 