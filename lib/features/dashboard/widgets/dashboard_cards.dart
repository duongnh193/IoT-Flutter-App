import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';

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
    final sizeClass = context.screenSizeClass;
    final minHeight = sizeClass == ScreenSizeClass.expanded 
        ? 140.0
        : sizeClass == ScreenSizeClass.medium
            ? 130.0
            : 120.0;
    
    final iconRadius = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.cardRadius + 2
        : AppSpacing.cardRadius;
    
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl
        : AppSpacing.lg;
    
    return Expanded(
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          splashColor: AppColors.primary.withAlpha(30),
          highlightColor: AppColors.primary.withAlpha(20),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight),
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: iconRadius,
                  backgroundColor: Colors.white,
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: iconRadius * 1.2,
                  ),
                ),
                SizedBox(height: sizeClass == ScreenSizeClass.compact 
                    ? AppSpacing.sm 
                    : AppSpacing.md),
                Text(
                  title,
                  style: context.responsiveBodyM.copyWith(
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

  Widget _buildIcon(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final iconSize = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.cardRadius * 3
        : sizeClass == ScreenSizeClass.medium
            ? AppSpacing.cardRadius * 2.5
            : AppSpacing.cardRadius * 2;
    
    if (iconAsset != null) {
      if (iconAsset!.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          iconAsset!,
          width: iconSize,
          height: iconSize,
        );
      }
      return Image.asset(
        iconAsset!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }
    return Icon(
      icon,
      color: AppColors.textPrimary,
      size: sizeClass == ScreenSizeClass.expanded ? 20 : 18,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final minHeight = sizeClass == ScreenSizeClass.expanded 
        ? 120.0
        : sizeClass == ScreenSizeClass.medium
            ? 110.0
            : 100.0;
    
    final avatarRadius = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.cardRadius * 2
        : sizeClass == ScreenSizeClass.medium
            ? AppSpacing.cardRadius * 1.8
            : AppSpacing.cardRadius * 1.6;
    
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.lg
        : AppSpacing.md;
    
    return SizedBox(
      width: width,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: background,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.white,
              child: _buildIcon(context),
            ),
            SizedBox(height: sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.sm 
                : AppSpacing.md),
            Text(
              title,
              style: context.responsiveLabelM.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: context.responsiveTitleM.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}
