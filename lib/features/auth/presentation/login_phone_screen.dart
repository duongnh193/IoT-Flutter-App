import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class LoginPhoneScreen extends StatelessWidget {
  const LoginPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Đăng Nhập Bằng Số\nĐiện Thoại',
      panelHeightFactor: 0.72,
      contentTopPaddingFactor: 0.08,
      waveOffset: -8,
      panelBuilder: (panelConstraints) {
        final maxFieldWidth =
            panelConstraints.maxWidth > 360 ? 300.0 : panelConstraints.maxWidth * 0.86;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/icons8-home 2.svg',
              width: 140,
              height: 120,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            AppSpacing.h16,
            Text(
              'Nhập số điện thoại của bạn',
              style: AppTypography.titleM,
            ),
            AppSpacing.h8,
            Text(
              'Chúng tôi sẽ gửi mã xác nhận này tới số máy này',
              style: AppTypography.bodyM.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            AppSpacing.h16,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxFieldWidth),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _FlagBadge(code: '+84'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: '123456789',
                          border: InputBorder.none,
                        ),
                        style: AppTypography.titleM,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.h24,
            const Spacer(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxFieldWidth,
                minHeight: 54,
              ),
              child: AppPrimaryButton(
                label: 'Sign in',
                background: AppColors.primary,
                onPressed: () {
                  context.push('/pin');
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/flag_vn.svg',
            width: 28,
            height: 20,
          ),
          const SizedBox(width: 6),
          Text(
            code,
            style: AppTypography.titleM,
          ),
        ],
      ),
    );
  }
}
