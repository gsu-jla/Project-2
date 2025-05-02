import 'package:cloud_firestore/cloud_firestore.dart';

class Artwork {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String artistId;
  final String artistName;
  final String category;
  final String style;
  final DateTime createdAt;
  final bool isAvailable;
  final List<String> tags;
  final int likes;
  final int views;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.artistId,
    required this.artistName,
    required this.category,
    required this.style,
    required this.createdAt,
    this.isAvailable = true,
    this.tags = const [],
    this.likes = 0,
    this.views = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'artistId': artistId,
      'artistName': artistName,
      'category': category,
      'style': style,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAvailable': isAvailable,
      'tags': tags,
      'likes': likes,
      'views': views,
    };
  }

  factory Artwork.fromMap(Map<String, dynamic> map) {
    return Artwork(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      artistId: map['artistId'] ?? '',
      artistName: map['artistName'] ?? '',
      category: map['category'] ?? '',
      style: map['style'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isAvailable: map['isAvailable'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
      likes: map['likes'] ?? 0,
      views: map['views'] ?? 0,
    );
  }
} 