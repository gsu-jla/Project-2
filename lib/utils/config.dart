class Config {
  // API Keys
  static const String pixabayApiKey = '50050223-f0431e0820c919b959d1400d4';
  static const String currencyLayerApiKey = 'YOUR_CURRENCY_LAYER_API_KEY';

  // Firebase Configuration
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_FIREBASE_MESSAGING_SENDER_ID';
  static const String firebaseStorageBucket = 'YOUR_FIREBASE_STORAGE_BUCKET';

  // App Configuration
  static const String appName = 'Digital Art Marketplace';
  static const String appVersion = '1.0.0';
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
    'INR',
  ];

  // Art Categories
  static const List<String> artCategories = [
    'Digital Art',
    'Photography',
    'Illustration',
    '3D Art',
    'Vector Art',
    'Pixel Art',
    'Concept Art',
    'Character Design',
    'Environment Design',
    'Other',
  ];

  // Art Styles
  static const List<String> artStyles = [
    'Realistic',
    'Abstract',
    'Cartoon',
    'Anime',
    'Fantasy',
    'Sci-Fi',
    'Minimalist',
    'Surreal',
    'Pop Art',
    'Other',
  ];
} 