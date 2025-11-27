import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class DeviceControlScreen extends ConsumerStatefulWidget {
  const DeviceControlScreen({
    super.key,
    required this.device,
  });

  final Device device;

  @override
  ConsumerState<DeviceControlScreen> createState() =>
      _DeviceControlScreenState();
}

class _DeviceControlScreenState extends ConsumerState<DeviceControlScreen> {
  late double temp;
  int speed = 1;
  int modeIndex = 0;

  final modes = const [
    ('assets/icons/clock.svg', 'Hẹn giờ'),
    ('assets/icons/snow.svg', 'Làm mát'),
    ('assets/icons/bright.svg', 'Năng lượng'),
    ('assets/icons/drop.svg', 'Hút ẩm'),
  ];

  @override
  void initState() {
    super.initState();
    temp = 22;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(deviceControllerProvider.notifier);
    final isOn = ref.watch(deviceControllerProvider).firstWhere(
          (d) => d.id == widget.device.id,
          orElse: () => widget.device,
        ).isOn;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.controlPurple,
              Color(0xFF9A3DF0),
              AppColors.controlPurpleDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(title: widget.device.name),
                AppSpacing.h16,
                _ModeSelector(
                  modes: modes,
                  selected: modeIndex,
                  onChanged: (i) => setState(() => modeIndex = i),
                ),
                AppSpacing.h20,
                _TempGauge(
                  value: temp,
                  onChanged: (v) => setState(() => temp = v),
                ),
                AppSpacing.h20,
                _SpeedPowerRow(
                  speed: speed,
                  onSpeedChanged: (v) => setState(() => speed = v),
                  isOn: isOn,
                  onTogglePower: () => notifier.toggle(widget.device.id),
                ),
                AppSpacing.h16,
                _TempSlider(
                  value: temp,
                  onChanged: (v) => setState(() => temp = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        Text(
          title,
          style: AppTypography.titleM.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.modes,
    required this.selected,
    required this.onChanged,
  });

  final List<(String, String)> modes;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(modes.length, (index) {
        final isActive = index == selected;
        final (asset, _) = modes[index];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    asset,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      isActive ? AppColors.controlPurple : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TempGauge extends StatelessWidget {
  const _TempGauge({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (value - 16) / 14; // 16 -> 30

    return Center(
      child: SizedBox(
        height: 240,
        width: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 210,
              width: 210,
              child: CircularProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                strokeWidth: 16,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.controlPurpleSoft,
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Container(
              height: 140,
              width: 140,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${value.toStringAsFixed(0)}°C',
                    style: AppTypography.headlineL.copyWith(
                      color: AppColors.controlPurpleDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phòng ngủ',
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
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

class _SpeedPowerRow extends StatelessWidget {
  const _SpeedPowerRow({
    required this.speed,
    required this.onSpeedChanged,
    required this.isOn,
    required this.onTogglePower,
  });

  final int speed;
  final ValueChanged<int> onSpeedChanged;
  final bool isOn;
  final VoidCallback onTogglePower;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Speed',
                    style: AppTypography.bodyM.copyWith(
                      color: Colors.white,
                    )),
                AppSpacing.h8,
                Row(
                  children: List.generate(3, (i) {
                    final val = i + 1;
                    final active = val == speed;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => onSpeedChanged(val),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            '$val',
                            style: AppTypography.bodyM.copyWith(
                              color: active
                                  ? AppColors.controlPurpleDark
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CardContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Power',
                        style: AppTypography.bodyM.copyWith(
                          color: Colors.white,
                        )),
                    AppSpacing.h8,
                    Text(
                      isOn ? 'ON' : 'OFF',
                      style: AppTypography.titleM.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: isOn,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.controlPurpleSoft,
                    inactiveTrackColor: Colors.white38,
                    onChanged: (_) => onTogglePower(),
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

class _TempSlider extends StatefulWidget {
  const _TempSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_TempSlider> createState() => _TempSliderState();
}

class _TempSliderState extends State<_TempSlider> {
  late double localValue;

  @override
  void initState() {
    super.initState();
    localValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant _TempSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      localValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temp', style: AppTypography.bodyM.copyWith(color: Colors.white)),
          AppSpacing.h12,
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: Colors.white,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
            ),
            child: Slider(
              value: localValue,
              min: 16,
              max: 30,
              onChanged: (v) {
                setState(() => localValue = v);
                widget.onChanged(v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('16°C',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('30°C',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.controlPurpleDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }
}
