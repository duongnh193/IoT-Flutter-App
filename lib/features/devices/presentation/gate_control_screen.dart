import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class GateControlScreen extends ConsumerStatefulWidget {
  const GateControlScreen({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<GateControlScreen> createState() => _GateControlScreenState();
}

class _GateControlScreenState extends ConsumerState<GateControlScreen>
    with SingleTickerProviderStateMixin {
  late bool isOpen;
  late AnimationController _controller;

  final history = const [
    ('Nguyễn Đức Thịnh', '12:20'),
    ('Nguyễn Đức Hoàng', '08:12'),
    ('Đinh Trọng Thành', '03:34'),
  ];

  @override
  void initState() {
    super.initState();
    isOpen = widget.device.isOn;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..value = isOpen ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleGate() {
    final notifier = ref.read(deviceControllerProvider.notifier);
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    notifier.toggle(widget.device.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.panel,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black87),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Text(
                      widget.device.name,
                      style: AppTypography.titleM.copyWith(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              _GateAnimation(controller: _controller),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DeviceHeader(
                          device: widget.device,
                          isOpen: isOpen,
                          onToggle: _toggleGate,
                        ),
                        AppSpacing.h20,
                        _HistoryList(history: history),
                        AppSpacing.h20,
                        _ActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader({
    required this.device,
    required this.isOpen,
    required this.onToggle,
  });

  final Device device;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            radius: 22,
            child: SvgPicture.asset(
              'assets/icons/phone-number-svgrepo-com 1.svg',
              width: 22,
              height: 22,
              colorFilter:
                  const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: AppTypography.titleM.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  isOpen ? 'Đang mở' : 'Đang đóng',
                  style: AppTypography.bodyM.copyWith(
                    color: isOpen ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: isOpen,
              onChanged: (_) => onToggle(),
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<(String, String)> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lịch Sử Ra Vào', style: AppTypography.titleM),
        AppSpacing.h12,
        ...history.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.$1,
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  item.$2,
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.primary,
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

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Thêm Thẻ',
            color: AppColors.roomSky,
            icon: Icons.add,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Xoá Thẻ',
            color: AppColors.primary,
            icon: Icons.delete_outline,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.bodyM.copyWith(
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

class _GateAnimation extends StatelessWidget {
  const _GateAnimation({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final openFactor = controller.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 60 * openFactor,
                  child: Icon(
                    Icons.garage_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 60 * openFactor,
                  child: Icon(
                    Icons.garage_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
