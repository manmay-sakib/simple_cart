# CartBuddy

A Flutter-based shopping app for managing products, favorites, and cart items.

## Setup Steps

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) or VS Code with Flutter & Dart plugins
- [Xcode](https://developer.apple.com/xcode/) (for iOS development on macOS)
- A connected device or emulator/simulator

Verify setup:

```bash
flutter doctor
git clone <your-repo-url>
cd CartBuddy
flutter pub get
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons:main
flutter run
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter test
```


## Architecture Overview


```bash

├───android
├───ios
├───lib
│   ├───application
│   │   ├───router
│   ├───core
│   │   ├───constants
│   │   ├───errors
│   │   ├───providers
│   ├───features
│       └───example
│           ├───data
│           │   ├───entities
│           │   ├───repositories
│           │   └───services
│           ├───domain
│           │   ├───models
│           │   ├───repositories
│           │   └───usecases
│           └───presentation
│               ├───components
│               ├───screens
│               ├───states
│               └───viewmodels
│   
└───test

```

## Features Implemented
- Browse products with pagination
- View product details
- Add/remove items from cart
- Mark/unmark favorites
- Offline support with cached data
- Search products

## Known Issues
- Some tests may fail if SharedPreferences is not mocked correctly
- Offline data sync may fail if the cache is corrupted

## Screenshots / Demo
![Product List](screenshots/product_list.png)
![Cart](screenshots/cart.png)
[Demo Video](link-to-demo-video)
