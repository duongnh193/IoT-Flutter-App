import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../providers/room_provider.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomNames = ref.watch(roomListProvider);
    final rooms = roomNames
        .map(
          (name) => _RoomItem(
            label: name,
            icon: _iconForRoom(name),
          ),
        )
        .toList();

    return AuthScaffold(
      title: 'Chọn Phòng',
      panelHeightFactor: 0.8,
      contentTopPaddingFactor: 0.08,
      showWave: false,
      panelScrollable: true,
      horizontalPaddingFactor: 0.08,
      panelBuilder: (constraints) {
        const spacing = 20.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.h12,
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: rooms
                  .map(
                    (room) => SizedBox(
                      width: itemWidth,
                      child: _RoomCard(room: room),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
      titleWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn Phòng',
              style: AppTypography.headlineL,
            ),
            const SizedBox(height: 8),
            const Icon(Icons.home_work_outlined,
                size: 56, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  IconData _iconForRoom(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('khách')) return Icons.weekend_outlined;
    if (lower.contains('ngủ')) return Icons.bed_outlined;
    if (lower.contains('tắm')) return Icons.bathtub_outlined;
    if (lower.contains('bếp')) return Icons.kitchen_outlined;
    if (lower.contains('garage')) return Icons.garage_outlined;
    if (lower.contains('cổng')) return Icons.garage_outlined;
    return Icons.home_outlined;
  }
}

class _RoomItem {
  const _RoomItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room});

  final _RoomItem room;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.skySoft,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.primary.withAlpha(30),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                room.icon,
                size: 38,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                room.label,
                style: AppTypography.bodyM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
