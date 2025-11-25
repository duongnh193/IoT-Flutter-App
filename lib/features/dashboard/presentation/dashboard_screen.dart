import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../widgets/dashboard_cards.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      title: 'Hi, TEST USER',
      panelHeightFactor: 0.82,
      contentTopPaddingFactor: 0.08,
      waveOffset: 0,
      showWave: false,
      panelScrollable: true,
      panelOffset: 0,
      horizontalPaddingFactor: 0.06,
      panelShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, -2),
        ),
      ],
      panelBuilder: (panelConstraints) {
        const chipSpacing = 6.0;
        final chipWidth = (panelConstraints.maxWidth - chipSpacing * 8) / 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.h16,
            Row(
              children: [
                DashboardShortcutCard(
                  icon: Icons.exit_to_app,
                  title: 'Rời nhà',
                  background: AppColors.coralSoft,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                DashboardShortcutCard(
                  icon: Icons.home_outlined,
                  title: 'Về nhà',
                  background: AppColors.skySoft,
                  onTap: () {},
                ),
              ],
            ),
            AppSpacing.h20,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSoft),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardStatusChip(
                    icon: Icons.device_thermostat,
                    iconAsset: 'assets/icons/temperature.svg',
                    title: 'Nhiệt độ',
                    value: '28°C',
                    background: AppColors.white,
                    width: chipWidth,
                  ),
                  const SizedBox(width: chipSpacing),
                  DashboardStatusChip(
                    icon: Icons.water_drop_outlined,
                    iconAsset: 'assets/icons/humidity.svg',
                    title: 'Độ ẩm',
                    value: '70%',
                    background: AppColors.white,
                    width: chipWidth,
                  ),
                  const SizedBox(width: chipSpacing),
                  DashboardStatusChip(
                    icon: Icons.eco_outlined,
                    iconAsset: 'assets/icons/air.svg',
                    title: 'Không khí',
                    value: 'Trong lành',
                    background: AppColors.white,
                    width: chipWidth,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      titleWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, TEST USER',
                  style: AppTypography.headlineL,
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back!',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
