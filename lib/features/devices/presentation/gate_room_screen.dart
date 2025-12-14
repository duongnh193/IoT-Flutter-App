import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../domain/entities/device_type.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';
import '../providers/room_provider.dart';

/// Gate room screen with special layout: device, access history, and card management
class GateRoomScreen extends ConsumerWidget {
  const GateRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    final devices = ref.watch(devicesProvider);
    final sizeClass = context.screenSizeClass;

    return roomsAsync.when(
      data: (rooms) {
        // Handle empty rooms list
        if (rooms.isEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy phòng Cổng',
              style: context.responsiveBodyM.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        // Find gate room
        final gateRoom = rooms.firstWhere(
          (r) => r.id == 'gate',
          orElse: () => rooms.first,
        );

        // Get gate device - filter by room name/keywords AND device type/name
        final gateDevices = devices.where((d) {
          final roomName = d.room.toLowerCase();
          final deviceName = d.name.toLowerCase();
          final keywords = [
            gateRoom.name.toLowerCase(),
            ...?gateRoom.keywords?.map((e) => e.toLowerCase()),
          ];
          
          // Match by room name/keywords
          final matchesRoom = keywords.any((k) => roomName.contains(k));
          
          // Also match devices with lock type or gate-related names in any room
          final isLockDevice = d.type == DeviceType.lock;
          final hasGateName = deviceName.contains('cổng') || 
                             deviceName.contains('gate') ||
                             deviceName.contains('khóa');
          
          return matchesRoom || (isLockDevice && hasGateName);
        }).toList();

        // Handle no gate devices found - create a default gate device
        Device gateDevice;
        if (gateDevices.isEmpty) {
          // Create default gate device as fallback
          gateDevice = const Device(
            id: 'gate-main-default',
            name: 'Cổng Chính',
            type: DeviceType.lock,
            room: 'Cổng',
            isOn: false,
          );
        } else {
          // Prioritize: devices with "Cổng Chính" name, then lock type devices
          gateDevice = gateDevices.firstWhere(
            (d) => d.name.toLowerCase().contains('cổng chính') || 
                  d.id == 'gate-main',
            orElse: () {
              // Second priority: any device with "cổng" in name
              return gateDevices.firstWhere(
                (d) => d.name.toLowerCase().contains('cổng'),
                orElse: () => gateDevices.first, // Fallback to first device
              );
            },
          );
        }

        // Mock access history
        const accessHistory = [
          ('Nguyễn Đức Thịnh', '12:20'),
          ('Nguyễn Đức Hoàng', '08:12'),
          ('Đình Trọng Thành', '3:34'),
        ];

        return ContentScaffold(
          title: gateRoom.name,
          showBack: true,
          panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
          horizontalPaddingFactor: 0.06,
          scrollable: true,
          titleWidget: _GateHeader(room: gateRoom),
          body: (context, constraints) {
            final sectionSpacing = sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.md 
                : AppSpacing.lg;
            final dividerSpacing = sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.xl 
                : AppSpacing.xxl;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Thiết Bị" Section
                Text(
                  'Thiết Bị',
                  style: context.responsiveTitleM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: sectionSpacing),
                
                // Gate device row
                _DeviceRow(
                  device: gateDevice,
                  status: gateDevice.isOn ? 'Đang Mở' : 'Đang Đóng',
                  onToggle: () {
                    ref.read(deviceControllerProvider.notifier).toggle(gateDevice.id);
                  },
                ),
                
                Divider(
                  height: dividerSpacing,
                  thickness: 1,
                  color: AppColors.borderSoft,
                ),
                
                // "Lịch Sử Ra Vào:" Section
                Text(
                  'Lịch Sử Ra Vào:',
                  style: context.responsiveTitleM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: sectionSpacing),
                
                // Access history list
                _AccessHistoryList(history: accessHistory),
                
                SizedBox(height: dividerSpacing),
                
                // Action buttons: Thêm Thẻ and Xoá Thẻ
                _CardActionButtons(),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Lỗi: $error', style: context.responsiveBodyM),
      ),
    );
  }
}

/// Gate header with icon
class _GateHeader extends StatelessWidget {
  const _GateHeader({required this.room});

  final dynamic room;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 56.0 : 48.0;

    return Row(
      children: [
        Expanded(
          child: Text(
            room.name,
            style: context.responsiveHeadlineL.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(
          room.icon,
          size: iconSize,
          color: Colors.white,
        ),
      ],
    );
  }
}

/// Device row with icon, name, status, and toggle switch
class _DeviceRow extends ConsumerWidget {
  const _DeviceRow({
    required this.device,
    required this.status,
    required this.onToggle,
  });

  final Device device;
  final String status;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(deviceControllerProvider);
    final isOn = devicesAsync.when(
      data: (devices) {
        final currentDevice = devices.firstWhere(
          (d) => d.id == device.id,
          orElse: () => device,
        );
        return currentDevice.isOn;
      },
      loading: () => device.isOn,
      error: (_, __) => device.isOn,
    );

    final sizeClass = context.screenSizeClass;
    final iconRadius = sizeClass == ScreenSizeClass.expanded ? 28.0 : 24.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 32.0 : 28.0;

    return Row(
      children: [
        // Icon - gate icon for gate device
        CircleAvatar(
          radius: iconRadius,
          backgroundColor: AppColors.primarySoft,
          child: Icon(
            Icons.garage_outlined, // Gate icon
            color: AppColors.primary,
            size: iconSize,
          ),
        ),
        SizedBox(width: sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.md 
            : AppSpacing.lg),
        
        // Name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: context.responsiveTitleM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                status,
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Toggle switch
        Transform.scale(
          scale: sizeClass == ScreenSizeClass.expanded ? 1.2 : 1.0,
          child: Switch(
            value: isOn,
            onChanged: (_) => onToggle(),
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            inactiveTrackColor: AppColors.borderSoft,
            inactiveThumbColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Access history list
class _AccessHistoryList extends StatelessWidget {
  const _AccessHistoryList({required this.history});

  final List<(String, String)> history;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    
    return Column(
      children: history.map((entry) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.md 
                : AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.$1,
                  style: context.responsiveBodyM.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: AppColors.borderSoft,
                margin: EdgeInsets.symmetric(
                  horizontal: sizeClass == ScreenSizeClass.compact 
                      ? AppSpacing.md 
                      : AppSpacing.lg,
                ),
              ),
              Text(
                entry.$2,
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Card action buttons: Thêm Thẻ and Xoá Thẻ
class _CardActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final buttonHeight = sizeClass == ScreenSizeClass.expanded ? 56.0 : 48.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 24.0 : 20.0;
    final spacing = sizeClass == ScreenSizeClass.compact 
        ? AppSpacing.md 
        : AppSpacing.lg;

    return Row(
      children: [
        Expanded(
          child: _CardActionButton(
            label: 'Thêm Thẻ',
            backgroundColor: AppColors.roomSky,
            icon: Icons.add,
            iconSize: iconSize,
            height: buttonHeight,
            onTap: () {
              // TODO: Implement add card functionality
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng Thêm Thẻ đang phát triển')),
                );
              }
            },
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _CardActionButton(
            label: 'Xoá Thẻ',
            backgroundColor: AppColors.primary,
            icon: Icons.delete_outline,
            iconSize: iconSize,
            height: buttonHeight,
            onTap: () {
              // TODO: Implement delete card functionality
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng Xoá Thẻ đang phát triển')),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.backgroundColor,
    required this.icon,
    required this.iconSize,
    required this.height,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final IconData icon;
  final double iconSize;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md)
        : EdgeInsets.symmetric(vertical: AppSpacing.md + 2, horizontal: AppSpacing.md);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: onTap,
        child: Container(
          height: height,
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: context.responsiveBodyM.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

