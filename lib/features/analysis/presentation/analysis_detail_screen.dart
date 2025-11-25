import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../providers/analysis_provider.dart';

class AnalysisDetailScreen extends ConsumerWidget {
  const AnalysisDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analysisPeriodProvider);
    final detail = ref.watch(analysisDetailProvider);

    return AuthScaffold(
      title: 'Phân Tích',
      showWave: false,
      panelHeightFactor: 0.8,
      contentTopPaddingFactor: 0.1,
      panelScrollable: true,
      horizontalPaddingFactor: 0.06,
      panelBuilder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodTabs(
              selected: period,
              onChanged: (value) =>
                  ref.read(analysisPeriodProvider.notifier).state = value,
            ),
            AppSpacing.h16,
            _EnergyBarCard(detail: detail),
            AppSpacing.h16,
            _SummaryRow(detail: detail),
          ],
        );
      },
      titleWidget: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text('Phân Tích', style: AppTypography.titleL),
                AppSpacing.h12,
                const Icon(Icons.house_outlined,
                    size: 56, color: Colors.black87),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onChanged});

  final AnalysisPeriod selected;
  final ValueChanged<AnalysisPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(6),
      child: Row(
        children: tabs
            .map(
              (tab) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(tab.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          selected == tab.$1 ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        tab.$2,
                        style: AppTypography.bodyM.copyWith(
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

  @override
  Widget build(BuildContext context) {
    final double maxY = (detail.points
                .map((e) => e.kwh)
                .reduce((a, b) => a > b ? a : b) *
            1.3)
        .clamp(1.0, 12.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiêu Thụ Năng Lượng',
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.h12,
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.borderSoft,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}kwh',
                          style: AppTypography.labelM.copyWith(fontSize: 11),
                        );
                      },
                      interval: (maxY / 4).clamp(1.0, 3.0),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= detail.points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            detail.points[index].label,
                            style: AppTypography.labelM.copyWith(fontSize: 11),
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
                          toY: detail.points[i].kwh,
                          width: 16,
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                ],
                maxY: maxY,
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.detail});

  final AnalysisDetailData detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryTile(
          icon: Icons.bolt_outlined,
          label: 'Tổng Điện Năng',
          value: '${detail.totalEnergy.toStringAsFixed(0)}kwh',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        _SummaryTile(
          icon: Icons.payments_outlined,
          label: 'Tổng Tiền Điện',
          value: detail.totalCost.toStringAsFixed(0),
          color: Colors.indigo,
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
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySoft,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodyM.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleM.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
