import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../models/device.dart';
import '../../../../shared/layout/device_panel_layout.dart';

class ACPanel extends StatefulWidget {
  const ACPanel({super.key, required this.device});

  final Device device;

  @override
  State<ACPanel> createState() => _ACPanelState();
}

class _ACPanelState extends State<ACPanel> {
  double temperature = 22;
  int speed = 1;
  int modeIndex = 1;
  bool isOn = true;

  final modes = const [
    (Icons.schedule, 'Hẹn giờ'),
    (Icons.ac_unit, 'Làm mát'),
    (Icons.water_drop, 'Khử ẩm'),
    (Icons.wb_sunny_outlined, 'Sưởi'),
  ];

  @override
  Widget build(BuildContext context) {
    return DevicePanelLayout(
      icon: widget.device.type.icon,
      title: 'Điều hòa',
      stateLabel: isOn ? 'Bật' : 'Tắt',
      modeSelector: _ModeSelector(
        modes: modes,
        selected: modeIndex,
        onChanged: (index) => setState(() => modeIndex = index),
      ),
      mainControl: _TempGauge(value: temperature),
      secondaryControls: [
        _SpeedControl(
          speed: speed,
          onChanged: (value) => setState(() => speed = value),
        ),
        _TempSlider(
          value: temperature,
          onChanged: (value) => setState(() => temperature = value),
        ),
        _PowerControl(
          isOn: isOn,
          onToggle: (value) => setState(() => isOn = value),
        ),
      ],
      automation: const _AutomationList(
        items: [
          'Bật trước 10 phút khi về nhà',
          'Tắt khi phòng trống',
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.modes,
    required this.selected,
    required this.onChanged,
  });

  final List<(IconData, String)> modes;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm, // Add runSpacing for better wrapping
      children: List.generate(modes.length, (index) {
        final mode = modes[index];
        final active = index == selected;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mode.$1,
                size: AppSpacing.lg,
                color: active ? AppColors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(mode.$2),
            ],
          ),
          selected: active,
          onSelected: (_) => onChanged(index),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            side: const BorderSide(color: AppColors.borderSoft),
          ),
          labelStyle: AppTypography.bodyM.copyWith(
            color: active ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colors.white,
          selectedColor: AppColors.controlPurple,
        );
      }),
    );
  }
}

class _TempGauge extends StatelessWidget {
  const _TempGauge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value - 16) / 14;
    // Make size responsive to avoid overflow on smaller screens
    // Match Fan panel sizing - use smaller size to prevent overflow
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final size = screenWidth < 400 || screenHeight < 700
        ? AppSpacing.xxl * 4.5  // Much smaller on compact screens
        : screenWidth < 450
            ? AppSpacing.xxl * 5  // Medium on small screens
            : AppSpacing.xxl * 6;  // Full size on larger screens

    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: size * 0.8,
              width: size * 0.8,
              child: CircularProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                strokeWidth: AppSpacing.md,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.controlPurple,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            Container(
              height: size * 0.45,
              width: size * 0.45,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${value.toStringAsFixed(0)}°C',
                      style: AppTypography.headlineL.copyWith(
                        color: AppColors.controlPurpleDark,
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      'Nhiệt độ',
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedControl extends StatelessWidget {
  const _SpeedControl({required this.speed, required this.onChanged});

  final int speed;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tốc độ', style: AppTypography.titleM),
        AppSpacing.h8,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: List.generate(3, (index) {
            final value = index + 1;
            final active = value == speed;
            return ChoiceChip(
              label: Text(value.toString()),
              selected: active,
              onSelected: (_) => onChanged(value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                side: const BorderSide(color: AppColors.borderSoft),
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primarySoft,
              labelStyle: AppTypography.bodyM,
            );
          }),
        ),
      ],
    );
  }
}

class _TempSlider extends StatelessWidget {
  const _TempSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nhiệt độ', style: AppTypography.titleM),
        AppSpacing.h8, // Reduced from h12 to match Fan panel
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.controlPurple,
            inactiveTrackColor: AppColors.primarySoft,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: value,
            min: 16,
            max: 30,
            onChanged: onChanged,
            divisions: 14,
            label: '${value.toStringAsFixed(0)}°C',
          ),
        ),
      ],
    );
  }
}

class _PowerControl extends StatelessWidget {
  const _PowerControl({required this.isOn, required this.onToggle});

  final bool isOn;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nguồn', style: AppTypography.titleM),
              AppSpacing.h8,
              Text(
                isOn ? 'Bật' : 'Tắt',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isOn,
          activeThumbColor: AppColors.controlPurple,
          activeTrackColor: AppColors.controlPurpleSoft,
          onChanged: onToggle,
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
                const Icon(Icons.event_available, color: AppColors.controlPurple),
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
