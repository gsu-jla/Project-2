import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchService {
  static const String _recentSearchesKey = 'recent_searches';
  final SharedPreferences _prefs;

  SearchService._(this._prefs);

  static Future<SearchService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SearchService._(prefs);
  }

  List<String> getRecentSearches() {
    return _prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> addRecentSearch(String query) async {
    final searches = getRecentSearches();
    if (!searches.contains(query)) {
      searches.insert(0, query);
      if (searches.length > 10) {
        searches.removeLast();
      }
      await _prefs.setStringList(_recentSearchesKey, searches);
    }
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_recentSearchesKey);
  }

  List<Map<String, dynamic>> searchArtworks(
    List<Map<String, dynamic>> artworks,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();
    return artworks.where((artwork) {
      final title = artwork['title'].toString().toLowerCase();
      final artist = artwork['artist'].toString().toLowerCase();
      final description = artwork['description'].toString().toLowerCase();
      return title.contains(lowercaseQuery) ||
          artist.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }
} 