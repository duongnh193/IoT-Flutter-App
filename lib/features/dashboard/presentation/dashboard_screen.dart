import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../devices/providers/device_provider.dart';
import '../../devices/presentation/widgets/device_card.dart';
import '../../scenes/providers/scene_provider.dart';
import '../../scenes/presentation/scene_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../../shared/layout/main_layout.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceControllerProvider);
    final scenes = ref.watch(sceneControllerProvider);
    final activeDevices = ref.watch(activeDevicesCountProvider);
    final load = ref.watch(estimatedLoadProvider);
    final activeScenes = ref.watch(activeSceneCountProvider);

    return MainLayout(
      title: 'Nhà thông minh',
      subtitle: 'Điều khiển & tự động hóa',
      padding: EdgeInsets.zero,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                      activeDevices: activeDevices, activeScenes: activeScenes),
                  const SizedBox(height: 16),
                  _EnergyCard(load: load, deviceCount: activeDevices),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Thiết bị đang dùng',
                    actionLabel: 'Xem tất cả',
                    onActionTap: () =>
                        context.goNamed(AppRoute.devices.name),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: devices.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return SizedBox(
                          width: 180,
                          child: DeviceCard(
                            device: device,
                            compact: true,
                            onToggle: () => ref
                                .read(deviceControllerProvider.notifier)
                                .toggle(device.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Ngữ cảnh nhanh',
                    actionLabel: 'Quản lý',
                    onActionTap: () => context.goNamed(AppRoute.scenes.name),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scenes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final scene = scenes[index];
                      return SceneCard(
                        scene: scene,
                        onToggle: () => ref
                            .read(sceneControllerProvider.notifier)
                            .toggle(scene.id),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.activeDevices,
    required this.activeScenes,
  });

  final int activeDevices;
  final int activeScenes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào 👋',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhà thông minh',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text('$activeDevices thiết bị đang bật'),
                  avatar: const Icon(Icons.flash_on, size: 18),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('$activeScenes ngữ cảnh'),
                  avatar: const Icon(Icons.auto_awesome, size: 18),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.shield_moon_outlined),
        ),
      ],
    );
  }
}

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.load, required this.deviceCount});

  final double load;
  final int deviceCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0C9BFF), Color(0xFF0D3E90)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tải hiện tại',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(219),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${load.toStringAsFixed(0)} W',
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(36),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$deviceCount thiết bị',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Ổn định • cập nhật từ thiết bị',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(224),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
