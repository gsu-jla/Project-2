import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/art_service.dart';
import '../../services/search_service.dart';
import '../../services/favorite_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final ArtService _artService;
  late final SearchService _searchService;
  late final FavoriteService _favoriteService;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _artworks = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _artService = await ArtService.create();
    _searchService = await SearchService.create();
    _favoriteService = await FavoriteService.create();
    _loadArtworks();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = _searchService.getRecentSearches();
    });
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
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = _searchService.searchArtworks(_artworks, query);
    });
    _searchService.addRecentSearch(query);
    _loadRecentSearches();
  }

  void _clearRecentSearches() async {
    await _searchService.clearRecentSearches();
    _loadRecentSearches();
  }

  void _toggleFavorite(int artworkId) {
    setState(() {
      _favoriteService.toggleFavorite(artworkId);
    });
  }

  bool _isFavorite(int artworkId) {
    return _favoriteService.isFavorite(artworkId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[100],
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          decoration: InputDecoration(
            hintText: 'Search artworks...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[600]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
              ? _recentSearches.isEmpty
                  ? const Center(
                      child: Text(
                        'Search for artworks by title, artist, or description',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Searches',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _clearRecentSearches,
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recentSearches.length,
                            itemBuilder: (context, index) {
                              final search = _recentSearches[index];
                              return ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(search),
                                onTap: () {
                                  _searchController.text = search;
                                  _performSearch(search);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No artworks found',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final artwork = _searchResults[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
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
                                    errorWidget: (context, url, error) => const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  ),
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
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          artwork['price'],
                                          style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                _isFavorite(artwork['id'])
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 20,
                                                color: _isFavorite(artwork['id'])
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              onPressed: () => _toggleFavorite(artwork['id']),
                                            ),
                                            Text(
                                              artwork['likes'].toString(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
} 