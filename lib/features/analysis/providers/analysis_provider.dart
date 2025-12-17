import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/energy_firestore_datasource.dart';
import '../data/models/energy_model.dart';

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

/// Provider for EnergyFirestoreDataSource
final energyFirestoreDataSourceProvider = Provider<EnergyFirestoreDataSource>((ref) {
  return EnergyFirestoreDataSource();
});

/// Provider for selected month ID (null = latest/current month)
/// Format: "YYYY_MM" (e.g., "2026_01")
final selectedMonthIdProvider = StateProvider<String?>((ref) {
  return null; // null means use latest month
});

/// Stream provider that automatically updates when new documents are added to Firestore
/// Gets data for selected month (or latest if null) and compares with previous month
final analysisProvider = StreamProvider<AnalysisStats>((ref) async* {
  final datasource = ref.watch(energyFirestoreDataSourceProvider);
  final selectedMonthId = ref.watch(selectedMonthIdProvider);
  
  EnergyDocument? currentDoc;
  
  if (selectedMonthId == null) {
    // Use latest month - watch stream
    await for (final latestDoc in datasource.watchLatestEnergy()) {
      currentDoc = latestDoc;
      
      if (currentDoc == null) {
        yield const AnalysisStats(
          monthLabel: 'Chưa có dữ liệu',
          totalEnergyKwh: 0,
          totalCost: 0,
          deltaCost: 0,
          isDecrease: false,
          breakdown: [],
        );
        continue;
      }

      try {
        final currentMonth = EnergyModel.fromFirestore(currentDoc.data, currentDoc.id);
        EnergyModel? previousMonth;
        try {
          final previousMonthDoc = await datasource.getPreviousMonth(currentDoc.id);
          if (previousMonthDoc != null) {
            previousMonth = EnergyModel.fromFirestore(previousMonthDoc.data, previousMonthDoc.id);
          }
        } catch (e) {
          previousMonth = null;
        }
        yield currentMonth.toAnalysisStats(previousMonth);
      } catch (e) {
        yield AnalysisStats(
          monthLabel: 'Lỗi khi tải dữ liệu',
          totalEnergyKwh: 0,
          totalCost: 0,
          deltaCost: 0,
          isDecrease: false,
          breakdown: [],
        );
      }
    }
  } else {
    // Get specific month
    currentDoc = await datasource.getEnergyByMonth(selectedMonthId);
    
    if (currentDoc == null) {
      yield const AnalysisStats(
        monthLabel: 'Chưa có dữ liệu',
        totalEnergyKwh: 0,
        totalCost: 0,
        deltaCost: 0,
        isDecrease: false,
        breakdown: [],
      );
      return;
    }

    try {
      final currentMonth = EnergyModel.fromFirestore(currentDoc.data, currentDoc.id);
      EnergyModel? previousMonth;
      try {
        final previousMonthDoc = await datasource.getPreviousMonth(currentDoc.id);
        if (previousMonthDoc != null) {
          previousMonth = EnergyModel.fromFirestore(previousMonthDoc.data, previousMonthDoc.id);
        }
      } catch (e) {
        previousMonth = null;
      }
      yield currentMonth.toAnalysisStats(previousMonth);
    } catch (e) {
      yield AnalysisStats(
        monthLabel: 'Lỗi khi tải dữ liệu',
        totalEnergyKwh: 0,
        totalCost: 0,
        deltaCost: 0,
        isDecrease: false,
        breakdown: [],
      );
    }
  }
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
      EnergyPoint(label: 'Tháng 1', kwh: 2.5),
      EnergyPoint(label: 'Tháng 2', kwh: 3.0),
      EnergyPoint(label: 'Tháng 3', kwh: 2.8),
      EnergyPoint(label: 'Tháng 4', kwh: 4.2),
      EnergyPoint(label: 'Tháng 5', kwh: 5.5),
      EnergyPoint(label: 'Tháng 6', kwh: 6.0),
      EnergyPoint(label: 'Tháng 7', kwh: 7.2),
      EnergyPoint(label: 'Tháng 8', kwh: 8.5),
      EnergyPoint(label: 'Tháng 9', kwh: 6.8),
      EnergyPoint(label: 'Tháng 10', kwh: 4.5),
      EnergyPoint(label: 'Tháng 11', kwh: 3.8),
      EnergyPoint(label: 'Tháng 12', kwh: 2.2),
    ],
    totalEnergy: 900,
    totalCost: 12000000,
  ),
};

final analysisDetailProvider = Provider<AnalysisDetailData>((ref) {
  final period = ref.watch(analysisPeriodProvider);
  return _sampleDetailData[period]!;
});
