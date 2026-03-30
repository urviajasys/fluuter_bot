class AppConfig {
  static const backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://darkorchid-grouse-760106.hostingersite.com/laravel_backend/public',
  );
}
