import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../../devices/providers/device_provider.dart';
import '../../scenes/providers/scene_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceControllerProvider);
    final scenes = ref.watch(sceneControllerProvider);
    final activeDevices = ref.watch(activeDevicesCountProvider);
    final rooms = devices.map((d) => d.room).toSet().toList();
    final roomCards = rooms.take(2).toList();

    return AuthScaffold(
      title: 'Hi, TEST USER',
      panelHeightFactor: 0.92,
      contentTopPaddingFactor: 0.05,
      waveOffset: 0,
      showWave: false,
      panelScrollable: true,
      panelBuilder: (panelConstraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopStats(totalDevices: devices.length, activeDevices: activeDevices),
            AppSpacing.h20,
            _SectionHeader(
              title: 'Living Room',
              subtitle: 'A total of ${devices.length} devices',
              trailing: const Icon(Icons.more_horiz),
            ),
            AppSpacing.h12,
            SizedBox(
              height: 180,
              child: Row(
                children: roomCards.map((room) {
                  final count = devices.where((d) => d.room == room).length;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: room == roomCards.last ? 0 : 12,
                      ),
                      child: _RoomGridCard(
                        title: room,
                        subtitle: '$count devices',
                        highlighted: roomCards.indexOf(room) == 0,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            AppSpacing.h24,
            _SectionHeader(
              title: 'Ngữ cảnh',
              trailing: TextButton(
                onPressed: () => context.goNamed(AppRoute.scenes.name),
                child: const Text('Quản lý'),
              ),
            ),
            AppSpacing.h12,
            ...scenes.map(
              (scene) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SceneTile(
                  title: scene.name,
                  subtitle: scene.description,
                  isActive: scene.isActive,
                  onToggle: () => ref
                      .read(sceneControllerProvider.notifier)
                      .toggle(scene.id),
                ),
              ),
            ),
          ],
        );
      },
      // custom header with avatar
      titleWidget: Row(
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
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withAlpha(51),
            child: SvgPicture.asset(
              'assets/icons/icons8-home 2.svg',
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStats extends StatelessWidget {
  const _TopStats({required this.totalDevices, required this.activeDevices});

  final int totalDevices;
  final int activeDevices;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(text: '$activeDevices thiết bị bật'),
        const SizedBox(width: 8),
        _Pill(text: '$totalDevices tổng thiết bị'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              Text(
                title,
                style: AppTypography.titleM.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _RoomGridCard extends StatelessWidget {
  const _RoomGridCard({
    required this.title,
    required this.subtitle,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bgColor = highlighted ? AppColors.primary : Colors.white;
    final textColor = highlighted ? Colors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.borderSoft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: highlighted
                ? Colors.white.withAlpha(31)
                : AppColors.primarySoft,
            child: Icon(Icons.lightbulb_outline,
                color: highlighted ? Colors.white : AppColors.primary),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTypography.titleM.copyWith(color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTypography.bodyM.copyWith(
              color: highlighted ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneTile extends StatelessWidget {
  const _SceneTile({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_mode, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleM,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeColor: AppColors.primary,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(77)),
      ),
      child: Text(
        text,
        style: AppTypography.labelM.copyWith(color: Colors.white),
      ),
    );
  }
}
