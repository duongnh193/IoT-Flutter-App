import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/layout/auth_scaffold.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1, milliseconds: 300), () {
      if (mounted) {
        context.pushReplacementNamed(AppRoute.addName.name);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Success',
      panelHeightFactor: 0.7,
      contentTopPaddingFactor: 0.12,
      waveOffset: -8,
      panelBuilder: (panelConstraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/like-thumb-hand-success-svgrepo-com 1.png',
              width: 140,
              fit: BoxFit.contain,
            ),
            AppSpacing.h20,
            Text(
              'Đăng nhập thành công',
              style: AppTypography.titleM,
            ),
            AppSpacing.h8,
            Text(
              'Đang chuyển tiếp...',
              style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      },
    );
  }
}
