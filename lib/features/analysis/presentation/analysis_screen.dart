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
    final stats = ref.watch(analysisProvider);
    final sizeClass = context.screenSizeClass;

    return ContentScaffold(
      title: 'Phân Tích',
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      body: (context, constraints) {
        final spacing = sizeClass == ScreenSizeClass.expanded 
            ? AppSpacing.xl 
            : AppSpacing.lg;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  value: '${stats.totalEnergyKwh}kwh',
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
                  value: stats.totalCost.toStringAsFixed(0),
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
