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

/// Provider for selected month ID for detail view (null = latest/current month)
final selectedDetailMonthIdProvider = StateProvider<String?>((ref) {
  return null; // null means use latest month
});

/// Helper function to split daily_data into weeks
/// Returns list of EnergyPoint for each week (max 4 weeks)
List<EnergyPoint> _splitDailyDataIntoWeeks(Map<String, double> dailyData, int year, int month) {
  if (dailyData.isEmpty) {
    return List.generate(4, (i) => EnergyPoint(label: 'Tuần ${i + 1}', kwh: 0));
  }
  
  // Get all days and sort them
  final sortedDays = dailyData.keys
      .map((d) => int.tryParse(d) ?? 0)
      .where((d) => d > 0 && d <= 31)
      .toList()
    ..sort();
  
  if (sortedDays.isEmpty) {
    return List.generate(4, (i) => EnergyPoint(label: 'Tuần ${i + 1}', kwh: 0));
  }
  
  // Group days into weeks (7 days per week)
  final weeks = <List<int>>[];
  for (int i = 0; i < sortedDays.length; i += 7) {
    final weekDays = sortedDays.skip(i).take(7).toList();
    if (weekDays.isNotEmpty) {
      weeks.add(weekDays);
    }
  }
  
  // Convert to EnergyPoint list
  final points = <EnergyPoint>[];
  for (int i = 0; i < weeks.length && i < 4; i++) {
    double weekTotal = 0;
    for (final day in weeks[i]) {
      weekTotal += dailyData[day.toString()] ?? 0;
    }
    points.add(EnergyPoint(label: 'Tuần ${i + 1}', kwh: weekTotal));
  }
  
  // Pad with empty weeks if less than 4
  while (points.length < 4) {
    points.add(EnergyPoint(label: 'Tuần ${points.length + 1}', kwh: 0));
  }
  
  return points;
}

/// Helper function to group daily_data by weeks for month view
List<EnergyPoint> _groupDailyDataByWeeks(Map<String, double> dailyData, int year, int month) {
  return _splitDailyDataIntoWeeks(dailyData, year, month);
}

/// Helper function to parse monthly_data from energy_summary
/// monthly_data format: {11: 303, 12: 0.00918, 01: 123, 02: 12, ...}
List<EnergyPoint> _parseMonthlyData(Map<String, dynamic>? monthlyData) {
  if (monthlyData == null || monthlyData.isEmpty) {
    return List.generate(12, (i) => EnergyPoint(label: 'Tháng ${i + 1}', kwh: 0));
  }
  
  final points = <EnergyPoint>[];
  
  // Parse all months (keys can be strings or numbers)
  final monthValues = <int, double>{};
  monthlyData.forEach((key, value) {
    int? month;
    if (key is int) {
      month = key as int;
    } else {
      final keyStr = key.toString();
      month = int.tryParse(keyStr);
    }
    
    if (month != null && month >= 1 && month <= 12) {
      double? kwh;
      if (value is num) {
        kwh = value.toDouble();
      } else if (value is String) {
        kwh = double.tryParse(value);
      }
      if (kwh != null) {
        monthValues[month] = kwh;
      }
    }
  });
  
  // Create points for all 12 months
  for (int month = 1; month <= 12; month++) {
    final kwh = monthValues[month] ?? 0.0;
    points.add(EnergyPoint(label: 'Tháng $month', kwh: kwh));
  }
  
  return points;
}

/// Stream provider for analysis detail data
final analysisDetailProvider = StreamProvider<AnalysisDetailData>((ref) async* {
  final datasource = ref.watch(energyFirestoreDataSourceProvider);
  final period = ref.watch(analysisPeriodProvider);
  final selectedMonthId = ref.watch(selectedDetailMonthIdProvider);
  
  try {
    AnalysisDetailData? detailData;
    
    if (period == AnalysisPeriod.year) {
      // Get data from energy_summary collection
      final now = DateTime.now();
      final currentYear = now.year;
      
      final summaryData = await datasource.getEnergySummaryByYear(currentYear);
      if (summaryData == null || !summaryData.containsKey('monthly_data')) {
        // Return empty data
        yield AnalysisDetailData(
          period: period,
          points: List.generate(12, (i) => EnergyPoint(label: 'Tháng ${i + 1}', kwh: 0)),
          totalEnergy: 0,
          totalCost: 0,
        );
        return;
      }
      
      final monthlyData = summaryData['monthly_data'] as Map<String, dynamic>?;
      final points = _parseMonthlyData(monthlyData);
      
      // Calculate total energy and cost
      final totalEnergy = points.fold<double>(0, (sum, point) => sum + point.kwh);
      // Estimate cost (you may need to adjust this based on your cost calculation)
      final totalCost = totalEnergy * 1800; // Example: 1800 VND per kWh
      
      detailData = AnalysisDetailData(
        period: period,
        points: points,
        totalEnergy: totalEnergy,
        totalCost: totalCost,
      );
    } else {
      // Get data from energy collection (daily_data)
      EnergyDocument? currentDoc;
      
      if (selectedMonthId == null) {
        // Use latest month - get first value from stream
        await for (final latestDoc in datasource.watchLatestEnergy()) {
          currentDoc = latestDoc;
          break; // Get first value
        }
      } else {
        currentDoc = await datasource.getEnergyByMonth(selectedMonthId);
      }
      
      if (currentDoc == null) {
        // Return empty data
        yield AnalysisDetailData(
          period: period,
          points: period == AnalysisPeriod.week
              ? List.generate(7, (i) => EnergyPoint(label: 'Thứ ${i + 2}', kwh: 0))
              : List.generate(4, (i) => EnergyPoint(label: 'Tuần ${i + 1}', kwh: 0)),
          totalEnergy: 0,
          totalCost: 0,
        );
        return;
      }
      
      final energyModel = EnergyModel.fromFirestore(currentDoc.data, currentDoc.id);
      final dailyData = energyModel.dailyData;
      
      List<EnergyPoint> points;
      if (period == AnalysisPeriod.week) {
        // Split into 7 days of current week
        final now = DateTime.now();
        final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
        
        final weekLabels = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
        points = List.generate(7, (i) {
          final date = currentWeekStart.add(Duration(days: i));
          final day = date.day;
          final kwh = dailyData[day.toString()] ?? 0.0;
          return EnergyPoint(label: weekLabels[i], kwh: kwh);
        });
      } else {
        // Month view: group by weeks
        points = _groupDailyDataByWeeks(dailyData, energyModel.year, energyModel.month);
      }
      
      detailData = AnalysisDetailData(
        period: period,
        points: points,
        totalEnergy: energyModel.totalKwh,
        totalCost: energyModel.totalCost,
      );
    }
    
    yield detailData;
  } catch (e) {
    print('Error loading analysis detail data: $e');
    // Return empty data on error
    yield AnalysisDetailData(
      period: period,
      points: period == AnalysisPeriod.year
          ? List.generate(12, (i) => EnergyPoint(label: 'Tháng ${i + 1}', kwh: 0))
          : period == AnalysisPeriod.week
              ? List.generate(7, (i) => EnergyPoint(label: 'Thứ ${i + 2}', kwh: 0))
              : List.generate(4, (i) => EnergyPoint(label: 'Tuần ${i + 1}', kwh: 0)),
      totalEnergy: 0,
      totalCost: 0,
    );
  }
});
