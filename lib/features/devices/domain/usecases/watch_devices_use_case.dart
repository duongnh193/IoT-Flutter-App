import 'dart:async';

import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

/// Use case for watching devices in real-time
class WatchDevicesUseCase {
  final DeviceRepository _repository;

  WatchDevicesUseCase(this._repository);

  Stream<List<DeviceEntity>> call() {
    return _repository.watchDevices();
  }
}

