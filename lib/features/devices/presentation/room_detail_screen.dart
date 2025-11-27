import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';
import '../providers/room_provider.dart';
import 'widgets/device_card.dart';
import 'device_control_screen.dart';
import 'gate_control_screen.dart';

class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomListProvider);
    final room = rooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => rooms.first,
    );

    final devices = ref.watch(deviceControllerProvider).where((d) {
      final roomName = d.room.toLowerCase();
      final keywords = [
        room.name.toLowerCase(),
        ...?room.keywords?.map((e) => e.toLowerCase()),
      ];
      return keywords.any((k) => roomName.contains(k));
    }).toList();

    return AuthScaffold(
      title: room.name,
      showWave: false,
      contentTopPaddingFactor: 0.08,
      panelHeightFactor: 0.86,
      panelScrollable: false,
      horizontalPaddingFactor: 0.06,
      panelBuilder: (constraints) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.h12,
              Text(
                'Thiết bị trong ${room.name}',
                style: AppTypography.titleM,
              ),
              AppSpacing.h12,
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 3 / 3.6,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: devices.length,
                itemBuilder: (_, index) {
                  final device = devices[index];
                  WidgetBuilder? controlBuilder;
                  if (device.type == DeviceType.climate) {
                    controlBuilder = (_) => DeviceControlScreen(device: device);
                  } else if (device.type == DeviceType.lock) {
                    controlBuilder = (_) => GateControlScreen(device: device);
                  }
                  return DeviceCard(
                    device: device,
                    compact: true,
                    onToggle: () => ref
                        .read(deviceControllerProvider.notifier)
                        .toggle(device.id),
                    controlBuilder: controlBuilder,
                  );
                },
              ),
            ],
          ),
        );
      },
      titleWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name, style: AppTypography.headlineL),
                const SizedBox(height: 4),
                Text(
                  '${devices.length} thiết bị',
                  style: AppTypography.bodyM,
                ),
              ],
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(room.icon, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
