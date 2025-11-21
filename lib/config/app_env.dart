enum AppFlavor { dev, staging, prod }

class AppEnv {
  static const flavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'dev',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.smart-home.dev',
  );

  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'smart-home-demo',
  );

  static AppFlavor get flavorType {
    switch (flavor) {
      case 'staging':
        return AppFlavor.staging;
      case 'prod':
      case 'production':
        return AppFlavor.prod;
      default:
        return AppFlavor.dev;
    }
  }
}
