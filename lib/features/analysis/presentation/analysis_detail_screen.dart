import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/analysis_provider.dart';

class AnalysisDetailScreen extends ConsumerWidget {
  const AnalysisDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analysisPeriodProvider);
    final detailAsync = ref.watch(analysisDetailProvider);
    final sizeClass = context.screenSizeClass;

    return ContentScaffold(
      title: 'Phân Tích',
      showBack: true,
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.90 : 0.85,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      onRefresh: () async {
        // Invalidate cả period provider để force reload data
        ref.invalidate(analysisPeriodProvider);
        ref.invalidate(analysisDetailProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      titleWidget: _TitleSection(context: context),
      body: (context, constraints) {
        final spacing = sizeClass == ScreenSizeClass.expanded 
            ? AppSpacing.xl 
            : AppSpacing.lg;
        
        return detailAsync.when(
          data: (detail) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PeriodTabs(
                selected: period,
                onChanged: (value) =>
                    ref.read(analysisPeriodProvider.notifier).state = value,
              ),
              SizedBox(height: spacing),
              _EnergyBarCard(detail: detail),
              SizedBox(height: spacing),
              _SummaryRow(detail: detail),
            ],
          ),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom title section with icon
class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final iconSize = sizeClass == ScreenSizeClass.expanded 
        ? 56.0 
        : sizeClass == ScreenSizeClass.medium
            ? 52.0
            : 48.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Phân Tích',
            style: context.responsiveHeadlineL.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(
          Icons.insights_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ],
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onChanged});

  final AnalysisPeriod selected;
  final ValueChanged<AnalysisPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final tabs = [
      (AnalysisPeriod.week, 'Tuần'),
      (AnalysisPeriod.month, 'Tháng'),
      (AnalysisPeriod.year, 'Năm'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(sizeClass == ScreenSizeClass.compact ? 4 : 6),
      child: Row(
        children: tabs
            .map(
              (tab) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(tab.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: sizeClass == ScreenSizeClass.compact ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected == tab.$1 ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        tab.$2,
                        style: context.responsiveBodyM.copyWith(
                          color: selected == tab.$1
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EnergyBarCard extends StatelessWidget {
  const _EnergyBarCard({required this.detail});

  final AnalysisDetailData detail;

  /// Calculate nice interval for Y-axis labels
  double _calculateNiceInterval(double baseInterval) {
    if (baseInterval <= 0) return 1.0;
    
    // Làm tròn interval lên số đẹp (1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, ...)
    final ln10 = math.log(10);
    final magnitude = math.pow(10, (math.log(baseInterval) / ln10).floor()).toDouble();
    final normalized = baseInterval / magnitude;
    
    double niceInterval;
    if (normalized <= 1) {
      niceInterval = 1 * magnitude;
    } else if (normalized <= 2) {
      niceInterval = 2 * magnitude;
    } else if (normalized <= 5) {
      niceInterval = 5 * magnitude;
    } else {
      niceInterval = 10 * magnitude;
    }
    
    return niceInterval;
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl 
        : AppSpacing.lg;
    // Tăng chart height để có nhiều không gian hơn
    final chartHeight = sizeClass == ScreenSizeClass.expanded 
        ? 320.0 
        : sizeClass == ScreenSizeClass.medium
            ? 280.0
            : 260.0;
    
    // Convert kwh to wh for display
    final pointsInWh = detail.points.map((e) => e.kwh * 1000).toList();
    
    // Tính min và max từ dữ liệu thực tế
    final minValue = pointsInWh.reduce((a, b) => a < b ? a : b);
    final maxValue = pointsInWh.reduce((a, b) => a > b ? a : b);
    
    // Tính maxY với khoảng trống hợp lý (10-20% phía trên)
    // Đảm bảo minY là 0 hoặc gần 0 nếu tất cả giá trị đều dương
    final dataRange = maxValue - minValue;
    final yAxisPadding = dataRange > 0 ? (dataRange * 0.15) : (maxValue * 0.2);
    final maxY = maxValue + yAxisPadding;
    final minY = minValue > 0 && minValue < maxValue * 0.1 
        ? 0.0 
        : (minValue - yAxisPadding).clamp(0.0, double.infinity);
    
    // Tính số lượng labels hợp lý (4-6 labels)
    final targetLabelCount = 5;
    final range = maxY - minY;
    
    // Tính interval hợp lý dựa trên range
    double yInterval;
    if (range <= 0 || maxValue == 0) {
      // Nếu không có dữ liệu hoặc tất cả = 0
      yInterval = maxValue > 0 ? _calculateNiceInterval(maxValue / targetLabelCount) : 1.0;
    } else {
      // Tính interval cơ bản
      double baseInterval = range / targetLabelCount;
      yInterval = _calculateNiceInterval(baseInterval);
      
      // Đảm bảo interval không quá nhỏ
      if (yInterval < 0.01 && maxY < 1) {
        yInterval = 0.01;
      } else if (yInterval < 0.1 && maxY < 10) {
        yInterval = 0.1;
      } else if (yInterval < 1 && maxY < 100) {
        yInterval = 1;
      } else if (yInterval < 10 && maxY < 1000) {
        yInterval = 10;
      }
    }
    
    // Điều chỉnh maxY và minY để chia hết cho interval và có padding hợp lý
    var adjustedMaxY = ((maxValue * 1.15) / yInterval).ceil() * yInterval;
    var adjustedMinY = math.max(0.0, ((minValue * 0.95) / yInterval).floor() * yInterval);
    
    // Đảm bảo adjustedMaxY >= maxValue
    adjustedMaxY = math.max(adjustedMaxY, maxValue * 1.1);
    
    // Recalculate interval based on final range để có labels đẹp hơn
    final finalRange = adjustedMaxY - adjustedMinY;
    if (finalRange > 0) {
      final finalInterval = finalRange / targetLabelCount;
      yInterval = _calculateNiceInterval(finalInterval);
      
      // Điều chỉnh lại maxY và minY theo interval mới
      adjustedMaxY = (adjustedMaxY / yInterval).ceil() * yInterval;
      adjustedMinY = (adjustedMinY / yInterval).floor() * yInterval;
      
      // Đảm bảo adjustedMaxY >= maxValue
      adjustedMaxY = math.max(adjustedMaxY, maxValue * 1.1);
      adjustedMinY = math.max(0.0, adjustedMinY);
    }
    
    final finalMaxY = adjustedMaxY;
    final finalMinY = adjustedMinY;
    
    // Kiểm tra nếu là period year thì cần scrollable
    final isYearPeriod = detail.period == AnalysisPeriod.year;
    // Tính toán width cho chart: mỗi bar cần ~100-120px để có đủ không gian
    final barWidth = sizeClass == ScreenSizeClass.expanded ? 24.0 : 20.0;
    // Tăng groupsSpace để labels X không bị sát nhau - tăng nhiều hơn cho year period
    final groupsSpace = isYearPeriod
        ? (sizeClass == ScreenSizeClass.expanded ? 48.0 : 42.0)
        : (sizeClass == ScreenSizeClass.expanded ? 32.0 : 28.0);
    // Mỗi bar group cần khoảng 100-120px để có đủ không gian cho bar, spacing và label
    // Tăng width để đảm bảo có đủ không gian cho 12 tháng và khoảng cách giữa các labels
    final barGroupWidth = isYearPeriod
        ? (sizeClass == ScreenSizeClass.expanded ? 140.0 : 130.0)
        : (sizeClass == ScreenSizeClass.expanded ? 120.0 : 110.0);
    // Tính chart width: số bars * width mỗi bar + padding bên phải
    // Đảm bảo có đủ không gian cho tất cả bars (12 tháng)
    final rightPadding = sizeClass == ScreenSizeClass.expanded ? 32.0 : 24.0;
    final chartWidth = isYearPeriod 
        ? (detail.points.length * barGroupWidth + rightPadding)
        : null; // null = auto width cho week/month
    
    // Debug: Print để verify có đủ 12 tháng
    if (isYearPeriod) {
      print('Year period: ${detail.points.length} months, chartWidth: $chartWidth');
      print('Months: ${detail.points.map((p) => p.label).join(', ')}');
    }
    
    // Y-axis reserved size (cố định bên ngoài scroll)
    final yAxisReservedSize = sizeClass == ScreenSizeClass.expanded ? 55.0 : 50.0;

    return AppCard(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiêu Thụ Năng Lượng',
            style: context.responsiveTitleM.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: sizeClass == ScreenSizeClass.compact 
              ? AppSpacing.md 
              : AppSpacing.lg),
          SizedBox(
            height: chartHeight,
            child: isYearPeriod
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Y-axis labels cố định bên trái
                      SizedBox(
                        width: yAxisReservedSize,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: _buildYAxisLabels(
                            context,
                            sizeClass,
                            finalMaxY,
                            finalMinY,
                            yInterval,
                            chartHeight - 16, // Trừ padding top/bottom
                          ),
                        ),
                      ),
                      // Chart area scrollable
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            width: chartWidth,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: sizeClass == ScreenSizeClass.expanded ? 8 : 4,
                                right: rightPadding,
                                top: 8,
                                bottom: 8,
                              ),
                              child: _buildScrollableBarChart(
                                context,
                                sizeClass,
                                detail,
                                pointsInWh,
                                finalMaxY,
                                finalMinY,
                                yInterval,
                                barWidth,
                                groupsSpace,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      left: sizeClass == ScreenSizeClass.expanded ? 8 : 4,
                      right: sizeClass == ScreenSizeClass.expanded ? 8 : 4,
                      top: 8,
                      bottom: 8,
                    ),
                    child: _buildBarChart(
                      context,
                      sizeClass,
                      detail,
                      pointsInWh,
                      finalMaxY,
                      finalMinY,
                      yInterval,
                      barWidth,
                      groupsSpace,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Build Y-axis labels cố định (không scroll)
  Widget _buildYAxisLabels(
    BuildContext context,
    ScreenSizeClass sizeClass,
    double maxY,
    double minY,
    double yInterval,
    double availableHeight,
  ) {
    // Tính số labels từ minY đến maxY
    final range = maxY - minY;
    var labelCount = (range / yInterval).ceil() + 1; // +1 để bao gồm cả minY và maxY
    
    // Giới hạn số lượng labels để tránh overflow (tối đa 6 labels)
    const maxLabels = 6;
    if (labelCount > maxLabels) {
      // Tăng interval để giảm số labels
      yInterval = range / (maxLabels - 1);
      labelCount = maxLabels;
    }
    
    // Space cho bottom labels (X-axis)
    final bottomSpace = sizeClass == ScreenSizeClass.expanded ? 32.0 : 28.0;
    final chartAreaHeight = availableHeight - bottomSpace;
    
    // Tính chiều cao tối thiểu cho mỗi label (bao gồm text và spacing)
    final minLabelHeight = sizeClass == ScreenSizeClass.compact ? 20.0 : 24.0;
    final maxPossibleLabels = (chartAreaHeight / minLabelHeight).floor();
    
    // Điều chỉnh labelCount nếu quá nhiều
    if (labelCount > maxPossibleLabels) {
      labelCount = maxPossibleLabels;
      yInterval = range / (labelCount - 1);
    }
    
    final labels = <Widget>[];
    
    // Tạo labels từ maxY xuống minY
    for (int i = labelCount - 1; i >= 0; i--) {
      final value = minY + (i * yInterval);
      // Chỉ hiển thị nếu value >= minY và <= maxY (với tolerance nhỏ)
      if (value >= minY - 0.001 && value <= maxY + 0.001) {
        labels.add(
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value >= 1 
                      ? '${value.toInt()}wh'
                      : value >= 0.1
                          ? '${value.toStringAsFixed(1)}wh'
                          : '${value.toStringAsFixed(2)}wh',
                  style: context.responsiveLabelM.copyWith(
                    fontSize: sizeClass == ScreenSizeClass.compact ? 10 : 11,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return SizedBox(
      height: availableHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top spacer để align với chart top
          const SizedBox(height: 8),
          // Labels
          ...labels,
          // Bottom spacer để align với X-axis
          SizedBox(height: bottomSpace),
        ],
      ),
    );
  }

  /// Build scrollable chart (chỉ bars và X-axis labels)
  Widget _buildScrollableBarChart(
    BuildContext context,
    ScreenSizeClass sizeClass,
    AnalysisDetailData detail,
    List<double> pointsInWh,
    double maxY,
    double minY,
    double yInterval,
    double barWidth,
    double groupsSpace,
  ) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.start, // Căn trái để scroll mượt
        groupsSpace: groupsSpace, // Khoảng cách giữa các nhóm bars
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.borderSoft.withOpacity(0.3),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          // Ẩn Y-axis labels vì đã có cố định bên ngoài
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: sizeClass == ScreenSizeClass.expanded ? 32 : 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= detail.points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(
                    top: sizeClass == ScreenSizeClass.expanded ? 12.0 : 10.0,
                  ),
                  child: Text(
                    detail.points[index].label,
                    style: context.responsiveLabelM.copyWith(
                      fontSize: sizeClass == ScreenSizeClass.compact ? 11 : 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: [
          for (int i = 0; i < detail.points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: pointsInWh[i],
                  width: barWidth,
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ],
            ),
        ],
        maxY: maxY,
        minY: minY,
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    ScreenSizeClass sizeClass,
    AnalysisDetailData detail,
    List<double> pointsInWh,
    double maxY,
    double minY,
    double yInterval,
    double barWidth,
    double groupsSpace,
  ) {
    return BarChart(
                BarChartData(
                  alignment: detail.period == AnalysisPeriod.year 
                      ? BarChartAlignment.start // Với year, căn trái để scroll mượt
                      : BarChartAlignment.spaceAround, // Giãn đều các bars cho week/month
                  groupsSpace: groupsSpace, // Khoảng cách giữa các nhóm bars
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.borderSoft.withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: [4, 4], // Đường kẻ nét đứt để mượt hơn
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        // Tăng reservedSize để labels không bị lệch
                        reservedSize: sizeClass == ScreenSizeClass.expanded ? 50 : 45,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          // Căn chỉnh labels về bên phải
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${value.toInt()}wh',
                              style: context.responsiveLabelM.copyWith(
                                fontSize: sizeClass == ScreenSizeClass.compact ? 10 : 11,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                        interval: yInterval,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: sizeClass == ScreenSizeClass.expanded ? 32 : 28, // Tăng reservedSize cho bottom labels
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= detail.points.length) {
                            return const SizedBox.shrink();
                          }
                          // Căn giữa labels và thêm padding
                          return Padding(
                            padding: EdgeInsets.only(
                              top: sizeClass == ScreenSizeClass.expanded ? 12.0 : 10.0,
                            ),
                            child: Text(
                              detail.points[index].label,
                              style: context.responsiveLabelM.copyWith(
                                fontSize: sizeClass == ScreenSizeClass.compact ? 11 : 12,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: [
                    for (int i = 0; i < detail.points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: pointsInWh[i],
                            width: barWidth,
                            color: AppColors.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ],
                      ),
                  ],
                  maxY: maxY,
                  minY: minY,
                ),
              );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.detail});

  final AnalysisDetailData detail;

  /// Format currency with 3 decimal places and "đồng" unit
  String _formatCurrency(double amount) {
    if (amount == 0) return '0 đồng';
    return '${amount.toStringAsFixed(3)} đồng';
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final spacing = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.lg 
        : AppSpacing.md;
    
    // Convert kwh to wh for display
    final totalEnergyWh = detail.totalEnergy * 1000;
    
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            icon: Icons.bolt_outlined,
            label: 'Tổng Điện Năng',
            value: '${totalEnergyWh.toStringAsFixed(2)}wh',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _SummaryTile(
            icon: Icons.payments_outlined,
            label: 'Tổng Tiền Điện',
            value: _formatCurrency(detail.totalCost),
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final avatarRadius = sizeClass == ScreenSizeClass.expanded 
        ? 24.0 
        : sizeClass == ScreenSizeClass.medium
            ? 22.0
            : 20.0;
    
    return Column(
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
        SizedBox(height: sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.sm 
            : AppSpacing.md),
        Text(
          label,
          style: context.responsiveBodyM,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.responsiveTitleM.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
