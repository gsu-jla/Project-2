import 'dart:convert';
import 'package:http/http.dart' as http;

class ArtService {
  static const String _baseUrl = 'https://pixabay.com/api/';
  static const String _apiKey = '50050223-f0431e0820c919b959d1400d4';

  Future<List<Map<String, dynamic>>> getArtworks() async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey&q=digital+art&image_type=photo&per_page=20');
      print('Fetching artworks from: $url');
      
      final response = await http.get(url);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['hits'] == null) {
          throw Exception('No artworks found in response');
        }
        
        final List<dynamic> hits = data['hits'];
        if (hits.isEmpty) {
          throw Exception('No artworks found');
        }
        
        return hits.map((hit) {
          return {
            'id': hit['id'],
            'title': hit['tags'].split(',')[0],
            'artist': 'Pixabay Artist',
            'price': '\$${(hit['id'] % 100 + 50).toStringAsFixed(2)}',
            'imageUrl': hit['webformatURL'],
            'likes': hit['likes'],
            'downloads': hit['downloads'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load artworks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching artworks: $e');
      rethrow;
    }
  }
} 