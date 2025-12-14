import 'package:flutter/material.dart';

import '../../shared/layout/app_scaffold.dart';
import 'app_typography.dart';

/// Responsive Typography extension
/// Provides responsive text styles based on screen size
extension ResponsiveTypography on BuildContext {
  /// Responsive headline XL
  TextStyle get responsiveHeadlineXL {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppTypography.headlineL.copyWith(fontSize: 24);
      case ScreenSizeClass.medium:
        return AppTypography.headlineXL.copyWith(fontSize: 26);
      case ScreenSizeClass.expanded:
        return AppTypography.headlineXL.copyWith(fontSize: 32);
    }
  }

  /// Responsive headline L
  TextStyle get responsiveHeadlineL {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppTypography.headlineL.copyWith(fontSize: 20);
      case ScreenSizeClass.medium:
        return AppTypography.headlineL.copyWith(fontSize: 22);
      case ScreenSizeClass.expanded:
        return AppTypography.headlineL.copyWith(fontSize: 26);
    }
  }

  /// Responsive title L
  TextStyle get responsiveTitleL {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppTypography.titleM.copyWith(fontSize: 18);
      case ScreenSizeClass.medium:
        return AppTypography.titleL.copyWith(fontSize: 20);
      case ScreenSizeClass.expanded:
        return AppTypography.titleL.copyWith(fontSize: 22);
    }
  }

  /// Responsive title M
  TextStyle get responsiveTitleM {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppTypography.titleM.copyWith(fontSize: 16);
      case ScreenSizeClass.medium:
        return AppTypography.titleM;
      case ScreenSizeClass.expanded:
        return AppTypography.titleM.copyWith(fontSize: 20);
    }
  }

  /// Responsive body M
  TextStyle get responsiveBodyM {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppTypography.bodyM.copyWith(fontSize: 14);
      case ScreenSizeClass.medium:
        return AppTypography.bodyM;
      case ScreenSizeClass.expanded:
        return AppTypography.bodyM.copyWith(fontSize: 17);
    }
  }

  /// Responsive label M
  TextStyle get responsiveLabelM {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return AppTypography.labelM.copyWith(fontSize: 12);
      case ScreenSizeClass.medium:
        return AppTypography.labelM;
      case ScreenSizeClass.expanded:
        return AppTypography.labelM.copyWith(fontSize: 15);
    }
  }
}

/// Responsive spacing extension
extension ResponsiveSpacing on BuildContext {
  /// Responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return const EdgeInsets.symmetric(horizontal: 16);
      case ScreenSizeClass.medium:
        return const EdgeInsets.symmetric(horizontal: 24);
      case ScreenSizeClass.expanded:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  /// Responsive vertical padding
  EdgeInsets get responsiveVerticalPadding {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return const EdgeInsets.symmetric(vertical: 12);
      case ScreenSizeClass.medium:
        return const EdgeInsets.symmetric(vertical: 16);
      case ScreenSizeClass.expanded:
        return const EdgeInsets.symmetric(vertical: 20);
    }
  }

  /// Responsive screen padding
  EdgeInsets get responsiveScreenPadding {
    return responsiveHorizontalPadding + responsiveVerticalPadding;
  }
}

/// Responsive grid extension
extension ResponsiveGrid on BuildContext {
  /// Get responsive max cross axis extent for GridView
  double get responsiveGridMaxCrossAxisExtent {
    final sizeClass = screenSizeClass;
    final width = MediaQuery.sizeOf(this).width;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return width * 0.45; // 2 columns
      case ScreenSizeClass.medium:
        return width * 0.3; // 3 columns
      case ScreenSizeClass.expanded:
        return width * 0.22; // 4-5 columns
    }
  }

  /// Get responsive cross axis count for GridView
  int get responsiveGridCrossAxisCount {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return 2;
      case ScreenSizeClass.medium:
        return 3;
      case ScreenSizeClass.expanded:
        return 4;
    }
  }

  /// Get responsive child aspect ratio
  double get responsiveGridChildAspectRatio {
    final sizeClass = screenSizeClass;
    switch (sizeClass) {
      case ScreenSizeClass.compact:
        return 0.85;
      case ScreenSizeClass.medium:
        return 0.9;
      case ScreenSizeClass.expanded:
        return 1.0;
    }
  }
}

