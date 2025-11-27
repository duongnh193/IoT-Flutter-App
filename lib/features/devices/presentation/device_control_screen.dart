import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class DeviceControlScreen extends ConsumerWidget {
  const DeviceControlScreen({
    super.key,
    required this.device,
  });

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(deviceControllerProvider.notifier);
    final isOn = device.isOn;

    return AuthScaffold(
      title: device.name,
      showWave: false,
      panelHeightFactor: 0.9,
      contentTopPaddingFactor: 0.1,
      panelScrollable: true,
      horizontalPaddingFactor: 0.08,
      panelBuilder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.h12,
            _ControlHeader(
              device: device,
              isOn: isOn,
              onToggle: () => notifier.toggle(device.id),
            ),
            AppSpacing.h20,
            _TempSlider(initial: 24),
            AppSpacing.h16,
            _OptionsRow(),
          ],
        );
      },
      titleWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Text(
              device.name,
              style: AppTypography.headlineL.copyWith(color: Colors.black87),
            ),
            AppSpacing.h8,
            Icon(device.type.icon, size: 48, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}

class _ControlHeader extends StatelessWidget {
  const _ControlHeader({
    required this.device,
    required this.isOn,
    required this.onToggle,
  });

  final Device device;
  final bool isOn;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device.room, style: AppTypography.bodyM),
              const SizedBox(height: 6),
              Text(
                isOn ? 'Đang bật' : 'Đang tắt',
                style: AppTypography.titleM.copyWith(
                  color: isOn ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: isOn,
              activeTrackColor: AppColors.primary,
              activeThumbColor: AppColors.white,
              onChanged: (_) => onToggle(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TempSlider extends StatefulWidget {
  const _TempSlider({required this.initial});

  final double initial;

  @override
  State<_TempSlider> createState() => _TempSliderState();
}

class _TempSliderState extends State<_TempSlider> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nhiệt độ', style: AppTypography.titleM),
          AppSpacing.h12,
          Row(
            children: [
              Text('${value.toStringAsFixed(0)}°C',
                  style: AppTypography.headlineL),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() => value = (value - 1).clamp(16, 30)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => value = (value + 1).clamp(16, 30)),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 16,
            max: 30,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => value = val),
          ),
        ],
      ),
    );
  }
}

class _OptionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final options = [
      (Icons.ac_unit, 'Làm mát'),
      (Icons.waves, 'Quạt'),
      (Icons.bolt, 'Tiết kiệm'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options
          .map(
            (opt) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSoft),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(opt.$1, color: AppColors.primary),
                      const SizedBox(height: 6),
                      Text(
                        opt.$2,
                        style: AppTypography.bodyM.copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
