import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/energy_firestore_datasource.dart';
import '../data/models/energy_model.dart';

// Removed _getWeekStart - no longer needed with new week calculation logic

// Removed unused helper functions - logic moved to analysis_detail_screen.dart

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
/// Đồng bộ với selectedMonthIdProvider từ analysis_screen
final selectedDetailMonthIdProvider = StateProvider<String?>((ref) {
  // Đồng bộ với selectedMonthIdProvider từ analysis_screen
  return ref.watch(selectedMonthIdProvider);
});

/// Provider for selected week (0 = current week, 1 = week 1, 2 = week 2, etc.)
/// null = current week
final selectedWeekProvider = StateProvider<int?>((ref) {
  return null; // null means use current week
});

/// Helper function to split daily_data into weeks
/// Returns list of EnergyPoint for each week (max 5 weeks)
/// Logic mới: Tuần 0 = 1-7, Tuần 1 = 8-14, Tuần 2 = 15-21, Tuần 3 = 22-28, Tuần 4 = 29-31
List<EnergyPoint> _splitDailyDataIntoWeeks(Map<String, double> dailyData, int year, int month) {
  final lastDay = DateTime(year, month + 1, 0);
  final totalDays = lastDay.day;
  final totalWeeks = ((totalDays - 1) ~/ 7) + 1; // Số tuần trong tháng (tối đa 5)
  
  // Tạo danh sách points cho tất cả các tuần
  final points = <EnergyPoint>[];
  
  for (int weekIndex = 0; weekIndex < totalWeeks && weekIndex < 5; weekIndex++) {
    // Tính ngày bắt đầu và kết thúc của tuần
    final weekStartDay = 1 + (weekIndex * 7);
    final weekEndDay = (weekStartDay + 6) > totalDays ? totalDays : (weekStartDay + 6);
    
    // Tính tổng kwh cho tuần này
    double weekTotal = 0;
    for (int day = weekStartDay; day <= weekEndDay; day++) {
      // Thử cả 2 format: "1" và "01"
      final dayKey1 = day.toString();
      final dayKey2 = day.toString().padLeft(2, '0');
      weekTotal += dailyData[dayKey1] ?? dailyData[dayKey2] ?? 0;
    }
    
    points.add(EnergyPoint(label: 'Tuần ${weekIndex + 1}', kwh: weekTotal));
  }
  
  // Pad với tuần trống nếu ít hơn 4 tuần (để giữ layout nhất quán)
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
      // Lấy năm từ selectedMonthId, nếu null thì dùng năm hiện tại
      int targetYear;
      if (selectedMonthId != null) {
        // Parse year from selectedMonthId (format: "YYYY_MM")
        final parts = selectedMonthId.split('_');
        if (parts.length == 2) {
          final year = int.tryParse(parts[0]);
          if (year != null) {
            targetYear = year;
          } else {
            targetYear = DateTime.now().year;
          }
        } else {
          targetYear = DateTime.now().year;
        }
      } else {
        targetYear = DateTime.now().year;
      }
      
      final summaryData = await datasource.getEnergySummaryByYear(targetYear);
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
      
      // Calculate total energy from points
      final totalEnergy = points.fold<double>(0, (sum, point) => sum + point.kwh);
      
      // Lấy total_cost từ energy_summary document (nếu có), nếu không thì tính từ total_kwh
      double totalCost;
      if (summaryData.containsKey('total_cost')) {
        final costValue = summaryData['total_cost'];
        if (costValue is num) {
          totalCost = costValue.toDouble();
        } else {
          // Fallback: tính từ total_kwh nếu có
          final totalKwh = summaryData['total_kwh'];
          if (totalKwh is num) {
            // Ước tính: lấy giá trung bình từ các tháng trong năm
            // Hoặc dùng giá cố định nếu không có dữ liệu
            totalCost = totalKwh.toDouble() * 1800; // 1800 VND per kWh
          } else {
            totalCost = totalEnergy * 1800;
          }
        }
      } else {
        // Fallback: tính từ total_kwh nếu có
        final totalKwh = summaryData['total_kwh'];
        if (totalKwh is num) {
          totalCost = totalKwh.toDouble() * 1800;
        } else {
          totalCost = totalEnergy * 1800;
        }
      }
      
      detailData = AnalysisDetailData(
        period: period,
        points: points,
        totalEnergy: totalEnergy,
        totalCost: totalCost,
      );
    } else {
      // Get data from energy collection (daily_data)
      // Parse year và month từ selectedMonthId để lấy đúng document
      int targetYear, targetMonth;
      if (selectedMonthId != null) {
        final parts = selectedMonthId.split('_');
        if (parts.length == 2) {
          targetYear = int.tryParse(parts[0]) ?? DateTime.now().year;
          targetMonth = int.tryParse(parts[1]) ?? DateTime.now().month;
        } else {
          final now = DateTime.now();
          targetYear = now.year;
          targetMonth = now.month;
        }
      } else {
        final now = DateTime.now();
        targetYear = now.year;
        targetMonth = now.month;
      }
      
      // Lấy document đúng theo tháng được chọn
      final targetMonthId = '${targetYear}_${targetMonth.toString().padLeft(2, '0')}';
      print('Getting document for monthId: $targetMonthId');
      final currentDoc = await datasource.getEnergyByMonth(targetMonthId);
      
      // Lấy tuần được chọn (mặc định là tuần 0 - tuần đầu tiên)
      final selectedWeek = ref.watch(selectedWeekProvider) ?? 0;
      
      List<EnergyPoint> points;
      Map<String, double> dailyData = {};
      double totalEnergy = 0;
      double totalCost = 0;
      
      if (currentDoc != null) {
        final energyModel = EnergyModel.fromFirestore(currentDoc.data, currentDoc.id);
        dailyData = energyModel.dailyData;
        totalEnergy = energyModel.totalKwh;
        totalCost = energyModel.totalCost;
        print('Document found: year=${energyModel.year}, month=${energyModel.month}');
        print('dailyData keys: ${dailyData.keys.toList()}');
        print('dailyData sample values: ${dailyData.entries.take(3).map((e) => '${e.key}: ${e.value}').join(', ')}');
        print('totalKwh: $totalEnergy, totalCost: $totalCost');
      } else {
        print('Document $targetMonthId not found - using empty data');
      }
      
      if (period == AnalysisPeriod.week) {
        // Logic mới: Tuần được tính theo ngày trong tháng, không phụ thuộc vào thứ
        // Tuần 0 = ngày 1-7, Tuần 1 = ngày 8-14, Tuần 2 = ngày 15-21, Tuần 3 = ngày 22-28, Tuần 4 = ngày 29-31
        final lastDay = DateTime(targetYear, targetMonth + 1, 0); // Ngày cuối cùng của tháng
        
        // Tính ngày bắt đầu của tuần được chọn
        // Tuần 0: ngày 1, Tuần 1: ngày 8, Tuần 2: ngày 15, Tuần 3: ngày 22, Tuần 4: ngày 29
        final weekStartDay = 1 + (selectedWeek * 7);
        
        // Đảm bảo không vượt quá ngày cuối cùng của tháng
        if (weekStartDay > lastDay.day) {
          // Tuần này không có trong tháng, trả về dữ liệu trống
          final weekLabels = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
          points = List.generate(7, (i) => EnergyPoint(label: weekLabels[i], kwh: 0));
        } else {
          // Tạo 7 ngày từ ngày bắt đầu tuần
          final weekLabels = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
          points = List.generate(7, (i) {
            final day = weekStartDay + i;
            
            // Kiểm tra xem ngày có vượt quá ngày cuối cùng của tháng không
            if (day > lastDay.day) {
              // Ngày này không có trong tháng (ví dụ: tuần cuối chỉ có 3 ngày)
              // Tìm thứ của ngày đầu tuần để hiển thị label đúng
              final startDate = DateTime(targetYear, targetMonth, weekStartDay);
              final currentWeekday = startDate.weekday; // 1=Monday, 2=Tuesday, ..., 7=Sunday
              final labelIndex = (currentWeekday - 1 + i) % 7; // Map về index trong weekLabels
              return EnergyPoint(label: weekLabels[labelIndex], kwh: 0);
            }
            
            // Ngày hợp lệ trong tháng
            final date = DateTime(targetYear, targetMonth, day);
            final dateWeekday = date.weekday; // 1=Monday, 2=Tuesday, ..., 7=Sunday
            
            // Map weekday về index trong weekLabels (Thứ 2=0, Thứ 3=1, ..., CN=6)
            final labelIndex = dateWeekday - 1;
            
            // Lấy dữ liệu từ daily_data theo ngày
            // daily_data trong Firestore có thể lưu key với format "1", "2", ... hoặc "01", "02", ...
            // Thử cả 2 format
            final dayKey1 = day.toString(); // "1", "2", ...
            final dayKey2 = day.toString().padLeft(2, '0'); // "01", "02", ...
            final kwh = dailyData[dayKey1] ?? dailyData[dayKey2] ?? 0.0;
            print('Point $i (${weekLabels[labelIndex]}): $day/$targetMonth/$targetYear (weekday: $dateWeekday), kwh=$kwh (from dailyData["$dayKey1"] or ["$dayKey2"])');
            return EnergyPoint(label: weekLabels[labelIndex], kwh: kwh);
          });
        }
      } else {
        // Month view: group by weeks
        print('Month view: dailyData keys: ${dailyData.keys.toList()}, targetYear=$targetYear, targetMonth=$targetMonth');
        points = _groupDailyDataByWeeks(dailyData, targetYear, targetMonth);
        print('Month view: generated ${points.length} points: ${points.map((p) => '${p.label}: ${p.kwh}kwh').join(', ')}');
      }
      
      detailData = AnalysisDetailData(
        period: period,
        points: points,
        totalEnergy: totalEnergy,
        totalCost: totalCost,
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
