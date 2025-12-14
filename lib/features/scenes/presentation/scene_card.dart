import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../models/scene.dart';

class SceneCard extends StatelessWidget {
  const SceneCard({
    super.key,
    required this.scene,
    required this.onToggle,
  });

  final Scene scene;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final isActive = scene.isActive;
    
    final padding = sizeClass == ScreenSizeClass.expanded 
        ? AppSpacing.xl 
        : AppSpacing.lg;
    
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 28.0 : 24.0;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      onTap: onToggle,
      child: Ink(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primarySoft
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.borderSoft,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isActive ? 20 : 10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_mode,
              color: isActive ? AppColors.primary : AppColors.textPrimary,
              size: iconSize,
            ),
            SizedBox(width: sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.md 
                : AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.name,
                    style: context.responsiveTitleM.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    scene.description,
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Switch(
              value: isActive,
              onChanged: (_) => onToggle(),
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
