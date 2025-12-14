import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// Basic responsive size classes used for spacing decisions.
enum ScreenSizeClass { compact, medium, expanded }

ScreenSizeClass screenSizeClassForWidth(double width) {
  if (width < 600) {
    return ScreenSizeClass.compact;
  }
  if (width < 1024) {
    return ScreenSizeClass.medium;
  }
  return ScreenSizeClass.expanded;
}

extension ScreenSizeContextX on BuildContext {
  ScreenSizeClass get screenSizeClass =>
      screenSizeClassForWidth(MediaQuery.sizeOf(this).width);
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.showBack = false,
    this.scrollable = true,
    this.padding,
  });

  final String title;
  final Widget body;
  final Widget? action;
  final bool showBack;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final horizontal = _horizontalPaddingFor(sizeClass);
    final content = Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: AppSpacing.lg,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showBack)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headlineL,
                ),
              ),
              if (action != null) action!,
            ],
          ),
          AppSpacing.h16,
          body,
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: scrollable ? SingleChildScrollView(child: content) : content,
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
