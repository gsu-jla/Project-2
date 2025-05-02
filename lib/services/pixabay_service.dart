import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config.dart';

class PixabayService {
  final String _apiKey = Config.pixabayApiKey;
  final String _baseUrl = 'https://pixabay.com/api/';

  // Test API Connection
  Future<bool> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?key=$_apiKey&q=test'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['totalHits'] != null;
      }
      return false;
    } catch (e) {
      print('Error testing API connection: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchImages({
    required String query,
    String category = 'art',
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?key=$_apiKey&q=$query&category=$category&per_page=$perPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['hits']);
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Error fetching Pixabay images: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPopularArtworks({
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?key=$_apiKey&category=art&order=popular&per_page=$perPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['hits']);
      } else {
        throw Exception('Failed to load popular artworks');
      }
    } catch (e) {
      print('Error fetching popular artworks: $e');
      return [];
    }
  }
} 