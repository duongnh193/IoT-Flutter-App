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

enum AnalysisPeriod { week, month, year }

class EnergyPoint {
  const EnergyPoint({required this.label, required this.kwh});

  final String label;
  final double kwh;
}

class AnalysisDetailData {
  const AnalysisDetailData({
    required this.period,
    required this.points,
    required this.totalEnergy,
    required this.totalCost,
  });

  final AnalysisPeriod period;
  final List<EnergyPoint> points;
  final double totalEnergy;
  final double totalCost;
}

final analysisPeriodProvider = StateProvider<AnalysisPeriod>((ref) {
  return AnalysisPeriod.week;
});

final _sampleDetailData = {
  AnalysisPeriod.week: AnalysisDetailData(
    period: AnalysisPeriod.week,
    points: [
      EnergyPoint(label: 'Thứ 2', kwh: 2),
      EnergyPoint(label: 'Thứ 3', kwh: 4.5),
      EnergyPoint(label: 'Thứ 4', kwh: 3),
      EnergyPoint(label: 'Thứ 5', kwh: 8),
      EnergyPoint(label: 'Thứ 6', kwh: 1),
      EnergyPoint(label: 'Thứ 7', kwh: 6),
      EnergyPoint(label: 'Chủ nhật', kwh: 5),
    ],
    totalEnergy: 18,
    totalCost: 120000,
  ),
  AnalysisPeriod.month: AnalysisDetailData(
    period: AnalysisPeriod.month,
    points: [
      EnergyPoint(label: 'Tuần 1', kwh: 2),
      EnergyPoint(label: 'Tuần 2', kwh: 5),
      EnergyPoint(label: 'Tuần 3', kwh: 3),
      EnergyPoint(label: 'Tuần 4', kwh: 7),
    ],
    totalEnergy: 82,
    totalCost: 900000,
  ),
  AnalysisPeriod.year: AnalysisDetailData(
    period: AnalysisPeriod.year,
    points: [
      EnergyPoint(label: 'Tháng 6', kwh: 2),
      EnergyPoint(label: 'Tháng 7', kwh: 5),
      EnergyPoint(label: 'Tháng 8', kwh: 3),
      EnergyPoint(label: 'Tháng 9', kwh: 8),
      EnergyPoint(label: 'Tháng 10', kwh: 1.5),
      EnergyPoint(label: 'Tháng 11', kwh: 6),
    ],
    totalEnergy: 900,
    totalCost: 12000000,
  ),
};

final analysisDetailProvider = Provider<AnalysisDetailData>((ref) {
  final period = ref.watch(analysisPeriodProvider);
  return _sampleDetailData[period]!;
});
