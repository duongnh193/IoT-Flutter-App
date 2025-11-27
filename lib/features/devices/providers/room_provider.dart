import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';

class Room {
  const Room({
    required this.id,
    required this.name,
    required this.icon,
    required this.background,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color background;
}

final roomListProvider = Provider<List<Room>>((_) {
  return const [
    Room(
      id: 'living',
      name: 'Phòng khách',
      icon: Icons.weekend_outlined,
      background: AppColors.roomPeach,
    ),
    Room(
      id: 'bedroom',
      name: 'Phòng ngủ',
      icon: Icons.bed_outlined,
      background: AppColors.roomSky,
    ),
    Room(
      id: 'gate',
      name: 'Cổng',
      icon: Icons.garage_outlined,
      background: AppColors.roomMint,
    ),
    Room(
      id: 'bath',
      name: 'Phòng tắm',
      icon: Icons.bathtub_outlined,
      background: AppColors.roomLavender,
    ),
  ];
});
