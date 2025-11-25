import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../providers/analysis_provider.dart';
import '../../../core/router/app_router.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(analysisProvider);

    return AuthScaffold(
      title: 'Phân Tích',
      showWave: false,
      panelHeightFactor: 0.8,
      contentTopPaddingFactor: 0.08,
      panelScrollable: true,
      horizontalPaddingFactor: 0.06,
      panelBuilder: (constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatsCard(stats: stats),
            AppSpacing.h20,
            Text(
              'Phân Bố Tiêu Thụ:',
              style: AppTypography.titleM,
            ),
            AppSpacing.h12,
            _DistributionChart(stats: stats),
            AppSpacing.h12,
            TextButton.icon(
              onPressed: () => context.pushNamed(AppRoute.analysisDetail.name),
              icon: const Icon(Icons.insights, color: AppColors.primary),
              label: const Text(
                'Xem Chi Tiết Biểu Đồ Năng Lượng',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Phân Tích',
            style: AppTypography.titleL.copyWith(color: Colors.black87),
          ),
          AppSpacing.h12,
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final AnalysisStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats.monthLabel,
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.h12,
          Row(
            children: [
              _StatTile(
                icon: Icons.bolt_outlined,
                label: 'Tổng Điện Năng',
                value: '${stats.totalEnergyKwh}kwh',
                valueColor: AppColors.textPrimary,
              ),
              const SizedBox(width: 16),
              _StatTile(
                icon: Icons.payments_outlined,
                label: 'Tổng Tiền Điện',
                value: stats.totalCost.toStringAsFixed(0),
                valueColor: Colors.indigo,
              ),
            ],
          ),
          AppSpacing.h12,
          Row(
            children: [
              const Icon(Icons.check_box_outlined, size: 18),
              const SizedBox(width: 6),
              Text(
                '${stats.isDecrease ? 'Giảm' : 'Tăng'} ${stats.deltaCost.toStringAsFixed(0)} So Với Tháng Trước',
                style: AppTypography.bodyM.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
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
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodyM.copyWith(fontSize: 14),
              ),
              Text(
                value,
                style: AppTypography.titleM.copyWith(
                  color: valueColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({required this.stats});

  final AnalysisStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.breakdown.fold<double>(0, (sum, item) => sum + item.value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 36,
                startDegreeOffset: -90,
                sections: stats.breakdown
                    .map(
                      (item) => PieChartSectionData(
                        value: item.value,
                        color: item.color,
                        title: '${((item.value / total) * 100).round()}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          AppSpacing.h12,
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: stats.breakdown
                .map(
                  (item) => _LegendItem(
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
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodyM.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
