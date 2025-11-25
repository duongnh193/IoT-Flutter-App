import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';

class EnergyBreakdown {
  const EnergyBreakdown({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class AnalysisStats {
  const AnalysisStats({
    required this.monthLabel,
    required this.totalEnergyKwh,
    required this.totalCost,
    required this.deltaCost,
    required this.isDecrease,
    required this.breakdown,
  });

  final String monthLabel;
  final double totalEnergyKwh;
  final double totalCost;
  final double deltaCost;
  final bool isDecrease;
  final List<EnergyBreakdown> breakdown;
}

final analysisProvider = Provider<AnalysisStats>((ref) {
  return const AnalysisStats(
    monthLabel: 'Tháng 11',
    totalEnergyKwh: 83,
    totalCost: 900000,
    deltaCost: 115000,
    isDecrease: true,
    breakdown: [
      EnergyBreakdown(
        label: 'Quạt',
        value: 67,
        color: AppColors.chartCyan,
      ),
      EnergyBreakdown(
        label: 'Đèn',
        value: 27,
        color: AppColors.chartOrange,
      ),
      EnergyBreakdown(
        label: 'Khác',
        value: 11,
        color: AppColors.chartPurple,
      ),
      EnergyBreakdown(
        label: 'Máy lọc không khí',
        value: 21,
        color: AppColors.chartPink,
      ),
    ],
  );
});
