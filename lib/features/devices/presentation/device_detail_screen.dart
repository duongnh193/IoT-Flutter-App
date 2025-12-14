import 'package:flutter/material.dart';

import '../domain/entities/device_type.dart';
import 'smart_home_mock.dart';
import 'panels/ac_panel.dart';
import 'panels/curtain_panel.dart';
import 'panels/fan_panel.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({
    super.key,
    required this.roomId,
    required this.deviceId,
  });

  final String roomId;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    final entry = deviceById(deviceId);

    if (entry == null) {
      return AppScaffold(
        title: 'Thiết bị',
        showBack: true,
        body: const Text('Không tìm thấy thiết bị'),
      );
    }

    if (entry.isPlaceholder) {
      return AppScaffold(
        title: entry.device.name,
        showBack: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tính năng đang phát triển',
              style: AppTypography.titleM,
            ),
            AppSpacing.h8,
            Text(
              'Thiết bị này sẽ được cập nhật sớm.',
              style: AppTypography.bodyM.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    switch (entry.device.type) {
      case DeviceType.curtain:
        return CurtainPanel(device: entry.device);
      case DeviceType.fan:
        return FanPanel(device: entry.device);
      case DeviceType.ac:
        return ACPanel(device: entry.device);
      default:
        return AppScaffold(
          title: entry.device.name,
          showBack: true,
          body: const Text('Thiết bị chưa được hỗ trợ'),
        );
    }
  }
}
