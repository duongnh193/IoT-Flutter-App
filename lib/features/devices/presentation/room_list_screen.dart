import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../core/router/app_router.dart';
import '../data/models/room_model.dart';
import '../providers/device_provider.dart';
import '../providers/room_provider.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';

class RoomListScreen extends ConsumerWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    final devices = ref.watch(devicesProvider);
    final sizeClass = context.screenSizeClass;
    
    return ContentScaffold(
      title: 'Phòng',
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      titleWidget: _TitleSection(context: context),
      body: (context, constraints) {
        return roomsAsync.when(
          data: (rooms) => _buildRoomsList(context, rooms, devices),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Lỗi: $error', style: context.responsiveBodyM),
          ),
        );
      },
    );
  }

  Widget _buildRoomsList(BuildContext context, List rooms, List devices) {
    final sizeClass = context.screenSizeClass;
    final spacing = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl 
        : AppSpacing.lg;
    
    // Calculate tile width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06 * 2; // Left + right padding
    final availableWidth = screenWidth - horizontalPadding;
    
    // For expanded: 2 columns, medium: 2 columns, compact: 1 column
    final crossAxisCount = sizeClass == ScreenSizeClass.expanded ? 2 : 
                          sizeClass == ScreenSizeClass.medium ? 2 : 1;
    final tileWidth = (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
    
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: rooms.map((room) {
        final roomDevices = devices.where((d) {
          final roomName = d.room.toLowerCase();
          final keywords = [
            room.name.toLowerCase(),
            ...?room.keywords?.map((e) => e.toLowerCase()),
          ];
          return keywords.any((k) => roomName.contains(k));
        }).toList();
        
        final deviceLabel = roomDevices.isEmpty 
            ? 'Không có thiết bị' 
            : '${roomDevices.length} thiết bị';
        final status = roomDevices.isEmpty 
            ? 'Không có thiết bị' 
            : 'Đang hoạt động';

        return SizedBox(
          width: tileWidth,
          child: _RoomTile(
            room: room,
            deviceLabel: deviceLabel,
            statusLabel: status,
            onTap: () => context.pushNamed(
              AppRoute.roomDetail.name,
              pathParameters: {'roomId': room.id},
            ),
          ),
        );
      }).toList(),
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
            'Phòng',
            style: context.responsiveHeadlineL.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(
          Icons.home_outlined,
          size: iconSize,
          color: Colors.white,
        ),
      ],
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.deviceLabel,
    required this.statusLabel,
    required this.onTap,
  });

  final Room room;
  final String deviceLabel;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl 
        : AppSpacing.lg;
    final iconRadius = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.cardRadius + AppSpacing.md 
        : AppSpacing.cardRadius + AppSpacing.sm;
    
    return Material(
      color: room.background,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius + AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius + AppSpacing.sm),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: iconRadius,
                backgroundColor: AppColors.white,
                child: Icon(room.icon, color: AppColors.textPrimary),
              ),
              AppSpacing.h12,
              Text(
                room.name,
                style: context.responsiveTitleM,
              ),
              AppSpacing.h8,
              Text(
                deviceLabel,
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.h4,
              Text(
                statusLabel,
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
