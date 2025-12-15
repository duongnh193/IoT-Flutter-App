import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../models/device.dart';
import '../../../../shared/layout/device_panel_layout.dart';
import '../../di/device_dependencies.dart';

class CurtainPanel extends ConsumerStatefulWidget {
  const CurtainPanel({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<CurtainPanel> createState() => _CurtainPanelState();
}

class _CurtainPanelState extends ConsumerState<CurtainPanel> {
  int? _lastPosition; // Track last position to prevent duplicate updates
  bool _isDragging = false;
  double _position = 0; // Current position from Firebase
  DateTime? _lastUpdateTime; // Track when we last updated via UI

  @override
  void initState() {
    super.initState();
    // Initialize from device state
    _position = widget.device.isOn ? 100.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Watch Firebase data for this device
    final deviceDataAsync = ref.watch(deviceDataProvider(widget.device.id));
    
    // Update position when Firebase data changes (only when not dragging)
    // Đọc 'position' từ phần cứng (hardware response) để hiển thị trên UI
    deviceDataAsync.whenData((data) {
      if (data != null && !_isDragging && mounted) {
        final now = DateTime.now();
        // Ignore stream updates for 2 seconds after manual update
        if (_lastUpdateTime != null && 
            now.difference(_lastUpdateTime!).inSeconds < 2) {
          return; // Don't override optimistic update yet
        }
        
        // position: Giá trị từ phần cứng (hardware response) - dùng để hiển thị
        final positionValue = data['position'];
        int position = 0;
        if (positionValue is int) {
          position = positionValue;
        } else if (positionValue is double) {
          position = positionValue.round();
        }
        final newPosition = position.toDouble().clamp(0.0, 100.0);
        
        // Only update if value changed to avoid unnecessary rebuilds
        if ((newPosition - _position).abs() > 0.5) {
          setState(() {
            _position = newPosition;
          });
        }
      }
    });

    // Use current position (either from drag or Firebase)
    final currentPosition = _position;

    final String stateLabel = currentPosition <= 0 
        ? 'Đang đóng' 
        : 'Đang mở ${currentPosition.round()}%';

    return DevicePanelLayout(
      icon: widget.device.type.icon,
      title: 'Rèm Cửa',
      stateLabel: stateLabel,
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary,
          AppColors.panel,
        ],
      ),
      mainControl: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CurtainVisual(position: currentPosition),
          AppSpacing.h16,
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.borderMedium,
              thumbColor: Colors.white,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: currentPosition,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _position = value; // Update position while dragging
                });
              },
              onChangeEnd: (value) {
                setState(() {
                  _isDragging = false;
                  _position = value; // Final position
                });
                _handlePositionChange(value.round());
              },
            ),
          ),
        ],
      ),
      secondaryControls: [
        _PresetRow(
          currentValue: currentPosition,
          onSelect: (value) => _handlePositionChange(value.round()),
        ),
      ],
      automation: const _AutomationList(),
    );
  }

  Future<void> _handlePositionChange(int newPosition) async {
    if (_lastPosition == newPosition) return; // Prevent duplicate updates
    
    _lastPosition = newPosition;
    _lastUpdateTime = DateTime.now(); // Track update time
    // Optimistic update already done in onChangeEnd
    // Position is already set in state
    
    final repository = ref.read(deviceRepositoryProvider);
    try {
      // Gửi 'target_pos' lên Firebase (UI command) - phần cứng sẽ đọc và cập nhật 'position'
      await repository.updateCurtainPosition(widget.device.id, newPosition);
    } catch (e) {
      // Revert on error
      _lastPosition = null;
      _lastUpdateTime = null;
      if (mounted) {
        // Revert will happen via stream
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}

class _CurtainVisual extends StatelessWidget {
  const _CurtainVisual({required this.position});

  final double position;

  @override
  Widget build(BuildContext context) {
    final openFactor = position / 100;
    final panelHeight = AppSpacing.xxl * 5;
    final panelWidth = AppSpacing.xxl * 6;

    return Container(
      height: panelHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius + AppSpacing.sm),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: panelWidth,
              height: panelHeight / 1.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
            ),
            Positioned(
              left: panelWidth / 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: panelWidth / 2 * (1 - openFactor),
                height: panelHeight / 1.5,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
              ),
            ),
            Icon(
              Icons.curtains,
              color: AppColors.primary,
              size: AppSpacing.xxl * 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.currentValue,
    required this.onSelect,
  });

  final double currentValue;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final presets = <(String, int)>[
      ('Đóng', 0),
      ('50%', 50),
      ('Mở hết', 100),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nút nhanh', style: AppTypography.titleM),
        AppSpacing.h8,
        Wrap(
          spacing: AppSpacing.sm,
          children: presets
              .map(
                (preset) => ChoiceChip(
                  label: Text(preset.$1),
                  selected: currentValue.round() == preset.$2,
                  onSelected: (_) => onSelect(preset.$2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    side: const BorderSide(color: AppColors.borderSoft),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primarySoft,
                  labelStyle: AppTypography.bodyM,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AutomationList extends StatelessWidget {
  const _AutomationList();

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Mở lúc 7:00',
      'Đóng khi trời tối',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tự động hóa', style: AppTypography.titleM),
        AppSpacing.h12,
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item,
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
