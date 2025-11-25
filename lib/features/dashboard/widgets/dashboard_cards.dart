import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class DashboardShortcutCard extends StatelessWidget {
  const DashboardShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withAlpha(30),
          highlightColor: AppColors.primary.withAlpha(20),
          onTap: onTap,
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: AppColors.primary),
                ),
                const Spacer(),
                Text(
                  title,
                  style: AppTypography.bodyM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardStatusChip extends StatelessWidget {
  const DashboardStatusChip({
    super.key,
    required this.icon,
    this.iconAsset,
    required this.title,
    required this.value,
    required this.background,
    this.width,
  });

  final IconData icon;
  final String? iconAsset;
  final String title;
  final String value;
  final Color background;
  final double? width;

  Widget _buildIcon() {
    if (iconAsset != null) {
      if (iconAsset!.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          iconAsset!,
          width: 50,
          height: 50,
        );
      }
      return Image.asset(
        iconAsset!,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      );
    }
    return Icon(icon, color: AppColors.textPrimary, size: 18);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: background,
          // borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: AppColors.borderSoft),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: _buildIcon(),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.bodyM.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.titleM.copyWith(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
