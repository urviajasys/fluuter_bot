# Flutter App

This is the Android-first Flutter source app for the stock algo bot.

## Current status

- Flutter source code is ready
- `android/` and `ios/` runner folders are not generated in this environment because Flutter SDK is not available here

## On your Flutter machine

Run:

```bash
cd flutter_app
flutter create .
flutter pub get
flutter run --dart-define=BACKEND_BASE_URL=https://darkorchid-grouse-760106.hostingersite.com/laravel_backend/public
```

Default backend URL is already set to the live Laravel server:

```text
https://darkorchid-grouse-760106.hostingersite.com/laravel_backend/public
```

## Main screen

- dashboard summary
- bot on/off
- risk settings
- strategy overview
