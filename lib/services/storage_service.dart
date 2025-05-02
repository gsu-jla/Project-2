import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload Artwork Image
  Future<String> uploadArtworkImage(String userId, String filePath) async {
    final String fileName = 'artworks/$userId/${_uuid.v4()}.jpg';
    final Reference ref = _storage.ref().child(fileName);
    
    final UploadTask uploadTask = ref.putFile(File(filePath));
    final TaskSnapshot snapshot = await uploadTask;
    
    return await snapshot.ref.getDownloadURL();
  }

  // Delete Artwork Image
  Future<void> deleteArtworkImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Upload Profile Image
  Future<String> uploadProfileImage(String userId, String filePath) async {
    final String fileName = 'profiles/$userId/profile.jpg';
    final Reference ref = _storage.ref().child(fileName);
    
    final UploadTask uploadTask = ref.putFile(File(filePath));
    final TaskSnapshot snapshot = await uploadTask;
    
    return await snapshot.ref.getDownloadURL();
  }

  // Delete Profile Image
  Future<void> deleteProfileImage(String userId) async {
    try {
      final String fileName = 'profiles/$userId/profile.jpg';
      final Reference ref = _storage.ref().child(fileName);
      await ref.delete();
    } catch (e) {
      print('Error deleting profile image: $e');
    }
  }
} 