import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../providers/auth_session_provider.dart';

class LoginSuccessScreen extends ConsumerStatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  ConsumerState<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends ConsumerState<LoginSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1, milliseconds: 300), () {
      if (mounted) {
        // Mark session logged-in so app restores to dashboard next time.
        ref.read(authSessionProvider.notifier).logIn();
        // Navigate directly to dashboard after successful login
        context.go('/dashboard');
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
              width: panelConstraints.maxWidth * 0.35,
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
