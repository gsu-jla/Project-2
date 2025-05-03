import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CollectionService {
  static const String _collectionsKey = 'collections';
  final SharedPreferences _prefs;

  CollectionService._(this._prefs);

  static Future<CollectionService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CollectionService._(prefs);
  }

  List<Map<String, dynamic>> getCollections() {
    final collectionsString = _prefs.getString(_collectionsKey);
    if (collectionsString == null) return [];
    return (jsonDecode(collectionsString) as List)
        .map((collection) => collection as Map<String, dynamic>)
        .toList();
  }

  Future<void> createCollection(String name) async {
    final collections = getCollections();
    final newCollection = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'artworkIds': <int>[],
      'createdAt': DateTime.now().toIso8601String(),
    };
    collections.add(newCollection);
    await _prefs.setString(_collectionsKey, jsonEncode(collections));
  }

  Future<void> addToCollection(int collectionId, int artworkId) async {
    final collections = getCollections();
    final collection = collections.firstWhere(
      (c) => c['id'] == collectionId,
      orElse: () => throw Exception('Collection not found'),
    );
    if (!collection['artworkIds'].contains(artworkId)) {
      collection['artworkIds'].add(artworkId);
      await _prefs.setString(_collectionsKey, jsonEncode(collections));
    }
  }

  Future<void> removeFromCollection(int collectionId, int artworkId) async {
    final collections = getCollections();
    final collection = collections.firstWhere(
      (c) => c['id'] == collectionId,
      orElse: () => throw Exception('Collection not found'),
    );
    collection['artworkIds'].remove(artworkId);
    await _prefs.setString(_collectionsKey, jsonEncode(collections));
  }

  Future<void> deleteCollection(int collectionId) async {
    final collections = getCollections();
    collections.removeWhere((c) => c['id'] == collectionId);
    await _prefs.setString(_collectionsKey, jsonEncode(collections));
  }

  Future<void> renameCollection(int collectionId, String newName) async {
    final collections = getCollections();
    final collection = collections.firstWhere(
      (c) => c['id'] == collectionId,
      orElse: () => throw Exception('Collection not found'),
    );
    collection['name'] = newName;
    await _prefs.setString(_collectionsKey, jsonEncode(collections));
  }
} 