import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Security Pin',
      panelHeightFactor: 0.72,
      contentTopPaddingFactor: 0.1,
      waveOffset: -10,
      panelBuilder: (panelConstraints) {
        final maxWidth = panelConstraints.maxWidth > 320
            ? 320.0
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
                      right: index == _pinLength - 1 ? 0 : 12,
                    ),
                    child: SizedBox(
                      width: 42,
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
              constraints: const BoxConstraints(maxWidth: 220, minHeight: 48),
              child: AppPrimaryButton(
                label: 'Accept',
                background: AppColors.primary,
                onPressed: () {
                  if (_pin.length == _pinLength) {
                    context.pushReplacementNamed(AppRoute.phoneSuccess.name);
                  }
                },
              ),
            ),
            AppSpacing.h12,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220, minHeight: 46),
              child: AppPrimaryButton(
                label: 'Send Again',
                background: AppColors.primarySoft,
                foreground: AppColors.textPrimary,
                onPressed: () {},
              ),
            ),
          ],
        );
      },
    );
  }
}
