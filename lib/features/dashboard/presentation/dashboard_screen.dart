import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/providers/auth_session_provider.dart';
import '../providers/environment_provider.dart';
import '../providers/scenario_provider.dart';
import '../widgets/dashboard_cards.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeClass = context.screenSizeClass;
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return ContentScaffold(
      title: 'Trang chủ',
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.90 : 0.85,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      onRefresh: () async {
        ref.invalidate(environmentProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      titleWidget: currentUserAsync.when(
        data: (user) => _TitleSection(
          context: context,
          userName: user?.displayName ?? 'User',
        ),
        loading: () => _TitleSection(
          context: context,
          userName: '...',
        ),
        error: (_, __) => _TitleSection(
          context: context,
          userName: 'User',
        ),
      ),
      body: (context, constraints) {
        final spacing = sizeClass == ScreenSizeClass.expanded 
            ? AppSpacing.xl 
            : AppSpacing.lg;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shortcut cards in white card container
            AppCard(
              padding: EdgeInsets.all(spacing),
              child: Row(
                children: [
                  Expanded(
                    child: _ScenarioShortcutCard(
                      icon: Icons.exit_to_app,
                      title: 'Rời nhà',
                      background: AppColors.coralSoft,
                      scenarioId: 'ROI_NHA',
                    ),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _ScenarioShortcutCard(
                      icon: Icons.home_outlined,
                      title: 'Về nhà',
                      background: AppColors.skySoft,
                      scenarioId: 'VE_NHA',
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: spacing),
            
            // Status chips in white card container - responsive grid
            _StatusChipsSection(
              constraints: constraints,
            ),
          ],
        );
      },
    );
  }
}

/// Custom title section with user greeting
class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.context,
    required this.userName,
  });

  final BuildContext context;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final avatarRadius = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.cardRadius + 8 
        : sizeClass == ScreenSizeClass.medium
            ? AppSpacing.cardRadius + 6
            : AppSpacing.cardRadius + 4;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${userName.toUpperCase()}',
                style: context.responsiveHeadlineL,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sizeClass == ScreenSizeClass.compact 
                  ? AppSpacing.xs 
                  : AppSpacing.sm),
              Text(
                'Welcome back!',
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            color: AppColors.primary,
            size: avatarRadius * 0.7,
          ),
        ),
      ],
    );
  }
}

class _StatusChipsSection extends ConsumerWidget {
  const _StatusChipsSection({
    required this.constraints,
  });

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeClass = context.screenSizeClass;
    final chipPadding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl 
        : sizeClass == ScreenSizeClass.medium
            ? AppSpacing.lg
            : AppSpacing.md;
    
    final chipSpacing = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.lg 
        : sizeClass == ScreenSizeClass.medium
            ? AppSpacing.md
            : AppSpacing.sm;
    
    // Calculate chip width for top row (3 chips)
    final availableWidth = constraints.maxWidth;
    final totalPadding = chipPadding * 2;
    final topRowChipCount = sizeClass == ScreenSizeClass.expanded ? 3 : 2;
    final topRowTotalSpacing = chipSpacing * (topRowChipCount - 1);
    final topRowChipWidth = (availableWidth - totalPadding - topRowTotalSpacing) / topRowChipCount;
    
    // Air quality chip takes full width minus padding
    final airChipWidth = availableWidth - totalPadding;
    
    // Watch environment data from Firebase
    final envAsync = ref.watch(environmentProvider);
    
