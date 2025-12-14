import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'app_scaffold.dart';

/// Shared shell for all device detail screens.
class DevicePanelLayout extends StatelessWidget {
  const DevicePanelLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.stateLabel,
    required this.mainControl,
    required this.secondaryControls,
    required this.automation,
    this.modeSelector,
    this.onBack,
    this.actions,
    this.background,
  });

  final IconData icon;
  final String title;
  final String stateLabel;
  final Widget? modeSelector;
  final Widget mainControl;
  final List<Widget> secondaryControls;
  final Widget automation;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Gradient? background;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final horizontal = _horizontalPaddingFor(sizeClass);

    final mainCard = _PanelCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (modeSelector != null) ...[
            modeSelector!,
            SizedBox(height: sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.md 
                : AppSpacing.lg), // Reduced spacing for compact screens
          ],
          Flexible(
            child: mainControl, // Make mainControl flexible to prevent overflow
          ),
          for (int i = 0; i < secondaryControls.length; i++) ...[
            SizedBox(height: sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.md 
                : AppSpacing.lg), // Reduced spacing between controls
            secondaryControls[i],
          ],
        ],
      ),
    );

    final automationCard = _PanelCard(child: automation);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: background ??
              const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.controlPurple,
                  AppColors.controlPurpleDark,
                ],
              ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  icon: icon,
                  title: title,
                  stateLabel: stateLabel,
                  onBack: onBack,
                  actions: actions,
                ),
                AppSpacing.h16,
                if (sizeClass == ScreenSizeClass.expanded)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: mainCard),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: automationCard),
                    ],
                  )
                else ...[
                  mainCard,
                  AppSpacing.h16,
                  automationCard,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _horizontalPaddingFor(ScreenSizeClass sizeClass) {
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppSpacing.lg;
      case ScreenSizeClass.medium:
        return AppSpacing.xl;
      case ScreenSizeClass.expanded:
        return AppSpacing.xl + AppSpacing.md;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.title,
    required this.stateLabel,
    this.onBack,
    this.actions,
  });

  final IconData icon;
  final String title;
  final String stateLabel;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.controlPurpleDark),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleM.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                stateLabel,
                style: AppTypography.bodyM.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    // Reduce padding on compact screens to save space
    final padding = sizeClass == ScreenSizeClass.compact 
        ? const EdgeInsets.all(AppSpacing.md) 
        : const EdgeInsets.all(AppSpacing.lg);
    
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius + AppSpacing.sm),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: AppSpacing.lg,
            offset: Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: child,
    );
  }
}
