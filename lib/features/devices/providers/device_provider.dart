import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/device_dependencies.dart';
import '../domain/usecases/get_devices_use_case.dart';
import '../domain/usecases/toggle_device_use_case.dart';
import '../domain/usecases/watch_devices_use_case.dart';
import '../models/device.dart' as presentation;
import '../presentation/mappers/device_mapper.dart';

/// Refactored DeviceController using Clean Architecture
/// Uses Use Cases instead of direct business logic
/// Now supports realtime updates from Firebase
class DeviceController extends StateNotifier<AsyncValue<List<presentation.Device>>> {
  DeviceController(
    this._getDevicesUseCase,
    this._toggleDeviceUseCase,
    this._watchDevicesUseCase,
  ) : super(const AsyncValue.loading()) {
    _watchDevices();
  }

  final GetDevicesUseCase _getDevicesUseCase;
  final ToggleDeviceUseCase _toggleDeviceUseCase;
  final WatchDevicesUseCase _watchDevicesUseCase;
  
  StreamSubscription<List<presentation.Device>>? _devicesSubscription;
  
  // Track devices that are being toggled to prevent premature stream override
  final Map<String, DateTime> _pendingToggles = {};
  static const _toggleTimeout = Duration(seconds: 5);

  /// Watch devices in real-time from Firebase
  void _watchDevices() {
    _devicesSubscription?.cancel();
    
    _devicesSubscription = _watchDevicesUseCase()
        .map((entities) => entities.map((e) => DeviceMapper.toPresentation(e)).toList())
        .listen(
          (devices) {
            final currentDevices = state.value;
            
            // If we have pending toggles, merge stream data with optimistic updates
            if (_pendingToggles.isNotEmpty && currentDevices != null) {
              final now = DateTime.now();
              final mergedDevices = <presentation.Device>[];
              
              for (final streamDevice in devices) {
                final deviceId = streamDevice.id;
                
                // Check if this device was recently toggled
                if (_pendingToggles.containsKey(deviceId)) {
                  final toggleTime = _pendingToggles[deviceId]!;
                  final timeSinceToggle = now.difference(toggleTime);
                  
                  if (timeSinceToggle < _toggleTimeout) {
                    // Within timeout: prefer optimistic state if stream shows opposite
                    // Find optimistic device state
                    final optimisticDevice = currentDevices.firstWhere(
                      (d) => d.id == deviceId,
                      orElse: () => streamDevice,
                    );
                    
                    // Only use stream data if hardware has confirmed (state matches expected)
                    // For fan: if mode > 0 when we expected ON, or mode == 0 when we expected OFF
                    // For curtain: if target_pos > 0 when we expected ON, or target_pos == 0 when we expected OFF
                    if (optimisticDevice.isOn == streamDevice.isOn) {
                      // Hardware confirmed - use stream data and remove from pending
                      mergedDevices.add(streamDevice);
                      _pendingToggles.remove(deviceId);
                    } else {
                      // Hardware hasn't confirmed yet - keep optimistic state
                      mergedDevices.add(optimisticDevice);
                    }
                  } else {
                    // Timeout exceeded - use stream data and remove from pending
                    mergedDevices.add(streamDevice);
                    _pendingToggles.remove(deviceId);
                  }
                } else {
                  // Not a pending toggle - use stream data
                  mergedDevices.add(streamDevice);
                }
              }
              
              // Add any devices from optimistic that aren't in stream yet
              for (final optimisticDevice in currentDevices) {
                if (!mergedDevices.any((d) => d.id == optimisticDevice.id)) {
                  mergedDevices.add(optimisticDevice);
                }
              }
              
              state = AsyncValue.data(mergedDevices);
            } else {
              // No pending toggles - use stream data directly
              state = AsyncValue.data(devices);
            }
          },
          onError: (error, stackTrace) {
            // On error, preserve previous data if available
            final currentDevices = state.value;
            if (currentDevices != null) {
              state = AsyncValue.data(currentDevices);
            } else {
              state = AsyncValue.error(error, stackTrace);
            }
          },
        );
  }

