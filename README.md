# Digital Art Marketplace

A virtual marketplace platform for digital artists and art enthusiasts built with Flutter and Firebase.

## Features

- **Art Uploads**: Artists can post their artwork with descriptions and prices
- **User Profiles**: Separate dashboards for artists and buyers
- **Real-time Chat**: Direct messaging between artists and buyers
- **Advanced Search**: Filter art by category, style, and price range
- **Purchase System**: Integrated checkout with currency conversion
- **Collections**: Buyers can favorite art and create personal galleries

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **APIs**:
  - Pixabay API (for art inspirations)
  - CurrencyLayer API (for pricing conversion)

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your Firebase configuration files
   - Set up API keys for Pixabay and CurrencyLayer
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Firebase and API services
├── widgets/        # Reusable UI components
├── utils/          # Helper functions and constants
└── main.dart       # Entry point
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
