import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../domain/entities/device_type.dart';
import '../models/device.dart';
import '../di/device_dependencies.dart';
import '../providers/device_provider.dart';
import '../providers/room_provider.dart';
import 'widgets/device_card.dart';
import 'widgets/add_device_button.dart';
import 'device_control_screen.dart';
import 'device_detail_screen.dart';
import 'gate_control_screen.dart';

class RoomDevicesScreen extends ConsumerWidget {
  const RoomDevicesScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    final devices = ref.watch(devicesProvider);
    final sizeClass = context.screenSizeClass;

    return roomsAsync.when(
      data: (rooms) {
        final room = rooms.firstWhere(
          (r) => r.id == roomId,
          orElse: () => rooms.isNotEmpty ? rooms.first : throw StateError('No rooms'),
        );

        // Get devices for this room - improved matching logic
        final roomDevices = devices.where((d) {
          final deviceRoomName = d.room.toLowerCase().trim();
          final roomNameLower = room.name.toLowerCase().trim();
          
          // Direct match with room name (both directions)
          if (deviceRoomName == roomNameLower || 
              deviceRoomName.contains(roomNameLower) || 
              roomNameLower.contains(deviceRoomName)) {
            return true;
          }
          
          // Match with keywords if available
          if (room.keywords != null && room.keywords!.isNotEmpty) {
            final keywords = room.keywords!.map((e) => e.toLowerCase().trim()).toList();
            return keywords.any((k) => 
              deviceRoomName.contains(k) || 
              deviceRoomName == k ||
              k.contains(deviceRoomName)
            );
          }
          
          return false;
        }).toList();
        
        // Handle case when no devices found
        if (roomDevices.isEmpty) {
          return Center(
            child: Text(
              'Không có thiết bị nào trong phòng này',
              style: context.responsiveBodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        
        // Route to specific layouts based on room type
        if (roomId == 'living') {
          // Phòng khách: Cửa chính, Đèn, Máy lọc không khí
          Device? doorDevice;
          Device? lightDevice;
          Device? airPurifierDevice;
          
          // Debug: Log all devices found for this room
          // Uncomment for debugging:
          // if (kDebugMode) {
          //   print('=== Living Room Devices ===');
          //   print('Total devices: ${roomDevices.length}');
          //   for (final d in roomDevices) {
          //     print('  - ${d.name} (${d.type}, room: ${d.room})');
          //   }
          // }
          
          // Find door device - try multiple criteria
          for (final d in roomDevices) {
            if (d.type == DeviceType.lock && 
                (d.name.toLowerCase().contains('cửa') || 
                 d.name.toLowerCase().contains('door') ||
                 d.id.toLowerCase().contains('door'))) {
              doorDevice = d;
              break;
            }
          }
          // Fallback: any lock device if no specific door found
          if (doorDevice == null) {
            try {
              doorDevice = roomDevices.firstWhere((d) => d.type == DeviceType.lock);
            } catch (e) {
              // No lock device found
            }
          }
          
          // Find light device
          try {
            lightDevice = roomDevices.firstWhere((d) => d.type == DeviceType.light);
          } catch (e) {
            // Light not found
          }
          
          // Find air purifier device - try multiple name variations
          for (final d in roomDevices) {
            if (d.name.toLowerCase().contains('lọc') || 
                d.name.toLowerCase().contains('purifier') ||
                d.name.toLowerCase().contains('máy lọc') ||
                d.id.toLowerCase().contains('air-purifier') ||
                d.id.toLowerCase().contains('purifier')) {
              airPurifierDevice = d;
              break;
            }
          }
          // Fallback: sensor type with air-related name
          if (airPurifierDevice == null) {
            try {
              airPurifierDevice = roomDevices.firstWhere(
                (d) => d.type == DeviceType.sensor && 
                       (d.name.toLowerCase().contains('không khí') || 
                        d.name.toLowerCase().contains('air')),
              );
            } catch (e) {
              // Air purifier not found
            }
          }
          
          return _buildLivingRoomLayout(context, ref, sizeClass, room, doorDevice, lightDevice, airPurifierDevice);
        } else if (roomId == 'bedroom') {
          // Phòng ngủ: Rèm, Quạt (bỏ điều hòa)
          Device? curtainDevice;
          Device? fanDevice;
          
          try {
            curtainDevice = roomDevices.firstWhere(
              (d) => d.type == DeviceType.curtain,
            );
          } catch (e) {
            // Curtain not found
          }
          
          try {
            fanDevice = roomDevices.firstWhere(
              (d) => d.type == DeviceType.fan,
            );
          } catch (e) {
            // Fan not found
          }
          
          return _buildBedroomLayout(context, ref, sizeClass, room, curtainDevice, fanDevice);
        } else {
          // Other rooms (including gate) - use generic layout or specific screen
          return _buildGenericRoomLayout(context, ref, sizeClass, room, roomDevices);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Lỗi: $error', style: context.responsiveBodyM),
      ),
    );
  }

  Widget _buildLivingRoomLayout(
    BuildContext context,
    WidgetRef ref,
    ScreenSizeClass sizeClass,
    room,
    Device? doorDevice,
    Device? lightDevice,
    Device? airPurifierDevice,
  ) {
    return ContentScaffold(
      title: room.name,
      showBack: true,
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.90 : 0.85,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      onRefresh: () async {
        final deviceController = ref.read(deviceControllerProvider.notifier);
        await deviceController.refresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      titleWidget: _RoomHeader(room: room),
      floatingActionButton: const AddDeviceButton(),
          body: (context, constraints) {
            final sectionSpacing = sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.lg 
                : AppSpacing.xl;
            final dividerSpacing = sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.xxl 
                : AppSpacing.xxl + AppSpacing.md;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Thiết Bị" Section
                Text(
                  'Thiết Bị',
                  style: context.responsiveTitleM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: sectionSpacing),
                
                // Cửa chính (Main Door) - only show if exists
                if (doorDevice != null) ...[
                  _DeviceRow(
                    device: doorDevice,
                    status: doorDevice.isOn ? 'Đang Mở' : 'Đang Đóng',
                    onToggle: () {
                      ref.read(deviceControllerProvider.notifier).toggle(doorDevice.id);
                    },
                  ),
                  Divider(
                    height: dividerSpacing,
                    thickness: 1,
                    color: AppColors.borderSoft,
                  ),
                ],
                
                // "Đèn" Section - only show if exists
                if (lightDevice != null) ...[
                  Text(
                    'Đèn',
                    style: context.responsiveTitleM.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  // Light control buttons
                  _LightControlButtons(
                    device: lightDevice,
                  ),
                  
                  if (airPurifierDevice != null)
                    Divider(
                      height: dividerSpacing,
                      thickness: 1,
                      color: AppColors.borderSoft,
                    ),
                ],
                
                // Máy Lọc Không Khí (Air Purifier) - only show if exists
                if (airPurifierDevice != null) ...[
                  Text(
                    'Máy Lọc Không Khí',
                    style: context.responsiveTitleM.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  // Air purifier control buttons
                  _PurifierControlButtons(
                    device: airPurifierDevice,
                  ),
                ],
              ],
            );
          },
        );
  }

  /// Bedroom layout: Rèm, Quạt
  Widget _buildBedroomLayout(
    BuildContext context,
    WidgetRef ref,
    ScreenSizeClass sizeClass,
    room,
    Device? curtainDevice,
    Device? fanDevice,
  ) {
    return ContentScaffold(
      title: room.name,
      showBack: true,
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      onRefresh: () async {
        final deviceController = ref.read(deviceControllerProvider.notifier);
        await deviceController.refresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      titleWidget: _RoomHeader(room: room),
      floatingActionButton: const AddDeviceButton(),
      body: (context, constraints) {
        final sectionSpacing = sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.lg 
            : AppSpacing.xl;
        final dividerSpacing = sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.xxl 
            : AppSpacing.xxl + AppSpacing.md;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Thiết Bị" Section
            Text(
              'Thiết Bị',
              style: context.responsiveTitleM.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: sectionSpacing),
            
            // Rèm (Curtain) - with detail screen (bỏ toggle switch)
            if (curtainDevice != null) ...[
              DeviceCard(
                device: curtainDevice,
                compact: false,
                onToggle: null, // Bỏ toggle switch, chỉ điều khiển trong panel
                controlBuilder: (_) => DeviceDetailScreen(
                  roomId: roomId,
                  deviceId: curtainDevice.id,
                ),
              ),
              if (fanDevice != null)
                Divider(
                  height: dividerSpacing,
                  thickness: 1,
                  color: AppColors.borderSoft,
                ),
            ],
            
            // Quạt (Fan) - with detail screen (bỏ toggle switch)
            if (fanDevice != null)
              DeviceCard(
                device: fanDevice,
                compact: false,
                onToggle: null, // Bỏ toggle switch, chỉ điều khiển trong panel
                controlBuilder: (_) => DeviceDetailScreen(
                  roomId: roomId,
                  deviceId: fanDevice.id,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGenericRoomLayout(
    BuildContext context,
    WidgetRef ref,
    ScreenSizeClass sizeClass,
    room,
    List<Device> devices,
  ) {
    final sectionSpacing = sizeClass == ScreenSizeClass.compact 
        ? AppSpacing.lg 
        : AppSpacing.xl;

    return ContentScaffold(
      title: room.name,
      showBack: true,
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      onRefresh: () async {
        final deviceController = ref.read(deviceControllerProvider.notifier);
        await deviceController.refresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      titleWidget: _RoomHeader(room: room),
      floatingActionButton: const AddDeviceButton(),
      body: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thiết Bị',
              style: context.responsiveTitleM.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: sectionSpacing),
            
            // Show all devices - use DeviceCard for devices with detail screens, otherwise use _DeviceRow
            ...devices.map((device) {
              final hasDetailScreen = device.type == DeviceType.curtain ||
                  device.type == DeviceType.fan ||
                  device.type == DeviceType.ac ||
                  device.type == DeviceType.climate ||
                  device.type == DeviceType.lock;

              if (hasDetailScreen) {
                // Use DeviceCard with controlBuilder for devices with detail screens
                WidgetBuilder? controlBuilder;
                if (device.type == DeviceType.climate || device.type == DeviceType.ac) {
                  controlBuilder = (_) => DeviceControlScreen(device: device);
                } else if (device.type == DeviceType.lock) {
                  controlBuilder = (_) => GateControlScreen(device: device);
                } else {
                  // For curtain, fan - use DeviceDetailScreen
                  controlBuilder = (_) => DeviceDetailScreen(
                    roomId: roomId,
                    deviceId: device.id,
                  );
                }

                // Bỏ toggle switch cho quạt và rèm (chỉ điều khiển trong panel)
                final shouldShowToggle = device.type != DeviceType.fan && 
                                         device.type != DeviceType.curtain;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: sectionSpacing),
                  child: DeviceCard(
                    device: device,
                    compact: false,
                    onToggle: shouldShowToggle ? () {
                      ref.read(deviceControllerProvider.notifier).toggle(device.id);
                    } : null,
                    controlBuilder: controlBuilder,
                  ),
                );
              } else {
                // Use simple _DeviceRow for other devices
                return Padding(
                  padding: EdgeInsets.only(bottom: sectionSpacing),
                  child: _DeviceRow(
                    device: device,
                    status: device.isOn ? 'Đang bật' : 'Đang tắt',
                    onToggle: () {
                      ref.read(deviceControllerProvider.notifier).toggle(device.id);
                    },
                  ),
                );
              }
            }),
          ],
        );
      },
    );
  }
}

/// Room header with icon
class _RoomHeader extends StatelessWidget {
  const _RoomHeader({required this.room});

  final dynamic room;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 56.0 : 48.0;

    return Row(
      children: [
        Expanded(
          child: Text(
            room.name,
            style: context.responsiveHeadlineL.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(
          room.icon,
          size: iconSize,
          color: Colors.white,
        ),
      ],
    );
  }
}

/// Device row with icon, name, status, and toggle switch
class _DeviceRow extends ConsumerWidget {
  const _DeviceRow({
    required this.device,
    required this.status,
    this.onToggle,
  });

  final Device device;
  final String status;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(deviceControllerProvider);
    final isOn = devicesAsync.when(
      data: (devices) {
        final currentDevice = devices.firstWhere(
          (d) => d.id == device.id,
          orElse: () => device,
        );
        return currentDevice.isOn;
      },
      loading: () => device.isOn,
      error: (_, __) => device.isOn,
    );

    final sizeClass = context.screenSizeClass;
    final iconRadius = sizeClass == ScreenSizeClass.expanded ? 28.0 : 24.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 32.0 : 28.0;

    return Row(
      children: [
        // Icon - special handling for door and air purifier
        CircleAvatar(
          radius: iconRadius,
          backgroundColor: AppColors.primarySoft,
          child: Icon(
            _getDeviceIcon(device),
            color: AppColors.primary,
            size: iconSize,
          ),
        ),
        SizedBox(width: sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.md 
            : AppSpacing.lg),
        
        // Name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: context.responsiveTitleM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                status,
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Toggle switch (ẩn nếu onToggle là null)
        if (onToggle != null)
          Transform.scale(
            scale: sizeClass == ScreenSizeClass.expanded ? 1.2 : 1.0,
            child: Switch(
              value: isOn,
              onChanged: (_) => onToggle!(),
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
              inactiveTrackColor: AppColors.borderSoft,
              inactiveThumbColor: Colors.white,
            ),
          ),
      ],
    );
  }
}

/// Helper function to get appropriate icon for device
IconData _getDeviceIcon(Device device) {
  final deviceName = device.name.toLowerCase();
  
  // Special icons for specific devices
  if (device.type == DeviceType.lock && deviceName.contains('cửa')) {
    return Icons.door_front_door_outlined;
  }
  if (deviceName.contains('lọc') || deviceName.contains('purifier') || deviceName.contains('máy lọc')) {
    return Icons.air; // Air/cloud icon for air purifier
  }
  
  return device.type.icon;
}

/// Light control buttons: sáng, vừa, tắt, tiết kiệm
class _LightControlButtons extends ConsumerStatefulWidget {
  const _LightControlButtons({
    required this.device,
  });

  final Device device;

  @override
  ConsumerState<_LightControlButtons> createState() => _LightControlButtonsState();
}

class _LightControlButtonsState extends ConsumerState<_LightControlButtons> {
  int _mode = 0; // Current mode from hardware (0=tắt, 1=tiết kiệm, 2=vừa, 3=sáng)
  int? _lastCommand; // Track last command to prevent duplicate updates
  DateTime? _lastUpdateTime; // Track when we last updated via UI

  @override
  void initState() {
    super.initState();
    // Initialize from device state
    _mode = widget.device.isOn ? 3 : 0; // Default to sáng if on, tắt if off
  }

  @override
  Widget build(BuildContext context) {
    // Watch Firebase data for this device
    final deviceDataAsync = ref.watch(deviceDataProvider(widget.device.id));
    
    // Update mode when Firebase data changes (ignore for 2 seconds after UI update)
    deviceDataAsync.whenData((data) {
      if (data != null && mounted) {
        final now = DateTime.now();
        // Ignore stream updates for 2 seconds after manual update
        if (_lastUpdateTime != null && 
            now.difference(_lastUpdateTime!).inSeconds < 2) {
          return; // Don't override optimistic update yet
        }
        
        // mode: Giá trị từ phần cứng (hardware response) - dùng để hiển thị
        final mode = data['mode'] as int? ?? 0;
        final newMode = mode.clamp(0, 3);
        
        // Only update if value changed to avoid unnecessary rebuilds
        if (newMode != _mode) {
          setState(() {
            _mode = newMode;
          });
        }
      }
    });

    final sizeClass = context.screenSizeClass;
    final buttonHeight = sizeClass == ScreenSizeClass.expanded ? 64.0 : 56.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 24.0 : 20.0;
    final fontSize = sizeClass == ScreenSizeClass.expanded ? 14.0 : 13.0;

    // Define modes: 0=tắt, 1=tiết kiệm, 2=trung bình, 3=sáng mạnh
    // Thứ tự hiển thị: tắt/tiết kiệm/trung bình/sáng mạnh (grid 2x2)
    final modes = [
      _LightMode(
        id: 0,
        label: 'Tắt',
        icon: Icons.power_off,
        isActive: _mode == 0,
      ),
      _LightMode(
        id: 1,
        label: 'Tiết kiệm',
        icon: Icons.eco_outlined,
        isActive: _mode == 1,
      ),
      _LightMode(
        id: 2,
        label: 'Trung bình',
        icon: Icons.wb_twilight,
        isActive: _mode == 2,
      ),
      _LightMode(
        id: 3,
        label: 'Sáng mạnh',
        icon: Icons.wb_sunny,
        isActive: _mode == 3,
      ),
    ];

    // Grid 2x2 layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.md 
            : AppSpacing.lg,
        mainAxisSpacing: sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.md 
            : AppSpacing.lg,
        childAspectRatio: 2.2, // Width/Height ratio for buttons
      ),
      itemCount: modes.length,
      itemBuilder: (context, index) {
        final mode = modes[index];
        return _LightButton(
          mode: mode,
          height: buttonHeight,
          iconSize: iconSize,
          fontSize: fontSize,
          onTap: () => _handleModeChange(mode.id),
        );
      },
    );
  }

  Future<void> _handleModeChange(int command) async {
    // command: 0=tắt, 1=tiết kiệm, 2=vừa, 3=sáng
    if (_lastCommand == command) return; // Prevent duplicate updates
    
    _lastCommand = command;
    _lastUpdateTime = DateTime.now(); // Track update time
    // Optimistic update - UI shows new mode immediately
    setState(() {
      _mode = command;
    });
    
    final repository = ref.read(deviceRepositoryProvider);
    try {
      // Gửi 'command' lên Firebase (UI command) - phần cứng sẽ đọc và cập nhật 'mode'
      await repository.updateLightCommand(widget.device.id, command);
    } catch (e) {
      // Revert on error
      _lastCommand = null;
      _lastUpdateTime = null;
      if (mounted) {
        // Revert will happen via stream (mode will update)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}

class _LightMode {
  const _LightMode({
    required this.id,
    required this.label,
    required this.icon,
    required this.isActive,
  });

  final int id; // 0=tắt, 1=tiết kiệm, 2=vừa, 3=sáng
  final String label;
  final IconData icon;
  final bool isActive;
}

class _LightButton extends StatelessWidget {
  const _LightButton({
    required this.mode,
    required this.height,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  });

  final _LightMode mode;
  final double height;
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md)
        : EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: mode.isActive ? AppColors.primary : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: mode.isActive ? AppColors.primary : AppColors.borderSoft,
            width: mode.isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mode.icon,
              size: iconSize,
              color: mode.isActive ? Colors.white : AppColors.primary,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              mode.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: mode.isActive ? FontWeight.w700 : FontWeight.w500,
                color: mode.isActive ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurifierControlButtons extends ConsumerStatefulWidget {
  const _PurifierControlButtons({
    required this.device,
  });

  final Device device;

  @override
  ConsumerState<_PurifierControlButtons> createState() => _PurifierControlButtonsState();
}

class _PurifierControlButtonsState extends ConsumerState<_PurifierControlButtons> {
  bool _isOn = false; // Current state from hardware (state: true/false)
  int? _lastCommand; // Track last command to prevent duplicate updates
  DateTime? _lastUpdateTime; // Track when we last updated via UI

  @override
  void initState() {
    super.initState();
    // Initialize from device state
    _isOn = widget.device.isOn;
  }

  @override
  Widget build(BuildContext context) {
    // Watch Firebase data for this device
    final deviceDataAsync = ref.watch(deviceDataProvider(widget.device.id));
    
    // Update state when Firebase data changes (ignore for 2 seconds after UI update)
    deviceDataAsync.whenData((data) {
      if (data != null && mounted) {
        final now = DateTime.now();
        // Ignore stream updates for 2 seconds after manual update
        if (_lastUpdateTime != null && 
            now.difference(_lastUpdateTime!).inSeconds < 2) {
          return; // Don't override optimistic update yet
        }
        
        // state: Giá trị từ phần cứng (hardware response) - dùng để hiển thị
        final state = data['state'] as bool? ?? false;
        
        // Only update if value changed to avoid unnecessary rebuilds
        if (state != _isOn) {
          setState(() {
            _isOn = state;
          });
        }
      }
    });

    final sizeClass = context.screenSizeClass;
    final buttonHeight = sizeClass == ScreenSizeClass.expanded ? 56.0 : 48.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 24.0 : 20.0;
    final fontSize = sizeClass == ScreenSizeClass.expanded ? 14.0 : 13.0;

    // Define buttons: Tắt (0) and Bật (1)
    final buttons = [
      _PurifierButton(
        command: 0,
        label: 'Tắt',
        icon: Icons.power_off,
        isActive: !_isOn,
      ),
      _PurifierButton(
        command: 1,
        label: 'Bật',
        icon: Icons.power_settings_new,
        isActive: _isOn,
      ),
    ];

    return Wrap(
      spacing: sizeClass == ScreenSizeClass.compact 
          ? AppSpacing.sm 
          : AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: buttons.map((button) {
        return GestureDetector(
          onTap: () => _handleCommandChange(button.command),
          child: Container(
            height: buttonHeight,
            padding: sizeClass == ScreenSizeClass.expanded 
                ? EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md)
                : EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: button.isActive ? AppColors.primary : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: button.isActive ? AppColors.primary : AppColors.borderSoft,
                width: button.isActive ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  button.icon,
                  size: iconSize,
                  color: button.isActive ? Colors.white : AppColors.primary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  button.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: button.isActive ? FontWeight.w700 : FontWeight.w500,
                    color: button.isActive ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleCommandChange(int command) async {
    // command: 0=tắt, 1=bật
    if (_lastCommand == command) return; // Prevent duplicate updates
    
    _lastCommand = command;
    _lastUpdateTime = DateTime.now(); // Track update time
    // Optimistic update - UI shows new state immediately
    setState(() {
      _isOn = command == 1;
    });
    
    final repository = ref.read(deviceRepositoryProvider);
    try {
      // Gửi 'command' lên Firebase (UI command) - phần cứng sẽ đọc và cập nhật 'state'
      await repository.updatePurifierCommand(widget.device.id, command);
    } catch (e) {
      // Revert on error
      _lastCommand = null;
      _lastUpdateTime = null;
      if (mounted) {
        // Revert will happen via stream (state will update)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}

class _PurifierButton {
  const _PurifierButton({
    required this.command,
    required this.label,
    required this.icon,
    required this.isActive,
  });

  final int command; // 0=tắt, 1=bật
  final String label;
  final IconData icon;
  final bool isActive;
}

