import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/art_service.dart';
import '../../services/favorite_service.dart';
import '../../services/cart_service.dart';
import '../../services/collection_service.dart';
import '../../services/user_preferences_service.dart';
import '../../services/currency_service.dart';
import '../../utils/currency_utils.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ArtService _artService;
  late final FavoriteService _favoriteService;
  late final CartService _cartService;
  late final CollectionService _collectionService;
  late final UserPreferencesService _prefsService;
  late final CurrencyService _currencyService;
  List<Map<String, dynamic>> _artworks = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  String _currentCurrency = 'USD';

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
    _prefsService = UserPreferencesService();
    _currencyService = CurrencyService();
    _loadPreferredCurrency();
    _loadArtworks();
  }

  Future<void> _loadPreferredCurrency() async {
    final currency = await _prefsService.getPreferredCurrency();
    setState(() {
      _currentCurrency = currency;
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

  Future<void> _loadArtworks() async {
    try {
      final artworks = await _artService.getArtworks();
      setState(() {
        _artworks = artworks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadArtworks();
              },
            ),
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 1: // Gallery
        Navigator.pushNamed(context, '/gallery');
        break;
      case 2: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
      case 3: // Settings
        Navigator.pushNamed(context, '/settings');
        break;
      default:
        setState(() {
          _selectedIndex = index;
        });
    }
  }

  void _toggleFavorite(int artworkId) {
    setState(() {
      _favoriteService.toggleFavorite(artworkId);
    });
  }

  bool _isFavorite(int artworkId) {
    return _favoriteService.isFavorite(artworkId);
  }

  bool _isPurchased(int artworkId) {
    return _cartService.isInCart(artworkId);
  }

  Future<void> _showPurchaseDialog(Map<String, dynamic> artwork) async {
    final formattedPrice = await _getFormattedPrice(artwork['price']);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Artwork'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${artwork['title']}'),
            Text('Artist: ${artwork['artist']}'),
            Text('Price: $formattedPrice'),
            const SizedBox(height: 16),
            const Text('Are you sure you want to purchase this artwork?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _cartService.addToCart(artwork['id']);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase successful!'),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {}); // Refresh the UI
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(Map<String, dynamic> artwork) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CachedNetworkImage(
                imageUrl: artwork['imageUrl'],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCollection(Map<String, dynamic> artwork) async {
    final collections = _collectionService.getCollections();
    if (collections.isEmpty) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Collections'),
          content: const Text('Would you like to create a new collection?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        ),
      );

      if (result == true) {
        final nameController = TextEditingController();
        final name = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Create Collection'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, nameController.text),
                child: const Text('Create'),
              ),
            ],
          ),
        );

        if (name != null && name.isNotEmpty) {
          await _collectionService.createCollection(name);
          await _collectionService.addToCollection(
            DateTime.now().millisecondsSinceEpoch,
            artwork['id'],
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to new collection')),
            );
          }
        }
      }
    } else {
      final selectedCollection = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add to Collection'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return ListTile(
                  title: Text(collection['name']),
                  subtitle: Text('${collection['artworkIds'].length} artworks'),
                  onTap: () => Navigator.pop(context, collection),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final nameController = TextEditingController();
                showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Create New Collection'),
                    content: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Collection Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, nameController.text),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                ).then((name) async {
                  if (name != null && name.isNotEmpty) {
                    await _collectionService.createCollection(name);
                    await _collectionService.addToCollection(
                      DateTime.now().millisecondsSinceEpoch,
                      artwork['id'],
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to new collection')),
                      );
                    }
                  }
                });
              },
              child: const Text('New Collection'),
            ),
          ],
        ),
      );

      if (selectedCollection != null) {
        await _collectionService.addToCollection(
          selectedCollection['id'],
          artwork['id'],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to ${selectedCollection['name']}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade100,
        elevation: 0,
        title: const Text(
          'Art Gallery',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black87),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _artworks.length,
              itemBuilder: (context, index) {
                final artwork = _artworks[index];
                return Card(
                  elevation: 4,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showImagePreview(artwork),
                          child: Hero(
                            tag: 'artwork_${artwork['id']}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: artwork['imageUrl'],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                            const SizedBox(height: 4),
                            Text(
                              artwork['artist'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: FutureBuilder<String>(
                                      future: _getFormattedPrice(artwork['price']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        }
                                        return Text(
                                          snapshot.data ?? '\$${artwork['price'].toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.deepPurple.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        _isFavorite(artwork['id'])
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 18,
                                        color: _isFavorite(artwork['id'])
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () => _toggleFavorite(artwork['id']),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.collections,
                                        size: 18,
                                        color: Colors.deepPurple,
                                      ),
                                      onPressed: () => _addToCollection(artwork),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        artwork['likes'].toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!_isPurchased(artwork['id']))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showPurchaseDialog(artwork),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Buy Now',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (_isPurchased(artwork['id']))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Purchased',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/upload'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
} 