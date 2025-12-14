import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/device_firebase_datasource.dart';
import '../data/datasources/device_local_datasource.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../data/datasources/room_local_datasource.dart';
import '../data/repositories/device_repository_impl.dart';
import '../data/repositories/room_repository_impl.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/repositories/room_repository.dart';
import '../domain/usecases/get_device_by_id_use_case.dart';
import '../domain/usecases/get_devices_by_room_use_case.dart';
import '../domain/usecases/get_devices_use_case.dart';
import '../domain/usecases/get_room_by_id_use_case.dart';
import '../domain/usecases/get_rooms_use_case.dart';
import '../domain/usecases/toggle_device_use_case.dart';
import '../domain/usecases/watch_devices_use_case.dart';

// Data Sources
final deviceFirebaseDataSourceProvider = Provider<DeviceFirebaseDataSource>((ref) {
  return DeviceFirebaseDataSource();
});

final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>((ref) {
  return DeviceRemoteDataSourceImpl(
    ref.watch(deviceFirebaseDataSourceProvider),
  );
});

final deviceLocalDataSourceProvider = Provider<DeviceLocalDataSource>((ref) {
  return DeviceLocalDataSourceImpl();
});

final roomLocalDataSourceProvider = Provider<RoomLocalDataSource>((ref) {
  return RoomLocalDataSourceImpl();
});

// Repositories
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(
    remoteDataSource: ref.watch(deviceRemoteDataSourceProvider),
    localDataSource: ref.watch(deviceLocalDataSourceProvider),
  );
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(
    ref.watch(roomLocalDataSourceProvider),
  );
});

// Use Cases
final getDevicesUseCaseProvider = Provider<GetDevicesUseCase>((ref) {
  return GetDevicesUseCase(ref.watch(deviceRepositoryProvider));
});

final getDeviceByIdUseCaseProvider = Provider<GetDeviceByIdUseCase>((ref) {
  return GetDeviceByIdUseCase(ref.watch(deviceRepositoryProvider));
});

final getDevicesByRoomUseCaseProvider = Provider<GetDevicesByRoomUseCase>((ref) {
  return GetDevicesByRoomUseCase(ref.watch(deviceRepositoryProvider));
});

final toggleDeviceUseCaseProvider = Provider<ToggleDeviceUseCase>((ref) {
  return ToggleDeviceUseCase(ref.watch(deviceRepositoryProvider));
});

final watchDevicesUseCaseProvider = Provider<WatchDevicesUseCase>((ref) {
  return WatchDevicesUseCase(ref.watch(deviceRepositoryProvider));
});

final getRoomsUseCaseProvider = Provider<GetRoomsUseCase>((ref) {
  return GetRoomsUseCase(ref.watch(roomRepositoryProvider));
});

final getRoomByIdUseCaseProvider = Provider<GetRoomByIdUseCase>((ref) {
  return GetRoomByIdUseCase(ref.watch(roomRepositoryProvider));
});

/// Provider to watch raw Firebase data for a specific device
final deviceDataProvider = StreamProvider.family<Map<dynamic, dynamic>?, String>((ref, deviceId) {
  final remoteDataSource = ref.watch(deviceRemoteDataSourceProvider);
  return remoteDataSource.watchDeviceData(deviceId);
});

