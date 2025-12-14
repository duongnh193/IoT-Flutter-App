import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../models/device.dart';
import '../../../../shared/layout/device_panel_layout.dart';
import '../../di/device_dependencies.dart';

class FanPanel extends ConsumerStatefulWidget {
  const FanPanel({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<FanPanel> createState() => _FanPanelState();
}

class _FanPanelState extends ConsumerState<FanPanel> {
  int? _lastCommand; // Track last command to prevent duplicate updates
  int timerIndex = 1;
  int _speed = 0; // Current speed from Firebase (0 = tắt, 1-3 = tốc độ)
  bool _isOn = false; // Current state from Firebase
  DateTime? _lastUpdateTime; // Track when we last updated via UI

  @override
  void initState() {
    super.initState();
    // Initialize from device
    _isOn = widget.device.isOn;
    _speed = widget.device.isOn ? 1 : 0; // Default to speed 1 if on, 0 if off
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
        
        // Read from 'mode' (hardware state) - this is what hardware sends to DB
        final mode = data['mode'] as int? ?? 0;
        final newIsOn = mode > 0;
        // Speed: mode = 0 → tắt (speed = 0), mode = 1,2,3 → tốc độ tương ứng
        final newSpeed = mode.clamp(0, 3);
        
        // Only update if values changed to avoid unnecessary rebuilds
        if (newSpeed != _speed || newIsOn != _isOn) {
          setState(() {
            _speed = newSpeed;
            _isOn = newIsOn;
          });
        }
      }
    });

    final timers = ['Tắt', '30 phút', '1 giờ', '2 giờ'];

    return DevicePanelLayout(
      icon: widget.device.type.icon,
      title: 'Quạt',
      stateLabel: _isOn ? 'Đang bật' : 'Đang tắt',
      background: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.controlPurple,
          AppColors.controlPurpleDark,
        ],
      ),
      mainControl: _SpeedDial(speed: _speed, isOn: _isOn),
      secondaryControls: [
        _OptionChips(
          label: 'Tốc độ',
          options: const ['0', '1', '2', '3'],
          selectedIndex: _speed.clamp(0, 3),
          onSelected: (index) => _handleSpeedChange(index),
        ),
        _OptionChips(
          label: 'Hẹn giờ',
          options: timers,
          selectedIndex: timerIndex,
          onSelected: (index) => setState(() => timerIndex = index),
        ),
      ],
      automation: const _AutomationList(
        items: [
          'Bật khi nhiệt độ > 30°C',
          'Tắt sau 2 giờ',
        ],
      ),
    );
  }

  Future<void> _handleSpeedChange(int newSpeed) async {
    // newSpeed is 0, 1, 2, or 3 (0 = tắt, 1-3 = tốc độ)
    // We send this directly to 'command' field in Firebase
    if (_lastCommand == newSpeed) return; // Prevent duplicate updates
    
    _lastCommand = newSpeed;
    _lastUpdateTime = DateTime.now(); // Track update time
    // Optimistic update - UI shows new speed immediately
    setState(() {
      _speed = newSpeed;
      _isOn = newSpeed > 0; // Speed > 0 means on, 0 means off
    });
    
    final repository = ref.read(deviceRepositoryProvider);
    try {
      // Send command to Firebase: 0 = tắt, 1-3 = tốc độ
      await repository.updateFanCommand(widget.device.id, newSpeed);
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

class _SpeedDial extends StatelessWidget {
  const _SpeedDial({required this.speed, required this.isOn});

  final int speed;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    // Make size responsive to match AC panel pattern
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialSize = screenWidth < 400 || screenHeight < 700
        ? AppSpacing.xxl * 4.5  // Much smaller on compact screens
        : screenWidth < 450
            ? AppSpacing.xxl * 5  // Medium on small screens
            : AppSpacing.xxl * 6;  // Full size on larger screens
    final progress = speed > 0 ? speed / 3 : 0.0;

    return Center(
      child: SizedBox(
        height: dialSize,
        width: dialSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: dialSize * 0.8,
              width: dialSize * 0.8,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: AppSpacing.md,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                backgroundColor: AppColors.primarySoft,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.toys,
                  color: AppColors.primary,
                  size: AppSpacing.xxl * 1.5,
                ),
                AppSpacing.h8,
                Text(
                  speed > 0 ? 'Tốc độ $speed' : 'Đang tắt',
                  style: AppTypography.titleM.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionChips extends StatelessWidget {
  const _OptionChips({
    required this.label,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.titleM),
        AppSpacing.h8,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < options.length; i++)
              ChoiceChip(
                label: Text(options[i]),
                selected: i == selectedIndex,
                onSelected: (_) => onSelected(i),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  side: const BorderSide(color: AppColors.borderSoft),
                ),
                backgroundColor: Colors.white,
                selectedColor: AppColors.primarySoft,
                labelStyle: AppTypography.bodyM,
              ),
          ],
        ),
      ],
    );
  }
}

class _AutomationList extends StatelessWidget {
  const _AutomationList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tự động hóa', style: AppTypography.titleM),
        AppSpacing.h12,
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.primary),
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
