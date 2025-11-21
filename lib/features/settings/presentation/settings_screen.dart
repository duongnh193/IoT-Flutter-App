import 'package:flutter/material.dart';

import '../../../shared/layout/main_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      const _SettingsTile(
        icon: Icons.person_outline,
        title: 'Hồ sơ',
        subtitle: 'Tài khoản, thông báo, quyền truy cập',
      ),
      const _SettingsTile(
        icon: Icons.wifi_tethering,
        title: 'Kết nối',
        subtitle: 'Wi-Fi, mạng nội bộ, cloud backend',
      ),
      const _SettingsTile(
        icon: Icons.shield_outlined,
        title: 'Bảo mật',
        subtitle: 'Xác thực 2 lớp, quyền thiết bị',
      ),
      const _SettingsTile(
        icon: Icons.palette_outlined,
        title: 'Giao diện',
        subtitle: 'Theme sáng/tối, ngôn ngữ, bố cục',
      ),
      const _SettingsTile(
        icon: Icons.info_outline,
        title: 'Thông tin hệ thống',
        subtitle: 'Phiên bản app, trạng thái dịch vụ',
      ),
    ];

    return MainLayout(
      title: 'Cài đặt',
      subtitle: 'Cấu hình tài khoản & hệ thống',
      child: ListView.separated(
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) => tiles[index],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHigh,
        child: Icon(icon, color: colorScheme.onSurface),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
