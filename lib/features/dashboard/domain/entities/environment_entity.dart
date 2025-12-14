/// Domain Entity for Environment Sensor Data
/// Represents the core business object for environment readings
class EnvironmentEntity {
  const EnvironmentEntity({
    this.temperature,
    this.humidity,
    this.airQuality,
    this.lightLevel,
  });

  final double? temperature; // Celsius
  final double? humidity; // Percentage (0-100)
  final String? airQuality; // e.g., "good", "fair", "poor"
  final String? lightLevel; // e.g., "bright", "normal", "dim"

  EnvironmentEntity copyWith({
    double? temperature,
    double? humidity,
    String? airQuality,
    String? lightLevel,
  }) {
    return EnvironmentEntity(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      airQuality: airQuality ?? this.airQuality,
      lightLevel: lightLevel ?? this.lightLevel,
    );
  }
}
