import 'app_env.dart';

class AppConfig {
  AppConfig({
    required this.baseUrl,
    required this.firebaseProjectId,
    required this.flavor,
  });

  final String baseUrl;
  final String firebaseProjectId;
  final AppFlavor flavor;

  static final AppConfig current = AppConfig(
    baseUrl: AppEnv.apiBaseUrl,
    firebaseProjectId: AppEnv.firebaseProjectId,
    flavor: AppEnv.flavorType,
  );
}
