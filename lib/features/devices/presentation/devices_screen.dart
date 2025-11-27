import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../providers/room_provider.dart';
import 'widgets/room_card.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomListProvider);

    return AuthScaffold(
      title: 'Chọn Phòng',
      panelHeightFactor: 0.8,
      contentTopPaddingFactor: 0.08,
      showWave: false,
      panelScrollable: false,
      horizontalPaddingFactor: 0.08,
      panelBuilder: (constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 3.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: rooms.length,
            itemBuilder: (_, index) {
              final room = rooms[index];
              return RoomCard(
                room: room,
                onTap: () => context.push('/devices/${room.id}'),
              );
            },
          ),
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
}
