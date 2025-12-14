import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/responsive_typography.dart';
import 'app_scaffold.dart';

/// Unified Content Scaffold - A flexible, responsive layout component
/// Based on AuthScaffold pattern but optimized for all content screens
/// 
/// Features:
/// - Fully responsive (compact/medium/expanded)
/// - Panel-based layout with customizable positioning
/// - Supports both scrollable and non-scrollable content
/// - Consistent spacing and padding
/// - Easy to debug with clear structure
class ContentScaffold extends StatelessWidget {
  const ContentScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.showWave = false,
    this.backgroundColor,
    this.panelColor,
    this.panelHeightFactor,
    this.contentTopPaddingFactor = 0.08,
    this.horizontalPaddingFactor,
    this.scrollable = true,
    this.showBack = false,
    this.titleWidget,
    this.floatingActionButton,
  });

  /// Screen title (used if titleWidget is null)
  final String title;
  
  /// Optional subtitle shown below title
  final String? subtitle;
  
  /// Main content builder - receives constraints for responsive calculations
  final Widget Function(BuildContext context, BoxConstraints constraints) body;
  
  /// Optional action buttons in header
  final List<Widget>? actions;
  
  /// Show decorative wave at bottom
  final bool showWave;
  
  /// Background color (defaults to AppColors.panel)
  final Color? backgroundColor;
  
  /// Panel background color (defaults to Colors.white)
  final Color? panelColor;
  
  /// Panel height as factor of screen height (0.0 - 1.0)
  /// If null, panel takes remaining space after title
  final double? panelHeightFactor;
  
  /// Top padding factor inside panel (relative to panel height)
  final double contentTopPaddingFactor;
  
  /// Horizontal padding factor (relative to screen width)
  /// If null, uses responsive padding based on screen size
  final double? horizontalPaddingFactor;
  
  /// Enable scrolling in content area
  final bool scrollable;
  
  /// Show back button
  final bool showBack;
  
  /// Custom title widget (overrides title String)
  final Widget? titleWidget;
  
  /// Optional floating action button
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor ?? AppColors.panel,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive calculations
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          
          // Calculate panel height
          final effectivePanelHeightFactor = panelHeightFactor ?? 
              _defaultPanelHeightFactor(sizeClass);
          final panelHeight = (screenHeight * effectivePanelHeightFactor)
              .clamp(_minPanelHeight(sizeClass), screenHeight);
          
          // Calculate padding
          final effectiveHorizontalPadding = horizontalPaddingFactor != null
              ? screenWidth * horizontalPaddingFactor!
              : _responsiveHorizontalPadding(sizeClass);
          
          final contentTopPadding = panelHeight * contentTopPaddingFactor;
          
          return SafeArea(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Header section (title area)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _HeaderSection(
                    context: context,
                    title: title,
                    subtitle: subtitle,
                    titleWidget: titleWidget,
                    showBack: showBack,
                    actions: actions,
                    horizontalPadding: effectiveHorizontalPadding,
                  ),
                ),
                
                // Content panel
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: panelHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: panelColor ?? Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.cardRadius + 8),
                        topRight: Radius.circular(AppSpacing.cardRadius + 8),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: contentTopPadding,
                        bottom: _bottomPadding(sizeClass),
                        left: effectiveHorizontalPadding,
                        right: effectiveHorizontalPadding,
                      ),
                      child: LayoutBuilder(
                        builder: (context, panelConstraints) {
                          final content = body(context, panelConstraints);
                          if (scrollable) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: content,
                            );
                          }
                          return content;
                        },
                      ),
                    ),
                  ),
                ),
                
                // Decorative wave (optional)
                if (showWave)
                  Positioned(
                    bottom: -10,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/images/—Pngtree—green wavy line shade image_8955302 1.png',
                        width: screenWidth,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Default panel height factor based on screen size
  double _defaultPanelHeightFactor(ScreenSizeClass sizeClass) {
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return 0.75; // 75% on mobile
      case ScreenSizeClass.medium:
        return 0.80; // 80% on tablet
      case ScreenSizeClass.expanded:
        return 0.85; // 85% on desktop
    }
  }

  /// Minimum panel height based on screen size
  double _minPanelHeight(ScreenSizeClass sizeClass) {
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return 400.0;
      case ScreenSizeClass.medium:
        return 500.0;
      case ScreenSizeClass.expanded:
        return 600.0;
    }
  }

  /// Responsive horizontal padding
  double _responsiveHorizontalPadding(ScreenSizeClass sizeClass) {
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppSpacing.lg;
      case ScreenSizeClass.medium:
        return AppSpacing.xl;
      case ScreenSizeClass.expanded:
        return AppSpacing.xl + AppSpacing.md;
    }
  }

  /// Bottom padding based on screen size
  double _bottomPadding(ScreenSizeClass sizeClass) {
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppSpacing.xl;
      case ScreenSizeClass.medium:
        return AppSpacing.xxl;
      case ScreenSizeClass.expanded:
        return AppSpacing.xxl + AppSpacing.md;
    }
  }
}

/// Header section component
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.context,
    required this.title,
    this.subtitle,
    this.titleWidget,
    required this.showBack,
    this.actions,
    required this.horizontalPadding,
  });

  final BuildContext context;
  final String title;
  final String? subtitle;
  final Widget? titleWidget;
  final bool showBack;
  final List<Widget>? actions;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final verticalPadding = sizeClass == ScreenSizeClass.compact 
        ? AppSpacing.md 
        : AppSpacing.lg;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBack) ...[
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: sizeClass == ScreenSizeClass.compact 
                ? AppSpacing.sm 
                : AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget ??
                    Text(
                      title,
                      style: context.responsiveHeadlineL,
                    ),
                if (subtitle != null) ...[
                  SizedBox(height: sizeClass == ScreenSizeClass.compact 
                      ? AppSpacing.xs 
                      : AppSpacing.sm),
                  Text(
                    subtitle!,
                    style: context.responsiveBodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            SizedBox(width: AppSpacing.sm),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

