import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorites';
  final Set<int> _favorites = {};
  final SharedPreferences _prefs;

  FavoriteService._(this._prefs) {
    // Load favorites from storage
    final favoritesString = _prefs.getString(_favoritesKey);
    if (favoritesString != null) {
      _favorites.addAll(favoritesString.split(',').map(int.parse));
    }
  }

  static Future<FavoriteService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoriteService._(prefs);
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

  void _saveFavorites() {
    _prefs.setString(_favoritesKey, _favorites.join(','));
  }
} 