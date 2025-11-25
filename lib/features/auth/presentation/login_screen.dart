import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome',
      panelHeightFactor: 0.72,
      contentTopPaddingFactor: 0.08,
      waveOffset: -8,
      panelBuilder: (panelConstraints) {
        final maxButtonWidth =
            panelConstraints.maxWidth > 360 ? 290.0 : panelConstraints.maxWidth * 0.82;
        const buttonHeight = 70.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxButtonWidth,
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: AppColors.borderStrong,
                      thickness: 2.4,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
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
                onPressed: () {
                  context.pushNamed(AppRoute.loginPhone.name);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
