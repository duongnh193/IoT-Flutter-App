import 'package:flutter/material.dart';

import '../../models/device.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
    this.compact = false,
  });

  final Device device;
  final VoidCallback onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = device.isOn;
    final bgColor = isOn
        ? colorScheme.primary.withAlpha(31)
        : colorScheme.surfaceContainerHigh;

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOn ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        boxShadow: [
          if (isOn)
            BoxShadow(
              color: colorScheme.primary.withAlpha(31),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: isOn
                    ? colorScheme.onPrimary.withAlpha(31)
                    : Colors.white,
                child: Icon(
                  device.type.icon,
                  color: isOn ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
              Switch(
                value: isOn,
                activeThumbColor: colorScheme.onPrimary,
                activeTrackColor: colorScheme.primary,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            device.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            device.room,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (!compact) ...[
            const SizedBox(height: 12),
            Text(
              isOn ? 'Đang bật • ${device.power.toStringAsFixed(0)}W' : 'Đang tắt',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isOn
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
