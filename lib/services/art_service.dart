import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArtService {
  static const String _baseUrl = 'https://pixabay.com/api/';
  static const String _apiKey = '50050223-f0431e0820c919b959d1400d4';
  static const String _artworksKey = 'artworks';
  final SharedPreferences _prefs;

  ArtService._(this._prefs);

  static Future<ArtService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ArtService._(prefs);
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
          return {
            'id': hit['id'] as int,
            'title': hit['tags'] ?? 'Untitled',
            'price': '\$${(hit['id'] % 1000).toStringAsFixed(2)}',
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
    // For demo purposes, we'll just save the artwork details
    // In a real app, you would upload the image to a storage service
    // and save the URL along with other details
    final artworks = _prefs.getStringList(_artworksKey) ?? [];
    final newArtwork = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'price': price,
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
    
    // If no artworks exist, load initial artworks from Pixabay
    if (artworks == null || artworks.isEmpty) {
      await _loadInitialArtworks();
      return getArtworks(); // Recursively call to get the newly loaded artworks
    }

    return artworks.map((artwork) {
      final decoded = jsonDecode(artwork) as Map<String, dynamic>;
      // Ensure ID is an int
      if (decoded['id'] is String) {
        decoded['id'] = int.parse(decoded['id']);
      }
      return decoded;
    }).toList();
  }
} 