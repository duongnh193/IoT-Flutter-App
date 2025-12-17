import 'package:flutter/material.dart';

import '../../providers/analysis_provider.dart';
import '../../../../core/constants/app_colors.dart';

/// Model for energy data from Firestore
class EnergyModel {
  final String monthId; // e.g., "2026_02"
  final int month;
  final int year;
  final double totalKwh;
  final double totalCost;
  final Map<String, double> devices; // e.g., {"fan": 0.00259, "light": 0.00201, ...}
  final Map<String, double> dailyData; // e.g., {"15": 0.00225, "16": 0.00021, ...}

  EnergyModel({
    required this.monthId,
    required this.month,
    required this.year,
    required this.totalKwh,
    required this.totalCost,
    required this.devices,
    required this.dailyData,
  });

  /// Parse from Firestore document
  factory EnergyModel.fromFirestore(Map<String, dynamic> data, String docId) {
    // Parse devices map (convert values to double)
    final devicesMap = <String, double>{};
    if (data['devices'] != null && data['devices'] is Map) {
      final devicesData = data['devices'] as Map;
      devicesData.forEach((key, value) {
        if (value is num) {
          devicesMap[key.toString()] = value.toDouble();
        }
      });
    }

    // Parse daily_data map (convert values to double)
    final dailyDataMap = <String, double>{};
    if (data['daily_data'] != null && data['daily_data'] is Map) {
      final dailyDataRaw = data['daily_data'] as Map;
      dailyDataRaw.forEach((key, value) {
        if (value is num) {
          dailyDataMap[key.toString()] = value.toDouble();
        }
      });
    }

    return EnergyModel(
      monthId: docId,
      month: (data['month'] ?? 0) as int,
      year: (data['year'] ?? 0) as int,
      totalKwh: (data['total_kwh'] ?? 0.0).toDouble(),
      totalCost: (data['total_cost'] ?? 0.0).toDouble(),
      devices: devicesMap,
      dailyData: dailyDataMap,
    );
  }

  /// Convert to AnalysisStats
  AnalysisStats toAnalysisStats(EnergyModel? previousMonth) {
    // Format month label (e.g., "Tháng 2/2026")
    final monthLabel = month > 0 && year > 0
        ? 'Tháng $month/$year'
        : 'Tháng hiện tại';

    // Calculate delta from previous month
    double deltaCost = 0;
    bool isDecrease = false;
    if (previousMonth != null) {
      deltaCost = (totalCost - previousMonth.totalCost).abs();
      isDecrease = totalCost < previousMonth.totalCost;
    }

    // Convert devices breakdown to EnergyBreakdown list
    final breakdownList = devices.entries.map((entry) {
      return EnergyBreakdown(
        label: _formatDeviceName(entry.key),
        value: entry.value,
        color: _getColorForDevice(entry.key),
      );
    }).toList();

    // Convert kwh to wh (1 kwh = 1000 wh) for display
    final totalEnergyWh = totalKwh * 1000;

    return AnalysisStats(
      monthLabel: monthLabel,
      totalEnergyKwh: totalEnergyWh, // Actually stores wh value
      totalCost: totalCost,
      deltaCost: deltaCost,
      isDecrease: isDecrease,
      breakdown: breakdownList,
    );
  }

  /// Get color for device based on device key
  Color _getColorForDevice(String deviceKey) {
    final key = deviceKey.toLowerCase();
    if (key.contains('quat') || key.contains('fan')) return AppColors.chartCyan;
    if (key.contains('den') || key.contains('light')) return AppColors.chartOrange;
    if (key.contains('loc') || key.contains('purifier')) return AppColors.chartPink;
    if (key.contains('other') || key.contains('khac')) return AppColors.chartPurple;
    return AppColors.chartPurple; // Default
  }

  /// Format device name to Vietnamese
  String _formatDeviceName(String key) {
    final nameMap = {
      'quat': 'Quạt',
      'fan': 'Quạt',
      'den': 'Đèn',
      'light': 'Đèn',
      'loc': 'Máy lọc không khí',
      'purifier': 'Máy lọc không khí',
      'other': 'Khác',
      'others': 'Khác',
      'khac': 'Khác',
    };
    
    final lowerKey = key.toLowerCase();
    return nameMap[lowerKey] ?? key;
  }
}

