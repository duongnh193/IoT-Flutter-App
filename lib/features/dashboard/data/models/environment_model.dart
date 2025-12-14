import '../../domain/entities/environment_entity.dart';

/// Data Transfer Object (DTO) for Environment Sensor Data
/// Used for serialization/deserialization from Firebase
class EnvironmentModel {
  const EnvironmentModel({
    this.temperature,
    this.humidity,
    this.airQuality,
    this.lightLevel,
  });

  final double? temperature;
  final double? humidity;
  final String? airQuality;
  final String? lightLevel;

  /// Convert from Firebase data (Map)
  /// Firebase structure: { temp: 26, hum: 62, lux: 4 }
  factory EnvironmentModel.fromFirebase(Map<dynamic, dynamic> data) {
    // Handle temperature - check both 'temp' and 'temperature'
    double? temp;
    final tempValue = data['temp'] ?? data['temperature'];
    if (tempValue != null) {
      if (tempValue is int) {
        temp = tempValue.toDouble();
      } else if (tempValue is double) {
        temp = tempValue;
      } else if (tempValue is String) {
        temp = double.tryParse(tempValue);
      }
    }

    // Handle humidity - check both 'hum' and 'humidity'
    double? hum;
    final humValue = data['hum'] ?? data['humidity'];
    if (humValue != null) {
      if (humValue is int) {
        hum = humValue.toDouble();
      } else if (humValue is double) {
        hum = humValue;
      } else if (humValue is String) {
        hum = double.tryParse(humValue);
      }
    }

    // Handle air quality from living_room/env
    // Mapping: 0 = "Trong lành", 1 = "Bình thường", 2 = "Ô nhiễm", 3 = "Nguy hiểm"
    String? air;
    final airValue = data['air_quality'] ?? 
                     data['airQuality'] ?? 
                     data['air_quality_index'] ??
                     data['aqi'];
    if (airValue != null) {
      if (airValue is String) {
        air = airValue;
      } else if (airValue is int) {
        // Map int to quality level according to user's specification
        switch (airValue) {
          case 0:
            air = 'Trong lành';
            break;
          case 1:
            air = 'Bình thường';
            break;
          case 2:
            air = 'Ô nhiễm';
            break;
          case 3:
            air = 'Nguy hiểm';
            break;
          default:
            air = 'Bình thường'; // Default fallback for unknown values
        }
      }
    } else {
      // If no air quality data, set default
      air = 'Trong lành'; // Default fallback
    }

    // Handle light level - check 'lux', 'light_level', 'lightLevel'
    String? light;
    final lightValue = data['lux'] ?? 
                       data['light_level'] ?? 
                       data['lightLevel'];
    if (lightValue != null) {
      if (lightValue is String) {
        light = lightValue;
      } else if (lightValue is int || lightValue is double) {
        final lightNum = lightValue is int ? lightValue.toDouble() : lightValue;
        // Map lux values to text (lux is illuminance in lux units)
        // Typical indoor: 100-1000 lux, bright office: 1000+, dim: <100
        if (lightNum >= 1000) {
          light = 'Rất sáng';
        } else if (lightNum >= 500) {
          light = 'Đủ sáng';
        } else if (lightNum >= 100) {
          light = 'Bình thường';
        } else if (lightNum >= 10) {
          light = 'Hơi tối';
        } else {
          light = 'Thiếu sáng';
        }
      }
    }

    return EnvironmentModel(
      temperature: temp,
      humidity: hum,
      airQuality: air,
      lightLevel: light,
    );
  }

  /// Convert to Domain Entity
  EnvironmentEntity toEntity() {
    return EnvironmentEntity(
      temperature: temperature,
      humidity: humidity,
      airQuality: airQuality,
      lightLevel: lightLevel,
    );
  }

  /// Create from Domain Entity
  factory EnvironmentModel.fromEntity(EnvironmentEntity entity) {
    return EnvironmentModel(
      temperature: entity.temperature,
      humidity: entity.humidity,
      airQuality: entity.airQuality,
      lightLevel: entity.lightLevel,
    );
  }
}

