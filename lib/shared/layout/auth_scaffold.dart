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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final panelHeight =
              (constraints.maxHeight * panelHeightFactor).clamp(minPanelHeight, constraints.maxHeight);
          final contentTopPadding = panelHeight * contentTopPaddingFactor;

          return SafeArea(
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
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: panelHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: panelColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: contentTopPadding,
                                bottom: 48,
                              ),
                              child: LayoutBuilder(
                                builder: (context, panelConstraints) {
                                  final content = panelBuilder(panelConstraints);
                                  if (panelScrollable) {
                                    return SingleChildScrollView(
                                      child: content,
                                    );
                                  }
                                  return content;
                                },
                              ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
