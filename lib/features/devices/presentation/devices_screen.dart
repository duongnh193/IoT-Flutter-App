import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/main_layout.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';
import 'widgets/device_card.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceControllerProvider);
    final grouped = _groupByType(devices);

    return MainLayout(
      title: 'Thiết bị',
      subtitle: 'Quản lý thiết bị trong nhà',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      child: ListView(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grouped.entries
                .map(
                  (entry) => Chip(
                    avatar: Icon(entry.key.icon, size: 18),
                    label: Text('${entry.key.label} • ${entry.value}'),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ...devices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DeviceCard(
                device: device,
                onToggle: () => ref
                    .read(deviceControllerProvider.notifier)
                    .toggle(device.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<DeviceType, int> _groupByType(List<Device> devices) {
    final map = <DeviceType, int>{};
    for (final device in devices) {
      map.update(device.type, (value) => value + 1, ifAbsent: () => 1);
    }
    return map;
  }
}
