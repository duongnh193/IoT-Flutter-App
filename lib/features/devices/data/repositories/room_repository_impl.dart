import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_local_datasource.dart';

/// Implementation of RoomRepository
class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._localDataSource);

  final RoomLocalDataSource _localDataSource;

  @override
  Future<List<RoomEntity>> getRooms() async {
    final rooms = _localDataSource.getRooms();
    return rooms.map((model) => model.toEntity()).toList();
  }

  @override
  Future<RoomEntity?> getRoomById(String id) async {
    final room = _localDataSource.getRoomById(id);
    return room?.toEntity();
  }
}

