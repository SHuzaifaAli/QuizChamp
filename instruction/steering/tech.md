# Technology Stack & Build System

## Framework & Language
- **Flutter SDK**: >=3.0.0 <4.0.0
- **Dart**: Latest stable version
- **Target Platforms**: Android & iOS

## Core Dependencies

### State Management & Architecture
- **flutter_bloc** (^8.1.3): BLoC pattern for state management
- **bloc** (^8.1.2): Core BLoC library
- **dartz** (^0.10.1): Functional programming utilities (Either, Option)
- **equatable** (^2.0.5): Value equality for entities and events

### Dependency Injection
- **get_it** (^7.6.4): Service locator for dependency injection

### Networking & Data
- **dio** (^5.3.3): HTTP client for API requests
- **hive** (^2.2.3) & **hive_flutter** (^1.1.0): Local storage/caching

### Authentication & Backend
- **google_sign_in** (^6.1.5): Google authentication
- **firebase_core** (^2.24.2): Firebase initialization
- **cloud_firestore** (^4.13.3): Cloud database
- **firebase_messaging** (^14.7.10): Push notifications
- **firebase_analytics** (^10.7.3): Analytics tracking

### UI & Animations
- **lottie** (^2.7.0): Animation support
- **wakelock_plus** (^1.1.1): Screen wake management

### Monetization
- **google_mobile_ads** (^6.0.0): AdMob integration
- **in_app_purchase** (^3.2.3): In-app purchase handling

## Development Tools
- **flutter_lints** (^3.0.1): Dart/Flutter linting rules
- **build_runner** (^2.4.6): Code generation
- **hive_generator** (^2.0.1): Hive model generation

## Common Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on specific device
flutter run -d <device_id>

# Hot reload is available during development
```

### Code Generation
```bash
# Generate Hive adapters and other generated code
flutter packages pub run build_runner build

# Watch for changes and auto-generate
flutter packages pub run build_runner watch
```

### Testing & Analysis
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Check for outdated dependencies
flutter pub outdated
```

### Build & Release
```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android - recommended for Play Store)
flutter build appbundle --release

# Build iOS (requires Xcode)
flutter build ios --release
```

## External API
- **OpenTDB API**: https://opentdb.com/ - Source for trivia questions
- Base URL configured in Dio: `https://opentdb.com/`