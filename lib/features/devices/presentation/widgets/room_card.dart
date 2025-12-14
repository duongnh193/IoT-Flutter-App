import 'package:flutter/material.dart';

import '../../../../core/constants/app_typography.dart';
import '../../data/models/room_model.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: room.background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(room.icon, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                room.name,
                style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
