import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.panelBuilder,
    this.panelHeightFactor = 0.74,
    this.contentTopPaddingFactor = 0.1,
    this.waveAsset = 'assets/images/—Pngtree—green wavy line shade image_8955302 1.png',
    this.waveOffset = -10,
    this.minPanelHeight = 360,
    this.backgroundColor = AppColors.primary,
    this.panelColor = AppColors.panel,
    this.titleWidget,
    this.showWave = true,
    this.panelScrollable = false,
    this.panelOffset = 0,
    this.panelShadow,
    this.backgroundGradient,
    this.panelOffsetFactor,
    this.horizontalPadding = 20,
    this.horizontalPaddingFactor,
  });

  final String title;
  final Widget Function(BoxConstraints panelConstraints) panelBuilder;
  final double panelHeightFactor;
  final double contentTopPaddingFactor;
  final String waveAsset;
  final double waveOffset;
  final double minPanelHeight;
  final Color backgroundColor;
  final Color panelColor;
  final Widget? titleWidget;
  final bool showWave;
  final bool panelScrollable;
  final double panelOffset;
  final List<BoxShadow>? panelShadow;
  final Gradient? backgroundGradient;
  final double? panelOffsetFactor;
  final double horizontalPadding;
  final double? horizontalPaddingFactor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final panelHeight =
              (constraints.maxHeight * panelHeightFactor).clamp(minPanelHeight, constraints.maxHeight);
          final contentTopPadding = panelHeight * contentTopPaddingFactor;
          final effectiveOffset = panelOffsetFactor != null
              ? constraints.maxHeight * panelOffsetFactor!
              : panelOffset;
          final effectiveHorizontalPadding = horizontalPaddingFactor != null
              ? constraints.maxWidth * horizontalPaddingFactor!
              : horizontalPadding;

          return Container(
            decoration: BoxDecoration(
              color: backgroundGradient == null ? backgroundColor : null,
              gradient: backgroundGradient,
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        AppSpacing.h16,
                        titleWidget ??
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: AppTypography.headlineL,
                            ),
                        AppSpacing.h20,
                        const Spacer(),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: effectiveOffset,
                    height: panelHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: panelShadow ??
                            [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 12,
                                offset: const Offset(0, -4),
                              ),
                            ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: contentTopPadding,
                          bottom: showWave ? 0 : 48, // Remove bottom padding when wave is shown
                          left: effectiveHorizontalPadding,
                          right: effectiveHorizontalPadding,
                        ),
                        child: LayoutBuilder(
                          builder: (context, panelConstraints) {
                            final content = panelBuilder(panelConstraints);
                            if (panelScrollable) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: panelConstraints.maxHeight,
                                  ),
                                  child: content,
                                ),
                              );
                            }
                            return content;
                          },
                        ),
                      ),
                    ),
                  ),
                  if (showWave)
                    Positioned(
                      bottom: waveOffset,
                      child: IgnorePointer(
                        child: Image.asset(
                          waveAsset,
                          width: constraints.maxWidth,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
