import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/analysis_provider.dart';
import '../../../core/router/app_router.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(analysisProvider);
    final sizeClass = context.screenSizeClass;

    return ContentScaffold(
      title: 'Phân Tích',
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.90 : 0.85,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      onRefresh: () async {
        ref.invalidate(analysisProvider);
        ref.invalidate(selectedMonthIdProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      body: (context, constraints) {
        final spacing = sizeClass == ScreenSizeClass.expanded 
            ? AppSpacing.xl 
            : AppSpacing.lg;
        
        return statsAsync.when(
          data: (stats) {
            // Check if no data
            if (stats.monthLabel == 'Chưa có dữ liệu' && 
                stats.totalEnergyKwh == 0 && 
                stats.totalCost == 0 &&
                stats.breakdown.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Chưa có dữ liệu',
                      style: context.responsiveTitleM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _MonthYearPicker(),
                  ],
                ),
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MonthYearPicker(),
                SizedBox(height: spacing),
                _StatsCard(
                  stats: stats,
                  constraints: constraints,
                ),
              SizedBox(height: spacing),
              Text(
                'Phân Bố Tiêu Thụ:',
                style: context.responsiveTitleM.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: sizeClass == ScreenSizeClass.compact 
                  ? AppSpacing.md 
                  : AppSpacing.lg),
              _DistributionChart(stats: stats),
              SizedBox(height: sizeClass == ScreenSizeClass.compact 
                  ? AppSpacing.md 
                  : AppSpacing.lg),
              TextButton.icon(
                onPressed: () => context.pushNamed(AppRoute.analysisDetail.name),
                icon: const Icon(Icons.insights, color: AppColors.primary),
                label: Text(
                  'Xem Chi Tiết Biểu Đồ Năng Lượng',
                  style: context.responsiveBodyM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Lỗi khi tải dữ liệu',
                    style: context.responsiveTitleM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    error.toString(),
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _MonthYearPicker(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.stats,
    required this.constraints,
  });

  final AnalysisStats stats;
  final BoxConstraints constraints;

  /// Format currency with 3 decimal places and "đồng" unit
  String _formatCurrency(double amount) {
    if (amount == 0) return '0 đồng';
    // Format with 3 decimal places
    return '${amount.toStringAsFixed(3)} đồng';
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl 
        : AppSpacing.lg;
    
    return AppCard(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats.monthLabel,
            style: context.responsiveBodyM.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: sizeClass == ScreenSizeClass.compact 
              ? AppSpacing.md 
              : AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  context: context,
                  icon: Icons.bolt_outlined,
                  label: 'Tổng Điện Năng',
                  value: '${stats.totalEnergyKwh.toStringAsFixed(2)}wh',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: sizeClass == ScreenSizeClass.compact 
                  ? AppSpacing.md 
                  : AppSpacing.lg),
              Expanded(
                child: _StatTile(
                  context: context,
                  icon: Icons.payments_outlined,
                  label: 'Tổng Tiền Điện',
                  value: _formatCurrency(stats.totalCost),
                  valueColor: Colors.indigo,
                ),
              ),
            ],
          ),
          SizedBox(height: sizeClass == ScreenSizeClass.compact 
              ? AppSpacing.md 
              : AppSpacing.lg),
          Row(
            children: [
              Icon(
                Icons.check_box_outlined,
                size: sizeClass == ScreenSizeClass.expanded ? 20 : 18,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${stats.isDecrease ? 'Giảm' : 'Tăng'} ${stats.deltaCost.toStringAsFixed(0)} So Với Tháng Trước',
                  style: context.responsiveBodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final avatarRadius = sizeClass == ScreenSizeClass.expanded 
        ? 24.0 
        : sizeClass == ScreenSizeClass.medium
            ? 22.0
            : 20.0;
    
    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: AppColors.primarySoft,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: avatarRadius * 0.9,
          ),
        ),
        SizedBox(width: sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.sm 
            : AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.responsiveBodyM,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: context.responsiveTitleM.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({required this.stats});

  final AnalysisStats stats;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final total = stats.breakdown.fold<double>(0, (sum, item) => sum + item.value);
    final chartHeight = sizeClass == ScreenSizeClass.expanded 
        ? 260.0 
        : sizeClass == ScreenSizeClass.medium
            ? 240.0
            : 220.0;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl 
        : AppSpacing.lg;

    return AppCard(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: sizeClass == ScreenSizeClass.expanded ? 44 : 36,
                startDegreeOffset: -90,
                sections: stats.breakdown
                    .map(
                      (item) => PieChartSectionData(
                        value: item.value,
                        color: item.color,
                        title: '${((item.value / total) * 100).round()}%',
                        radius: sizeClass == ScreenSizeClass.expanded ? 90 : 80,
                        titleStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: sizeClass == ScreenSizeClass.expanded ? 14 : 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          SizedBox(height: sizeClass == ScreenSizeClass.compact 
              ? AppSpacing.md 
              : AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: sizeClass == ScreenSizeClass.expanded 
                ? AppSpacing.xl 
                : AppSpacing.lg,
            runSpacing: sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.sm 
                : AppSpacing.md,
            children: stats.breakdown
                .map(
                  (item) => _LegendItem(
                    context: context,
                    color: item.color,
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.context,
    required this.color,
    required this.label,
  });

  final BuildContext context;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final dotSize = sizeClass == ScreenSizeClass.expanded ? 14.0 : 12.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: context.responsiveBodyM,
        ),
      ],
    );
  }
}

/// Month/Year picker widget
class _MonthYearPicker extends ConsumerWidget {
  const _MonthYearPicker();

  /// Format month ID to display string (e.g., "2026_01" -> "Tháng 1/2026")
  String _formatMonthId(String monthId) {
    final parts = monthId.split('_');
    if (parts.length != 2) return monthId;
    final year = parts[0];
    final month = int.tryParse(parts[1]);
    if (month == null) return monthId;
    return 'Tháng $month/$year';
  }

  /// Parse month ID from year and month
  String _parseMonthId(int year, int month) {
    return '${year}_${month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeClass = context.screenSizeClass;
    final selectedMonthId = ref.watch(selectedMonthIdProvider);
    final availableMonthsAsync = ref.watch(
      StreamProvider<List<String>>((ref) {
        final datasource = ref.watch(energyFirestoreDataSourceProvider);
        return datasource.watchAvailableMonthIds();
      }),
    );

    // Get current display text
    String displayText = 'Tháng hiện tại';
    if (selectedMonthId != null) {
      displayText = _formatMonthId(selectedMonthId);
    }

    return availableMonthsAsync.when(
      data: (availableMonths) {
        // Always show the picker, even if no months available
        return AppCard(
          padding: EdgeInsets.all(
            sizeClass == ScreenSizeClass.expanded 
                ? AppSpacing.lg 
                : AppSpacing.md,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('MonthYearPicker tapped, availableMonths: ${availableMonths.length}');
                _showMonthYearPicker(context, ref, availableMonths, selectedMonthId);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: sizeClass == ScreenSizeClass.compact 
                    ? AppSpacing.sm 
                    : AppSpacing.md,
                horizontal: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: sizeClass == ScreenSizeClass.expanded ? 20 : 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        displayText,
                        style: context.responsiveBodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
      loading: () {
        // Show picker even when loading
        return AppCard(
          padding: EdgeInsets.all(
            sizeClass == ScreenSizeClass.expanded 
                ? AppSpacing.lg 
                : AppSpacing.md,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('MonthYearPicker tapped (loading state)');
                // Try to get available months from datasource directly
                final datasource = ref.read(energyFirestoreDataSourceProvider);
                datasource.watchAvailableMonthIds().first.then((months) {
                  _showMonthYearPicker(context, ref, months, selectedMonthId);
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: sizeClass == ScreenSizeClass.compact 
                    ? AppSpacing.sm 
                    : AppSpacing.md,
                horizontal: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: sizeClass == ScreenSizeClass.expanded ? 20 : 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        displayText,
                        style: context.responsiveBodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
      error: (error, stack) {
        print('Error loading available months: $error');
        // Show picker even on error
        return AppCard(
          padding: EdgeInsets.all(
            sizeClass == ScreenSizeClass.expanded 
                ? AppSpacing.lg 
                : AppSpacing.md,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('MonthYearPicker tapped (error state)');
                // Try to get available months from datasource directly
                final datasource = ref.read(energyFirestoreDataSourceProvider);
                datasource.watchAvailableMonthIds().first.then((months) {
                  _showMonthYearPicker(context, ref, months, selectedMonthId);
                }).catchError((e) {
                  print('Error fetching months: $e');
                  // Show dialog with empty list
                  _showMonthYearPicker(context, ref, [], selectedMonthId);
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: sizeClass == ScreenSizeClass.compact 
                    ? AppSpacing.sm 
                    : AppSpacing.md,
                horizontal: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: sizeClass == ScreenSizeClass.expanded ? 20 : 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        displayText,
                        style: context.responsiveBodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }

  void _showMonthYearPicker(
    BuildContext context,
    WidgetRef ref,
    List<String> availableMonths,
    String? currentMonthId,
  ) {
    print('_showMonthYearPicker called with ${availableMonths.length} months');
    
    // Parse available months to get unique years and months
    final Map<int, List<int>> yearMonthsMap = {};
    for (final monthId in availableMonths) {
      final parts = monthId.split('_');
      if (parts.length != 2) continue;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null) continue;
      
      if (!yearMonthsMap.containsKey(year)) {
        yearMonthsMap[year] = [];
      }
      yearMonthsMap[year]!.add(month);
    }

    print('Parsed yearMonthsMap: $yearMonthsMap');

    // Sort years descending
    final sortedYears = yearMonthsMap.keys.toList()..sort((a, b) => b.compareTo(a));
    
    // Get current selection
    int? selectedYear;
    int? selectedMonth;
    if (currentMonthId != null) {
      final parts = currentMonthId.split('_');
      if (parts.length == 2) {
        selectedYear = int.tryParse(parts[0]);
        selectedMonth = int.tryParse(parts[1]);
      }
    }
    
    // Default to current month/year if not selected
    final now = DateTime.now();
    selectedYear ??= now.year;
    selectedMonth ??= now.month;

    print('Opening dialog with selectedYear: $selectedYear, selectedMonth: $selectedMonth');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Chọn Tháng/Năm',
            style: context.responsiveTitleM.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year selector
                Text(
                  'Năm:',
                  style: context.responsiveBodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: sortedYears.map((year) {
                    final isSelected = selectedYear == year;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedYear = year;
                          // Reset month if not available in selected year
                          if (!yearMonthsMap[year]!.contains(selectedMonth)) {
                            selectedMonth = yearMonthsMap[year]!.first;
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.panel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.primary 
                                : AppColors.borderSoft,
                          ),
                        ),
                        child: Text(
                          year.toString(),
                          style: context.responsiveBodyM.copyWith(
                            color: isSelected 
                                ? Colors.white 
                                : AppColors.textPrimary,
                            fontWeight: isSelected 
                                ? FontWeight.w700 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: AppSpacing.lg),
                // Month selector
                Text(
                  'Tháng:',
                  style: context.responsiveBodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                if (selectedYear != null && yearMonthsMap.containsKey(selectedYear))
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: (yearMonthsMap[selectedYear]!..sort())
                        .map((month) {
                          final isSelected = selectedMonth == month;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedMonth = month;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : AppColors.panel,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : AppColors.borderSoft,
                                ),
                              ),
                              child: Text(
                                'Tháng $month',
                                style: context.responsiveBodyM.copyWith(
                                  color: isSelected 
                                      ? Colors.white 
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected 
                                      ? FontWeight.w700 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Reset to latest
                ref.read(selectedMonthIdProvider.notifier).state = null;
                Navigator.of(context).pop();
              },
              child: Text(
                'Tháng hiện tại',
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: selectedYear != null && selectedMonth != null
                  ? () {
                      final monthId = _parseMonthId(selectedYear!, selectedMonth!);
                      ref.read(selectedMonthIdProvider.notifier).state = monthId;
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Text(
                'Chọn',
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
