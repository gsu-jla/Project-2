import 'package:shared_preferences/shared_preferences.dart';
import 'art_service.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorites';
  final Set<int> _favorites = {};
  final SharedPreferences _prefs;
  late final ArtService _artService;

  FavoriteService._(this._prefs) {
    // Load favorites from storage
    final favoritesString = _prefs.getString(_favoritesKey);
    if (favoritesString != null) {
      _favorites.addAll(favoritesString.split(',').map(int.parse));
    }
  }

  static Future<FavoriteService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = FavoriteService._(prefs);
    service._artService = await ArtService.create();
    return service;
  }

  bool isFavorite(int artworkId) {
    return _favorites.contains(artworkId);
  }

  void toggleFavorite(int artworkId) {
    if (_favorites.contains(artworkId)) {
      _favorites.remove(artworkId);
    } else {
      _favorites.add(artworkId);
    }
    _saveFavorites();
  }

  Set<int> get favorites => _favorites;

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final artworks = await _artService.getArtworks();
    return artworks.where((artwork) => _favorites.contains(artwork['id'])).toList();
  }

  void _saveFavorites() {
    _prefs.setString(_favoritesKey, _favorites.join(','));
  }
} 