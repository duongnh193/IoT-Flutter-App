import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

    return AuthScaffold(
      title: 'Cài đặt',
      panelHeightFactor: 0.8,
      contentTopPaddingFactor: 0.08,
      showWave: false,
      panelScrollable: false,
      horizontalPaddingFactor: 0.06,
      panelBuilder: (_) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.h12,
              ...tiles.map(
                (tile) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SettingsTile(tile: tile),
                ),
              ),
            ],
          ),
        );
      },
      titleWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'Cài đặt',
              style: AppTypography.headlineL,
            ),
            AppSpacing.h12,
            const Icon(Icons.settings_rounded,
                size: 48, color: Colors.black87),
          ],
        ),
      ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: AppSpacing.cardRadius + 6,
                backgroundColor: AppColors.primarySoft,
                child: Icon(tile.icon, color: AppColors.primary),
              ),
              AppSpacing.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tile.title,
                      style: AppTypography.titleM,
                    ),
                    AppSpacing.h4,
                    Text(
                      tile.subtitle,
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
