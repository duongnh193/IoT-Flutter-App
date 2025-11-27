import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';

class Room {
  const Room({
    required this.id,
    required this.name,
    required this.icon,
    required this.background,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final IconData icon;
  final Color background;
  final List<String>? keywords;
}

final roomListProvider = Provider<List<Room>>((_) {
  return const [
    Room(
      id: 'living',
      name: 'Phòng khách',
      icon: Icons.weekend_outlined,
      background: AppColors.roomPeach,
      keywords: ['phòng khách', 'living'],
    ),
    Room(
      id: 'bedroom',
      name: 'Phòng ngủ',
      icon: Icons.bed_outlined,
      background: AppColors.roomSky,
      keywords: ['phòng ngủ', 'bed'],
    ),
    Room(
      id: 'gate',
      name: 'Cổng',
      icon: Icons.garage_outlined,
      background: AppColors.roomMint,
      keywords: ['cửa chính', 'cổng', 'gate'],
    ),
    Room(
      id: 'bath',
      name: 'Phòng tắm',
      icon: Icons.bathtub_outlined,
      background: AppColors.roomLavender,
      keywords: ['tắm', 'bath'],
    ),
  ];
});
