import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../providers/auth_controller.dart';

class SecurityPinScreen extends ConsumerStatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  ConsumerState<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends ConsumerState<SecurityPinScreen> {
  static const _pinLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_pinLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_pinLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < _pinLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  String get _pin => _controllers.map((c) => c.text).join();

  Future<void> _handleVerifyOTP(
    BuildContext context,
    AuthController authController,
  ) async {
    if (_pin.length != _pinLength) return;

    try {
      await authController.verifyOTP(_pin);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mã OTP không đúng: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Clear PIN on error
      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);

    // Navigate on successful verification
    authState.whenData((user) {
      if (user != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushReplacementNamed(AppRoute.phoneSuccess.name);
          }
        });
      }
    });

    return AuthScaffold(
      title: 'Security Pin',
      panelHeightFactor: 0.72,
      contentTopPaddingFactor: 0.1,
      waveOffset: -10,
      panelBuilder: (panelConstraints) {
        final maxWidth = panelConstraints.maxWidth > AppConstants.authFieldMaxWidth
            ? AppConstants.authFieldMaxWidth
            : panelConstraints.maxWidth * 0.9;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Security Pin',
              style: AppTypography.titleM,
            ),
            AppSpacing.h20,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == _pinLength - 1 ? 0 : AppSpacing.md,
                    ),
                    child: SizedBox(
                      width: AppConstants.authPinBoxSize,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        autofocus: index == 0,
                        textAlign: TextAlign.center,
                        style: AppTypography.titleM,
                        keyboardType: TextInputType.number,
                        textInputAction:
                            index == _pinLength - 1 ? TextInputAction.done : TextInputAction.next,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (val) => _onChanged(index, val),
                      ),
                    ),
                  );
                }),
              ),
            ),
            AppSpacing.h32,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220, minHeight: AppConstants.authButtonMinHeight),
              child: AppPrimaryButton(
                label: authState.isLoading ? 'Đang xác thực...' : 'Xác nhận',
                background: AppColors.primary,
                onPressed: (authState.isLoading || _pin.length != _pinLength)
                    ? null
                    : () => _handleVerifyOTP(context, authController),
              ),
            ),
            AppSpacing.h12,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220, minHeight: AppConstants.authButtonMinHeight),
              child: AppPrimaryButton(
                label: 'Gửi lại mã',
                background: AppColors.primarySoft,
                foreground: AppColors.textPrimary,
                onPressed: () {
                  // Navigate back to phone screen to resend
                  context.pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
