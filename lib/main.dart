import 'package:flutter/material.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/gallery/gallery_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/cart/shopping_cart_screen.dart';
import 'screens/artwork/upload_artwork_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Art Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/cart': (context) => const ShoppingCartScreen(),
        '/upload': (context) => const UploadArtworkScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
