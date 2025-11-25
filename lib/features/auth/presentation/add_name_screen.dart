import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../providers/auth_session_provider.dart';

class AddNameScreen extends ConsumerWidget {
  const AddNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      title: 'Thêm tên',
      panelHeightFactor: 0.75,
      contentTopPaddingFactor: 0.1,
      waveOffset: -8,
      panelBuilder: (panelConstraints) {
        final maxWidth = panelConstraints.maxWidth > 340
            ? 320.0
            : panelConstraints.maxWidth * 0.9;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/icons8-home 2.svg',
              width: 120,
              height: 100,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            AppSpacing.h16,
            Text(
              'Nhập tên hiển thị',
              style: AppTypography.titleM,
            ),
            AppSpacing.h8,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: TextField(
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Tên của bạn',
                  filled: true,
                  fillColor: AppColors.primarySoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.borderSoft),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.borderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: AppTypography.titleM,
              ),
            ),
            AppSpacing.h24,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220, minHeight: 54),
              child: AppPrimaryButton(
                label: 'Tiếp tục',
                background: AppColors.primary,
                onPressed: () {
                  ref.read(authSessionProvider.notifier).logIn();
                  context.pushReplacementNamed(AppRoute.dashboard.name);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