  /// Load devices once (fallback if stream fails)
  Future<void> _loadDevices() async {
    try {
      final entities = await _getDevicesUseCase();
      final devices = entities.map((e) => DeviceMapper.toPresentation(e)).toList();
      state = AsyncValue.data(devices);
    } catch (e, stackTrace) {
      // On error, preserve previous data if available
      final currentDevices = state.value;
      if (currentDevices != null) {
        state = AsyncValue.data(currentDevices);
      } else {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> toggle(String id) async {
    final currentDevices = state.value;
    if (currentDevices == null) return;

    // Special handling for door-living: only allow opening, not closing
    if (id == 'door-living') {
      final currentDevice = currentDevices.firstWhere(
        (d) => d.id == id,
        orElse: () => throw Exception('Device not found'),
      );
      
      // If door is already open (isOn = true), don't allow closing from UI
      if (currentDevice.isOn) {
        throw Exception('DOOR_CLOSE_NOT_ALLOWED');
      }
      
      // If door is closed (isOn = false), allow opening
      // Track this toggle to prevent premature stream override
      _pendingToggles[id] = DateTime.now();

      // Optimistic update - set to open
      final updatedDevices = currentDevices.map((device) {
        if (device.id == id) {
          return device.copyWith(isOn: true);
        }
        return device;
      }).toList();
      state = AsyncValue.data(updatedDevices);

      try {
        // Call use case - this will update Firebase with command = 1
        await _toggleDeviceUseCase(id);
      } catch (e) {
        // Revert on error - restore previous state and remove from pending
        _pendingToggles.remove(id);
        state = AsyncValue.data(currentDevices);
        rethrow;
      }
      return;
    }

    // For other devices, use normal toggle logic
    // Track this toggle to prevent premature stream override
    _pendingToggles[id] = DateTime.now();

    // Optimistic update
    final updatedDevices = currentDevices.map((device) {
      if (device.id == id) {
        return device.copyWith(isOn: !device.isOn);
      }
      return device;
    }).toList();
    state = AsyncValue.data(updatedDevices);

    try {
      // Call use case - this will update Firebase
      // The stream will automatically update state when hardware confirms
      await _toggleDeviceUseCase(id);
    } catch (e) {
      // Revert on error - restore previous state and remove from pending
      _pendingToggles.remove(id);
      state = AsyncValue.data(currentDevices);
    }
  }

  Future<void> refresh() async {
    await _loadDevices();
    // Restart stream after refresh
    _watchDevices();
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    super.dispose();
  }
}

/// Provider that creates DeviceController with dependencies injected
final deviceControllerProvider =
    StateNotifierProvider<DeviceController, AsyncValue<List<presentation.Device>>>(
  (ref) {
    return DeviceController(
      ref.watch(getDevicesUseCaseProvider),
      ref.watch(toggleDeviceUseCaseProvider),
      ref.watch(watchDevicesUseCaseProvider),
    );
  },
);

/// Convenience provider that unwraps AsyncValue
final devicesProvider = Provider<List<presentation.Device>>((ref) {
  final asyncValue = ref.watch(deviceControllerProvider);
  return asyncValue.when(
    data: (devices) => devices,
    loading: () => <presentation.Device>[],
    error: (_, __) => <presentation.Device>[],
  );
});

/// Count of active devices
final activeDevicesCountProvider = Provider<int>((ref) {
  final devices = ref.watch(devicesProvider);
  return devices.where((device) => device.isOn).length;
});

/// Estimated power load
final estimatedLoadProvider = Provider<double>((ref) {
  final devices = ref.watch(devicesProvider);
  return devices
      .where((device) => device.isOn)
      .fold<double>(0, (sum, device) => sum + device.power);
});

/// Provider for devices by room
final devicesByRoomProvider = Provider.family<List<presentation.Device>, String>(
  (ref, roomId) {
    final devices = ref.watch(devicesProvider);
    // Map room IDs to room names
    final roomNames = {
      'living': 'Phòng khách',
      'bedroom': 'Phòng ngủ',
      'bath': 'Phòng tắm',
      'gate': 'Cổng',
      'kitchen': 'Nhà bếp',
      'garden': 'Sân vườn',
    };
    final roomName = roomNames[roomId] ?? roomId;
    return devices.where((device) => device.room == roomName).toList();
  },
);
