import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../domain/entities/device_type.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';
import '../providers/room_provider.dart';
import 'widgets/device_card.dart';
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
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      titleWidget: _RoomHeader(room: room),
          body: (context, constraints) {
            final sectionSpacing = sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.md 
                : AppSpacing.lg;
            final dividerSpacing = sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.xl 
                : AppSpacing.xxl;

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
                    onToggle: () {
                      ref.read(deviceControllerProvider.notifier).toggle(lightDevice.id);
                    },
                  ),
                  
                  if (airPurifierDevice != null)
                    Divider(
                      height: dividerSpacing,
                      thickness: 1,
                      color: AppColors.borderSoft,
                    ),
                ],
                
                // Máy Lọc Không Khí (Air Purifier) - only show if exists
                if (airPurifierDevice != null)
                  _DeviceRow(
                    device: airPurifierDevice,
                    status: airPurifierDevice.isOn ? 'Đang Mở' : 'Đang Đóng',
                    onToggle: () {
                      ref.read(deviceControllerProvider.notifier).toggle(airPurifierDevice.id);
                    },
                  ),
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
      titleWidget: _RoomHeader(room: room),
      body: (context, constraints) {
        final sectionSpacing = sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.md 
            : AppSpacing.lg;
        final dividerSpacing = sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.xl 
            : AppSpacing.xxl;

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
        ? AppSpacing.md 
        : AppSpacing.lg;

    return ContentScaffold(
      title: room.name,
      showBack: true,
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      titleWidget: _RoomHeader(room: room),
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
    required this.onToggle,
  });

  final Device device;
  final VoidCallback onToggle;

  @override
  ConsumerState<_LightControlButtons> createState() => _LightControlButtonsState();
}

class _LightControlButtonsState extends ConsumerState<_LightControlButtons> {
  String _selectedMode = 'sáng'; // sáng, vừa, tắt, tiết kiệm
  
  @override
  void initState() {
    super.initState();
    // Initialize selected mode based on device state
    if (!widget.device.isOn) {
      _selectedMode = 'tắt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final buttonHeight = sizeClass == ScreenSizeClass.expanded ? 56.0 : 48.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 24.0 : 20.0;
    final fontSize = sizeClass == ScreenSizeClass.expanded ? 14.0 : 13.0;

    final modes = [
      _LightMode(
        id: 'sáng',
        label: 'sáng',
        icon: Icons.wb_sunny,
        isActive: _selectedMode == 'sáng',
      ),
      _LightMode(
        id: 'vừa',
        label: 'vừa',
        icon: Icons.wb_twilight,
        isActive: _selectedMode == 'vừa',
      ),
      _LightMode(
        id: 'tắt',
        label: 'Tắt',
        icon: Icons.remove,
        isActive: _selectedMode == 'tắt',
      ),
      _LightMode(
        id: 'tiết kiệm',
        label: 'tiết kiệm',
        icon: Icons.eco_outlined,
        isActive: _selectedMode == 'tiết kiệm',
      ),
    ];

    return Wrap(
      spacing: sizeClass == ScreenSizeClass.compact 
          ? AppSpacing.sm 
          : AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: modes.map((mode) {
        return _LightButton(
          mode: mode,
          height: buttonHeight,
          iconSize: iconSize,
          fontSize: fontSize,
          onTap: () {
            setState(() {
              _selectedMode = mode.id;
              if (mode.id == 'tắt' && widget.device.isOn) {
                widget.onToggle();
              } else if (mode.id != 'tắt' && !widget.device.isOn) {
                widget.onToggle();
              }
            });
          },
        );
      }).toList(),
    );
  }
}

class _LightMode {
  const _LightMode({
    required this.id,
    required this.label,
    required this.icon,
    required this.isActive,
  });

  final String id;
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
        ? EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md)
        : EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm);

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mode.icon,
              size: iconSize,
              color: mode.isActive ? Colors.white : AppColors.primary,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              mode.label,
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
