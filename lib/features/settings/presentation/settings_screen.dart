import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    
    final tiles = [
      const _SettingsTileData(
        icon: Icons.person_outline,
        title: 'Hồ sơ',
        subtitle: 'Tài khoản, thông báo, quyền truy cập',
      ),
      const _SettingsTileData(
        icon: Icons.wifi_tethering,
        title: 'Kết nối',
        subtitle: 'Wi-Fi, mạng nội bộ, cloud backend',
      ),
      const _SettingsTileData(
        icon: Icons.shield_outlined,
        title: 'Bảo mật',
        subtitle: 'Xác thực 2 lớp, quyền thiết bị',
      ),
      const _SettingsTileData(
        icon: Icons.palette_outlined,
        title: 'Giao diện',
        subtitle: 'Theme sáng/tối, ngôn ngữ, bố cục',
      ),
      const _SettingsTileData(
        icon: Icons.info_outline,
        title: 'Thông tin hệ thống',
        subtitle: 'Phiên bản app, trạng thái dịch vụ',
      ),
    ];

    return ContentScaffold(
      title: 'Cài đặt',
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.90 : 0.85,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      titleWidget: _TitleSection(context: context),
      body: (context, constraints) {
        final spacing = sizeClass == ScreenSizeClass.expanded 
            ? AppSpacing.lg 
            : AppSpacing.md;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tiles.map(
            (tile) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: _SettingsTile(tile: tile),
            ),
          ).toList(),
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
            'Cài đặt',
            style: context.responsiveHeadlineL.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(
          Icons.settings_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ],
    );
  }
}

class _SettingsTileData {
  const _SettingsTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.tile});

  final _SettingsTileData tile;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final avatarRadius = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.cardRadius + 8 
        : sizeClass == ScreenSizeClass.medium
            ? AppSpacing.cardRadius + 6
            : AppSpacing.cardRadius + 4;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.md + 2,
          );
    
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () {},
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.primarySoft,
                child: Icon(
                  tile.icon, 
                  color: AppColors.primary,
                  size: avatarRadius * 0.85,
                ),
              ),
              SizedBox(width: sizeClass == ScreenSizeClass.expanded 
                  ? AppSpacing.lg 
                  : AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tile.title,
                      style: context.responsiveTitleM.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: sizeClass == ScreenSizeClass.expanded 
                        ? AppSpacing.xs 
                        : AppSpacing.xs / 2),
                    Text(
                      tile.subtitle,
                      style: context.responsiveBodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right, 
                color: AppColors.textSecondary,
                size: sizeClass == ScreenSizeClass.expanded ? 28.0 : 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
