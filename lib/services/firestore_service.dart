import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artwork.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Artwork Collection
  CollectionReference get _artworksCollection => _firestore.collection('artworks');

  // Create Artwork
  Future<void> createArtwork(Artwork artwork) async {
    await _artworksCollection.doc(artwork.id).set(artwork.toMap());
  }

  // Get Artwork by ID
  Future<Artwork?> getArtwork(String id) async {
    final doc = await _artworksCollection.doc(id).get();
    if (doc.exists) {
      return Artwork.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get All Artworks
  Stream<List<Artwork>> getArtworks() {
    return _artworksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Artwork.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get Artworks by Artist
  Stream<List<Artwork>> getArtworksByArtist(String artistId) {
    return _artworksCollection
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Artwork.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Update Artwork
  Future<void> updateArtwork(Artwork artwork) async {
    await _artworksCollection.doc(artwork.id).update(artwork.toMap());
  }

  // Delete Artwork
  Future<void> deleteArtwork(String id) async {
    await _artworksCollection.doc(id).delete();
  }

  // Search Artworks
  Stream<List<Artwork>> searchArtworks(String query) {
    return _artworksCollection
        .orderBy('title')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Artwork.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Filter Artworks by Category
  Stream<List<Artwork>> filterArtworksByCategory(String category) {
    return _artworksCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Artwork.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Filter Artworks by Style
  Stream<List<Artwork>> filterArtworksByStyle(String style) {
    return _artworksCollection
        .where('style', isEqualTo: style)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Artwork.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Update Artwork Views
  Future<void> incrementArtworkViews(String id) async {
    await _artworksCollection.doc(id).update({
      'views': FieldValue.increment(1),
    });
  }

  // Update Artwork Likes
  Future<void> incrementArtworkLikes(String id) async {
    await _artworksCollection.doc(id).update({
      'likes': FieldValue.increment(1),
    });
  }
} 