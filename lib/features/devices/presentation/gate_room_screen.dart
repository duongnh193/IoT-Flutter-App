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
import '../providers/rfid_card_provider.dart';
import '../data/datasources/rfid_card_firestore_datasource.dart';
import 'widgets/add_device_button.dart';

/// Gate room screen with special layout: device, access history, and card management
class GateRoomScreen extends ConsumerStatefulWidget {
  const GateRoomScreen({super.key});

  @override
  ConsumerState<GateRoomScreen> createState() => _GateRoomScreenState();
}

class _GateRoomScreenState extends ConsumerState<GateRoomScreen> {
  bool _isDialogShowing = false;
  String? _processingCardId;


  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomListProvider);
    final devices = ref.watch(devicesProvider);
    final sizeClass = context.screenSizeClass;
    final isAddingCard = ref.watch(isAddingCardProvider);
    // Preload named cards data at screen level so it's ready when modal opens
    ref.watch(namedRfidCardsProvider);
    // Watch to trigger listener for unnamed cards
    ref.watch(unnamedRfidCardsProvider);

    // Listen for new unnamed cards when in "add card" mode
    ref.listen(unnamedRfidCardsProvider, (previous, next) {
      next.whenData((unnamedCards) {
        if (isAddingCard && unnamedCards.isNotEmpty && !_isDialogShowing && mounted) {
          // Get the first unnamed card that we haven't processed yet
          for (final card in unnamedCards) {
            if (card.id != _processingCardId) {
              _processingCardId = card.id;
              _isDialogShowing = true;
              // Show dialog after a short delay to ensure context is available
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _showNameCardModal(context, card.id);
                }
              });
              break;
            }
          }
        }
      });
    });

    return roomsAsync.when(
      data: (rooms) {
        // Handle empty rooms list
        if (rooms.isEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy phòng Cổng',
              style: context.responsiveBodyM.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        // Find gate room
        final gateRoom = rooms.firstWhere(
          (r) => r.id == 'gate',
          orElse: () => rooms.first,
        );

        // Get gate device - filter by room name/keywords AND device type/name
        final gateDevices = devices.where((d) {
          final roomName = d.room.toLowerCase();
          final deviceName = d.name.toLowerCase();
          final keywords = [
            gateRoom.name.toLowerCase(),
            ...?gateRoom.keywords?.map((e) => e.toLowerCase()),
          ];
          
          // Match by room name/keywords
          final matchesRoom = keywords.any((k) => roomName.contains(k));
          
          // Also match devices with lock type or gate-related names in any room
          final isLockDevice = d.type == DeviceType.lock;
          final hasGateName = deviceName.contains('cổng') || 
                             deviceName.contains('gate') ||
                             deviceName.contains('khóa');
          
          return matchesRoom || (isLockDevice && hasGateName);
        }).toList();

        // Handle no gate devices found - create a default gate device
        Device gateDevice;
        if (gateDevices.isEmpty) {
          // Create default gate device as fallback
          gateDevice = const Device(
            id: 'gate-main-default',
            name: 'Cổng Chính',
            type: DeviceType.lock,
            room: 'Cổng',
            isOn: false,
          );
        } else {
          // Prioritize: devices with "Cổng Chính" name, then lock type devices
          gateDevice = gateDevices.firstWhere(
            (d) => d.name.toLowerCase().contains('cổng chính') || 
                  d.id == 'gate-main',
            orElse: () {
              // Second priority: any device with "cổng" in name
              return gateDevices.firstWhere(
                (d) => d.name.toLowerCase().contains('cổng'),
                orElse: () => gateDevices.first, // Fallback to first device
              );
            },
          );
        }

        // Access history will be loaded from Firestore via provider

        return ContentScaffold(
          title: gateRoom.name,
          showBack: true,
          panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.90 : 0.85,
          horizontalPaddingFactor: 0.06,
          scrollable: true,
          onRefresh: () async {
            final deviceController = ref.read(deviceControllerProvider.notifier);
            await deviceController.refresh();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          titleWidget: _GateHeader(room: gateRoom),
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
                
                // Gate device row
                _DeviceRow(
                  device: gateDevice,
                  status: gateDevice.isOn ? 'Đang Mở' : 'Đang Đóng',
                  onToggle: () {
                    ref.read(deviceControllerProvider.notifier).toggle(gateDevice.id);
                  },
                ),
                
                Divider(
                  height: dividerSpacing,
                  thickness: 1,
                  color: AppColors.borderSoft,
                ),
                
                // "Lịch Sử Ra Vào:" Section
                Text(
                  'Lịch Sử Ra Vào:',
                  style: context.responsiveTitleM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: sectionSpacing),
                
                // Access history list
                const _AccessHistoryList(),
                
                SizedBox(height: dividerSpacing),
                
                // Action buttons: Thêm Thẻ and Xoá Thẻ
                _CardActionButtons(
                  onAddCard: () {
                    // Enable "add card" mode and show waiting message
                    ref.read(isAddingCardProvider.notifier).state = true;
                    _isDialogShowing = false;
                    _processingCardId = null;
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng quẹt thẻ RFID mới vào thiết bị...'),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Lỗi: $error', style: context.responsiveBodyM),
      ),
    );
  }

  /// Show name card modal dialog (for new unnamed card)
  void _showNameCardModal(BuildContext context, String cardId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _NameCardModal(
        cardId: cardId,
        onComplete: () {
          // Disable "add card" mode after completion
          ref.read(isAddingCardProvider.notifier).state = false;
          _isDialogShowing = false;
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    ).then((_) {
      // Reset dialog showing flag when dialog is closed
      if (mounted) {
        setState(() {
          _isDialogShowing = false;
        });
      }
    });
  }
}

/// Gate header with icon
class _GateHeader extends StatelessWidget {
  const _GateHeader({required this.room});

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
    required this.onToggle,
  });

  final Device device;
  final String status;
  final VoidCallback onToggle;

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
        // Icon - gate icon for gate device
        CircleAvatar(
          radius: iconRadius,
          backgroundColor: AppColors.primarySoft,
          child: Icon(
            Icons.garage_outlined, // Gate icon
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
        
        // Toggle switch
        Transform.scale(
          scale: sizeClass == ScreenSizeClass.expanded ? 1.2 : 1.0,
          child: Switch(
            value: isOn,
            onChanged: (_) => onToggle(),
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

/// Access history list - displays logs from Firestore
class _AccessHistoryList extends ConsumerWidget {
  const _AccessHistoryList();

  /// Convert timestamp (seconds since epoch, UTC) to UTC+7 formatted time string
  String _formatTime(int timestamp) {
    // Convert seconds to DateTime (assume timestamp is in UTC)
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    // Add 7 hours to convert to UTC+7 (Vietnam timezone)
    final vietnamTime = dateTime.add(const Duration(hours: 7));
    // Format as HH:mm
    final hour = vietnamTime.hour.toString().padLeft(2, '0');
    final minute = vietnamTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeClass = context.screenSizeClass;
    final accessLogsAsync = ref.watch(accessLogsProvider);
    
    return accessLogsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Chưa có lịch sử',
                style: context.responsiveBodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        
        // Limit to max 5 visible items, rest scrollable
        // Each item: text (~20px) + separator (12-16px) ≈ 32-36px per item
        // 5 items ≈ 160-180px
        final maxVisibleHeight = sizeClass == ScreenSizeClass.expanded 
            ? 180.0  // ~5 items for expanded screens
            : 160.0; // ~5 items for compact screens
        
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxVisibleHeight),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: logs.length,
            separatorBuilder: (context, index) => SizedBox(
              height: sizeClass == ScreenSizeClass.compact 
                  ? AppSpacing.md 
                  : AppSpacing.lg,
            ),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      log.userName,
                      style: context.responsiveBodyM.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: AppColors.borderSoft,
                    margin: EdgeInsets.symmetric(
                      horizontal: sizeClass == ScreenSizeClass.compact 
                          ? AppSpacing.md 
                          : AppSpacing.lg,
                    ),
                  ),
                  Text(
                    _formatTime(log.time),
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Lỗi khi tải lịch sử',
            style: context.responsiveBodyM.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

/// Card action buttons: Thêm Thẻ and Xoá Thẻ
class _CardActionButtons extends ConsumerWidget {
  const _CardActionButtons({
    required this.onAddCard,
  });

  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeClass = context.screenSizeClass;
    final buttonHeight = sizeClass == ScreenSizeClass.expanded ? 56.0 : 48.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 24.0 : 20.0;
    final spacing = sizeClass == ScreenSizeClass.compact 
        ? AppSpacing.md 
        : AppSpacing.lg;

    return Row(
      children: [
        Expanded(
          child: _CardActionButton(
            label: 'Thêm Thẻ',
            backgroundColor: AppColors.cardBlue,
            icon: Icons.add,
            iconSize: iconSize,
            height: buttonHeight,
            onTap: onAddCard,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _CardActionButton(
            label: 'Xoá Thẻ',
            backgroundColor: AppColors.primary,
            icon: Icons.delete_outline,
            iconSize: iconSize,
            height: buttonHeight,
            onTap: () {
              _showDeleteCardModal(context, ref);
            },
          ),
        ),
      ],
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.backgroundColor,
    required this.icon,
    required this.iconSize,
    required this.height,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final IconData icon;
  final double iconSize;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md)
        : EdgeInsets.symmetric(vertical: AppSpacing.md + 2, horizontal: AppSpacing.md);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: onTap,
        child: Container(
          height: height,
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: context.responsiveBodyM.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Name card modal dialog (shown when new unnamed card is detected)
class _NameCardModal extends ConsumerStatefulWidget {
  const _NameCardModal({
    required this.cardId,
    required this.onComplete,
  });

  final String cardId;
  final VoidCallback onComplete;

  @override
  ConsumerState<_NameCardModal> createState() => _NameCardModalState();
}

class _NameCardModalState extends ConsumerState<_NameCardModal> {
  final _nameController = TextEditingController();
  bool _isUpdating = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateCardName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên người dùng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final datasource = ref.read(rfidCardFirestoreDataSourceProvider);
      await datasource.updateOwnerName(widget.cardId, name);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm thẻ cho: $name'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final dialogWidth = sizeClass == ScreenSizeClass.expanded 
        ? 400.0 
        : MediaQuery.of(context).size.width * 0.85;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background
            Container(
              padding: EdgeInsets.symmetric(
                vertical: sizeClass == ScreenSizeClass.expanded 
                    ? AppSpacing.xl 
                    : AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF03BE87),
                    Color(0xFF02A876),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.cardRadius),
                  topRight: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
              child: Center(
                child: Text(
                  'Thêm Thẻ',
                  style: context.responsiveTitleM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(
                sizeClass == ScreenSizeClass.expanded 
                    ? AppSpacing.xl 
                    : AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info message
                  Text(
                    'Thẻ mới đã được phát hiện! Vui lòng nhập tên cho thẻ này.',
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: sizeClass == ScreenSizeClass.expanded 
                      ? AppSpacing.lg 
                      : AppSpacing.md),
                  
                  // Input label
                  Text(
                    'Nhập Tên Người Dùng',
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: sizeClass == ScreenSizeClass.expanded 
                      ? AppSpacing.md 
                      : AppSpacing.sm),
                  
                  // Text field
                  TextField(
                    controller: _nameController,
                    enabled: !_isUpdating,
                    autofocus: true,
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.primarySoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: sizeClass == ScreenSizeClass.expanded 
                            ? AppSpacing.lg 
                            : AppSpacing.md,
                      ),
                      hintText: 'Ví dụ: Nguyễn Văn A',
                    ),
                    onSubmitted: (_) => _updateCardName(),
                  ),
                  
                  SizedBox(height: sizeClass == ScreenSizeClass.expanded 
                      ? AppSpacing.xl 
                      : AppSpacing.lg),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ModalButton(
                          label: 'Hủy',
                          backgroundColor: AppColors.textSecondary,
                          onTap: _isUpdating ? null : widget.onComplete,
                        ),
                      ),
                      SizedBox(width: sizeClass == ScreenSizeClass.expanded 
                          ? AppSpacing.lg 
                          : AppSpacing.md),
                      Expanded(
                        child: _isUpdating
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _ModalButton(
                                label: 'Thêm',
                                backgroundColor: AppColors.primary,
                                onTap: _updateCardName,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add card modal dialog
class _AddCardModal extends StatefulWidget {
  const _AddCardModal();

  @override
  State<_AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<_AddCardModal> {
  final _nameController = TextEditingController(text: 'Nguyễn Đức Thịnh');
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final dialogWidth = sizeClass == ScreenSizeClass.expanded 
        ? 400.0 
        : MediaQuery.of(context).size.width * 0.85;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background
            Container(
              padding: EdgeInsets.symmetric(
                vertical: sizeClass == ScreenSizeClass.expanded 
                    ? AppSpacing.xl 
                    : AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF03BE87),
                    Color(0xFF02A876),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.cardRadius),
                  topRight: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
              child: Center(
                child: Text(
                  'Thêm Thẻ',
                  style: context.responsiveTitleM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(
                sizeClass == ScreenSizeClass.expanded 
                    ? AppSpacing.xl 
                    : AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input label
                  Text(
                    'Nhập Tên Người Dùng',
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: sizeClass == ScreenSizeClass.expanded 
                      ? AppSpacing.md 
                      : AppSpacing.sm),
                  
                  // Text field
                  TextField(
                    controller: _nameController,
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.primarySoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: sizeClass == ScreenSizeClass.expanded 
                            ? AppSpacing.lg 
                            : AppSpacing.md,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: sizeClass == ScreenSizeClass.expanded 
                      ? AppSpacing.xl 
                      : AppSpacing.lg),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ModalButton(
                          label: 'Hủy',
                          backgroundColor: AppColors.textPrimary,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: sizeClass == ScreenSizeClass.expanded 
                          ? AppSpacing.lg 
                          : AppSpacing.md),
                      Expanded(
                        child: _ModalButton(
                          label: 'Thêm',
                          backgroundColor: AppColors.primary,
                          onTap: () {
                            // TODO: Implement add card logic
                            final name = _nameController.text.trim();
                            if (name.isNotEmpty) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã thêm thẻ cho: $name'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal button widget
class _ModalButton extends StatelessWidget {
  const _ModalButton({
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final buttonHeight = sizeClass == ScreenSizeClass.expanded ? 52.0 : 48.0;
    
    return Material(
      color: onTap == null ? backgroundColor.withOpacity(0.5) : backgroundColor,
      borderRadius: BorderRadius.circular(buttonHeight / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(buttonHeight / 2),
        onTap: onTap,
        child: Container(
          height: buttonHeight,
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.responsiveBodyM.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Show delete card modal dialog
void _showDeleteCardModal(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => _DeleteCardModal(ref: ref),
  );
}

/// Delete card modal dialog
class _DeleteCardModal extends ConsumerWidget {
  const _DeleteCardModal({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final namedCardsAsync = ref.watch(namedRfidCardsProvider);
    final sizeClass = context.screenSizeClass;
    final dialogWidth = sizeClass == ScreenSizeClass.expanded 
        ? 400.0 
        : MediaQuery.of(context).size.width * 0.85;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: namedCardsAsync.when(
          data: (namedCards) => _DeleteCardModalContent(cards: namedCards),
          loading: () => Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) {
            // Log error for debugging
            debugPrint('Error loading named cards: $error');
            // Show empty content on error
            return _DeleteCardModalContent(cards: []);
          },
        ),
      ),
    );
  }
}

class _DeleteCardModalContent extends ConsumerStatefulWidget {
  const _DeleteCardModalContent({required this.cards});

  final List<RfidCardDocument> cards;

  @override
  ConsumerState<_DeleteCardModalContent> createState() => _DeleteCardModalContentState();
}

class _DeleteCardModalContentState extends ConsumerState<_DeleteCardModalContent> {
  Future<void> _deleteCard(String cardId, String ownerName) async {
    try {
      final datasource = ref.read(rfidCardFirestoreDataSourceProvider);
      await datasource.deleteCard(cardId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xoá: $ownerName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xoá: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteAll() async {
    try {
      final datasource = ref.read(rfidCardFirestoreDataSourceProvider);
      await datasource.deleteAllCards();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xoá tất cả thẻ'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xoá tất cả: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background
            Container(
              padding: EdgeInsets.symmetric(
                vertical: sizeClass == ScreenSizeClass.expanded 
                    ? AppSpacing.xl 
                    : AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF03BE87),
                    Color(0xFF02A876),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.cardRadius),
                  topRight: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
              child: Center(
                child: Text(
                  'Xoá Thẻ',
                  style: context.responsiveTitleM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            
            // User list with ScrollView - max 3 items visible
            Container(
              constraints: BoxConstraints(
                maxHeight: widget.cards.isEmpty 
                    ? 100 
                    : (sizeClass == ScreenSizeClass.expanded ? 240.0 : 210.0), // Height for ~3 items
              ),
              child: widget.cards.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(
                          sizeClass == ScreenSizeClass.expanded 
                              ? AppSpacing.xxl 
                              : AppSpacing.xl,
                        ),
                        child: Text(
                          'Không có thẻ nào',
                          style: context.responsiveBodyM.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(
                        sizeClass == ScreenSizeClass.expanded 
                            ? AppSpacing.lg 
                            : AppSpacing.md,
                      ),
                      itemCount: widget.cards.length,
                      separatorBuilder: (context, index) => Divider(
                        height: AppSpacing.md,
                        thickness: 1,
                        color: AppColors.borderSoft,
                      ),
                      itemBuilder: (context, index) {
                        final card = widget.cards[index];
                        return _UserListItem(
                          name: card.ownerName,
                          isActive: card.isActive,
                          onDelete: () => _deleteCard(card.id, card.ownerName),
                        );
                      },
                    ),
            ),
            
            // Action buttons
            Padding(
              padding: EdgeInsets.all(
                sizeClass == ScreenSizeClass.expanded 
                    ? AppSpacing.xl 
                    : AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ModalButton(
                      label: 'Hủy',
                      backgroundColor: AppColors.textSecondary,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: sizeClass == ScreenSizeClass.expanded 
                      ? AppSpacing.lg 
                      : AppSpacing.md),
                  Expanded(
                    child: _ModalButton(
                      label: 'Xoá Tất Cả',
                      backgroundColor: Colors.red,
                      onTap: widget.cards.isEmpty ? () {} : _deleteAll,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }
}

/// User list item widget
class _UserListItem extends StatelessWidget {
  const _UserListItem({
    required this.name,
    required this.isActive,
    required this.onDelete,
  });

  final String name;
  final bool isActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: sizeClass == ScreenSizeClass.expanded 
            ? AppSpacing.sm 
            : AppSpacing.xs,
      ),
      child: Row(
        children: [
          // User name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.responsiveBodyM.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs / 2),
                // Active status
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? AppColors.primary.withOpacity(0.1) 
                        : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Text(
                    isActive ? 'Đang hoạt động' : 'Dừng hoạt động',
                    style: context.responsiveBodyM.copyWith(
                      fontSize: sizeClass == ScreenSizeClass.expanded ? 11.0 : 10.0,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: sizeClass == ScreenSizeClass.expanded ? 24.0 : 20.0,
            ),
            padding: EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

