import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/room_model.dart';

/// Local data source for rooms
abstract class RoomLocalDataSource {
  List<RoomModel> getRooms();
  RoomModel? getRoomById(String id);
}

/// Mock implementation
class RoomLocalDataSourceImpl implements RoomLocalDataSource {
  static final List<RoomModel> _rooms = _createMockRooms();

  @override
  List<RoomModel> getRooms() {
    return List.unmodifiable(_rooms);
  }

  @override
  RoomModel? getRoomById(String id) {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<RoomModel> _createMockRooms() {
    return [
      RoomModel(
        id: 'living',
        name: 'Phòng khách',
        iconCode: Icons.weekend_outlined.codePoint,
        backgroundColorValue: AppColors.roomPeach.toARGB32(),
        keywords: ['phòng khách', 'living'],
      ),
      RoomModel(
        id: 'bedroom',
        name: 'Phòng ngủ',
        iconCode: Icons.bed_outlined.codePoint,
        backgroundColorValue: AppColors.roomSky.toARGB32(),
        keywords: ['phòng ngủ', 'bed'],
      ),
      RoomModel(
        id: 'gate',
        name: 'Cổng',
        iconCode: Icons.garage_outlined.codePoint,
        backgroundColorValue: AppColors.roomMint.toARGB32(),
        keywords: ['cửa chính', 'cổng', 'gate'],
      ),
      RoomModel(
        id: 'bath',
        name: 'Phòng tắm',
        iconCode: Icons.bathtub_outlined.codePoint,
        backgroundColorValue: AppColors.roomLavender.toARGB32(),
        keywords: ['tắm', 'bath'],
      ),
    ];
  }
}

