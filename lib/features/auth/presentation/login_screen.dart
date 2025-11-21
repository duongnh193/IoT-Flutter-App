import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = AppColors.primary;
    const panelColor = AppColors.panel;

    return Scaffold(
      backgroundColor: background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxButtonWidth =
              constraints.maxWidth > 360 ? 290.0 : constraints.maxWidth * 0.82;
          const buttonHeight = 70.0;
          final verticalOffset = constraints.maxHeight * 0.2;

          return SafeArea(
            child: Column(
              children: [
                AppSpacing.h28,
                Text(
                  'Welcome',
                  style: AppTypography.headlineL,
                ),
                AppSpacing.h32,
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(height: verticalOffset),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: maxButtonWidth,
                                  minHeight: buttonHeight,
                                ),
                                child: AppActionButton(
                                  label: 'Tiếp tục với Google',
                                  background: AppColors.primarySoft,
                                  borderColor: AppColors.borderMedium,
                                  textColor: AppColors.textPrimary,
                                  leading: SvgPicture.asset(
                                    'assets/icons/Logo.svg',
                                    width: 24,
                                    height: 28,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              AppSpacing.h20,
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.borderStrong,
                                        thickness: 2.4,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 14),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.borderStrong,
                                        thickness: 2.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.h20,
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: maxButtonWidth,
                                  minHeight: buttonHeight,
                                ),
                                child: AppActionButton(
                                  label: 'Tiếp tục với số điện thoại',
                                  background: Colors.white,
                                  textColor: AppColors.textPrimary,
                                  borderColor: AppColors.borderMedium,
                                  leading: SvgPicture.asset(
                                    'assets/icons/phone-number-svgrepo-com 1.svg',
                                    width: 24,
                                    height: 28,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -6,
                        child: Image.asset(
                          'assets/images/—Pngtree—green wavy line shade image_8955302 1.png',
                          width: constraints.maxWidth,
                          fit: BoxFit.cover,
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
