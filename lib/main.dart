import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/gallery/gallery_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/cart/shopping_cart_screen.dart';
import 'screens/upload/upload_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/signin',
      routes: {
        '/': (context) => const HomeScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/cart': (context) => const ShoppingCartScreen(),
        '/upload': (context) => const UploadScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
