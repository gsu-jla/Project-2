import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArtService {
  static const String _baseUrl = 'https://pixabay.com/api/';
  static const String _apiKey = '50050223-f0431e0820c919b959d1400d4';
  static const String _artworksKey = 'artworks';
  static const String _artworksLoadedKey = 'artworks_loaded';
  final SharedPreferences _prefs;

  ArtService._(this._prefs);

  static Future<ArtService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = ArtService._(prefs);
    await service._ensureArtworksLoaded();
    return service;
  }

  Future<void> _ensureArtworksLoaded() async {
    final artworksLoaded = _prefs.getBool(_artworksLoadedKey) ?? false;
    if (!artworksLoaded) {
      await _loadInitialArtworks();
      await _prefs.setBool(_artworksLoadedKey, true);
    }
  }

  Future<void> _loadInitialArtworks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?key=$_apiKey&category=art&per_page=20'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hits = data['hits'] as List;
        final artworks = hits.map((hit) {
          // Generate a random price between 10 and 1000
          final price = (hit['id'] % 990 + 10).toDouble();
          return {
            'id': hit['id'] as int,
            'title': hit['tags'] ?? 'Untitled',
            'price': price,
            'description': hit['tags'] ?? 'No description available',
            'imageUrl': hit['webformatURL'],
            'artist': 'Pixabay Artist',
            'likes': hit['likes'] ?? 0,
          };
        }).toList();

        // Store the artworks
        await _prefs.setStringList(
          _artworksKey,
          artworks.map((artwork) => jsonEncode(artwork)).toList(),
        );
        print('Loaded ${artworks.length} initial artworks');
      }
    } catch (e) {
      print('Error loading initial artworks: $e');
    }
  }

  Future<void> uploadArtwork({
    required String title,
    required String price,
    required String description,
    required File imageFile,
  }) async {
    final artworks = _prefs.getStringList(_artworksKey) ?? [];
    final newArtwork = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'price': double.parse(price.replaceAll(RegExp(r'[^0-9.]'), '')),
      'description': description,
      'imageUrl': 'https://picsum.photos/800/600?random=${DateTime.now().millisecondsSinceEpoch}',
      'artist': 'Demo Artist',
      'likes': 0,
    };
    artworks.add(jsonEncode(newArtwork));
    await _prefs.setStringList(_artworksKey, artworks);
  }

  Future<List<Map<String, dynamic>>> getArtworks() async {
    final artworks = _prefs.getStringList(_artworksKey);
    
    if (artworks == null || artworks.isEmpty) {
      print('No artworks found, loading initial artworks');
      await _loadInitialArtworks();
      return getArtworks(); // Recursively call to get the newly loaded artworks
    }

    final decodedArtworks = artworks.map((artwork) {
      final decoded = jsonDecode(artwork) as Map<String, dynamic>;
      // Ensure ID is an int
      if (decoded['id'] is String) {
        decoded['id'] = int.parse(decoded['id']);
      } else if (decoded['id'] is double) {
        decoded['id'] = decoded['id'].toInt();
      }
      // Ensure price is a double
      if (decoded['price'] is String) {
        decoded['price'] = double.parse(decoded['price'].replaceAll(RegExp(r'[^0-9.]'), ''));
      }
      return decoded;
    }).toList();

    print('Retrieved ${decodedArtworks.length} artworks');
    return decodedArtworks;
  }

  // Add a method to clear all data (for testing)
  Future<void> clearAllData() async {
    await _prefs.remove(_artworksKey);
    await _prefs.remove(_artworksLoadedKey);
    print('Cleared all artwork data');
  }
} 