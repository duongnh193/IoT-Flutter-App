import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../providers/room_provider.dart';
import 'widgets/room_card.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    final sizeClass = context.screenSizeClass;
    
    return ContentScaffold(
      title: 'Chọn Phòng',
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.90 : 0.85,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      titleWidget: _TitleSection(context: context),
      body: (context, constraints) {
        return roomsAsync.when(
          data: (rooms) => _buildRoomsGrid(context, constraints, rooms),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Lỗi: $error',
                style: context.responsiveBodyM,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomsGrid(
    BuildContext context,
    BoxConstraints constraints,
    List rooms,
  ) {
    final sizeClass = context.screenSizeClass;
    final maxCrossAxisExtent = context.responsiveGridMaxCrossAxisExtent;
    final crossAxisSpacing = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.lg 
        : AppSpacing.md;
    final mainAxisSpacing = crossAxisSpacing;
    final aspectRatio = context.responsiveGridChildAspectRatio;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: rooms.length,
      itemBuilder: (_, index) {
        final room = rooms[index];
        return RoomCard(
          room: room,
          onTap: () => context.push('/devices/${room.id}'),
        );
      },
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
            'Chọn Phòng',
            style: context.responsiveHeadlineL.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(
          Icons.meeting_room,
          size: iconSize,
          color: Colors.white,
        ),
      ],
    );
  }
}