    return AppCard(
      padding: EdgeInsets.all(chipPadding),
      child: envAsync.when(
        data: (env) {
          // Format temperature
          final tempValue = env.temperature != null
              ? '${env.temperature!.round()}°C'
              : '--°C';
          
          // Format humidity
          final humValue = env.humidity != null
              ? '${env.humidity!.round()}%'
              : '--%';
          
          // Air quality (with fallback)
          final airValue = env.airQuality ?? 'Trong lành';
          
          // Light level (with fallback)
          final lightValue = env.lightLevel ?? 'Đủ sáng';
          
          return Column(
            children: [
              // Top row: Nhiệt độ, Độ ẩm, Ánh sáng (if expanded)
              Row(
                children: [
                  Expanded(
                    child: DashboardStatusChip(
                      icon: Icons.device_thermostat,
                      iconAsset: 'assets/icons/temperature.svg',
                      title: 'Nhiệt độ',
                      value: tempValue,
                      background: AppColors.white,
                      width: topRowChipWidth,
                    ),
                  ),
                  SizedBox(width: chipSpacing),
                  Expanded(
                    child: DashboardStatusChip(
                      icon: Icons.water_drop_outlined,
                      iconAsset: 'assets/icons/humidity.svg',
                      title: 'Độ ẩm',
                      value: humValue,
                      background: AppColors.white,
                      width: topRowChipWidth,
                    ),
                  ),
                  if (sizeClass == ScreenSizeClass.expanded) ...[
                    SizedBox(width: chipSpacing),
                    Expanded(
                      child: DashboardStatusChip(
                        icon: Icons.wb_sunny_outlined,
                        iconAsset: 'assets/icons/bright.svg',
                        title: 'Ánh sáng',
                        value: lightValue,
                        background: AppColors.white,
                        width: topRowChipWidth,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: chipSpacing),
              // Bottom row: Không khí (centered, full width)
              Center(
                child: DashboardStatusChip(
                  icon: Icons.eco_outlined,
                  iconAsset: 'assets/icons/air.svg',
                  title: 'Không khí',
                  value: airValue,
                  background: AppColors.white,
                  width: airChipWidth,
                ),
              ),
            ],
          );
        },
        loading: () {
          // Show loading placeholders
          return Column(
            children: [
              // Top row: Nhiệt độ, Độ ẩm, Ánh sáng (if expanded)
              Row(
                children: [
                  Expanded(
                    child: DashboardStatusChip(
                      icon: Icons.device_thermostat,
                      iconAsset: 'assets/icons/temperature.svg',
                      title: 'Nhiệt độ',
                      value: '...',
                      background: AppColors.white,
                      width: topRowChipWidth,
                    ),
                  ),
                  SizedBox(width: chipSpacing),
                  Expanded(
                    child: DashboardStatusChip(
                      icon: Icons.water_drop_outlined,
                      iconAsset: 'assets/icons/humidity.svg',
                      title: 'Độ ẩm',
                      value: '...',
                      background: AppColors.white,
                      width: topRowChipWidth,
                    ),
                  ),
                  if (sizeClass == ScreenSizeClass.expanded) ...[
                    SizedBox(width: chipSpacing),
                    Expanded(
                      child: DashboardStatusChip(
                        icon: Icons.wb_sunny_outlined,
                        iconAsset: 'assets/icons/bright.svg',
                        title: 'Ánh sáng',
                        value: '...',
                        background: AppColors.white,
                        width: topRowChipWidth,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: chipSpacing),
              // Bottom row: Không khí (centered, full width)
              Center(
                child: DashboardStatusChip(
                  icon: Icons.eco_outlined,
                  iconAsset: 'assets/icons/air.svg',
                  title: 'Không khí',
                  value: '...',
                  background: AppColors.white,
                  width: airChipWidth,
                ),
              ),
            ],
          );
        },
        error: (error, stack) {
          // Show error placeholders with fallback values
          return Column(
            children: [
              // Top row: Nhiệt độ, Độ ẩm, Ánh sáng (if expanded)
              Row(
                children: [
                  Expanded(
                    child: DashboardStatusChip(
                      icon: Icons.device_thermostat,
                      iconAsset: 'assets/icons/temperature.svg',
                      title: 'Nhiệt độ',
                      value: '28°C',
                      background: AppColors.white,
                      width: topRowChipWidth,
                    ),
                  ),
                  SizedBox(width: chipSpacing),
                  Expanded(
                    child: DashboardStatusChip(
                      icon: Icons.water_drop_outlined,
                      iconAsset: 'assets/icons/humidity.svg',
                      title: 'Độ ẩm',
                      value: '70%',
                      background: AppColors.white,
                      width: topRowChipWidth,
                    ),
                  ),
                  if (sizeClass == ScreenSizeClass.expanded) ...[
                    SizedBox(width: chipSpacing),
                    Expanded(
                      child: DashboardStatusChip(
                        icon: Icons.wb_sunny_outlined,
                        iconAsset: 'assets/icons/bright.svg',
                        title: 'Ánh sáng',
                        value: 'Đủ sáng',
                        background: AppColors.white,
                        width: topRowChipWidth,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: chipSpacing),
              // Bottom row: Không khí (centered, full width)
              Center(
                child: DashboardStatusChip(
                  icon: Icons.eco_outlined,
                  iconAsset: 'assets/icons/air.svg',
                  title: 'Không khí',
                  value: 'Trong lành',
                  background: AppColors.white,
                  width: airChipWidth,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Scenario shortcut card that executes scenario when tapped
class _ScenarioShortcutCard extends ConsumerWidget {
  const _ScenarioShortcutCard({
    required this.icon,
    required this.title,
    required this.background,
    required this.scenarioId,
  });

  final IconData icon;
  final String title;
  final Color background;
  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeClass = context.screenSizeClass;
    final minHeight = sizeClass == ScreenSizeClass.expanded 
        ? 140.0
        : sizeClass == ScreenSizeClass.medium
            ? 130.0
            : 120.0;
    
    final iconRadius = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.cardRadius + 2
        : AppSpacing.cardRadius;
    
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl
        : AppSpacing.lg;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        splashColor: AppColors.primary.withAlpha(30),
        highlightColor: AppColors.primary.withAlpha(20),
        onTap: () async {
          // Execute scenario
          try {
            await ref.read(executeScenarioProvider(scenarioId).future);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã thực hiện: $title'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: iconRadius,
                backgroundColor: Colors.white,
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: iconRadius * 1.2,
                ),
              ),
              SizedBox(height: sizeClass == ScreenSizeClass.compact 
                  ? AppSpacing.sm 
                  : AppSpacing.md),
              Text(
                title,
                style: context.responsiveBodyM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
