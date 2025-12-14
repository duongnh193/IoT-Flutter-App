import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/auth_scaffold.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);

    try {
      if (_isSignUp) {
        await authController.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authController.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // Navigate to success screen on successful auth
      if (mounted) {
        context.pushNamed(AppRoute.phoneSuccess.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSignUp ? 'Đăng ký thất bại: $e' : 'Đăng nhập thất bại: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authController = ref.read(authControllerProvider.notifier);
    
    try {
      await authController.signInWithGoogle();
      // Navigate to success screen on successful auth
      if (mounted) {
        context.pushNamed(AppRoute.phoneSuccess.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AuthScaffold(
      title: 'Welcome',
      panelHeightFactor: 0.80,
      contentTopPaddingFactor: 0.06,
      waveOffset: -8,
      panelScrollable: true,
      panelBuilder: (panelConstraints) {
        final sizeClass = context.screenSizeClass;
        final maxWidth = panelConstraints.maxWidth > AppConstants.authContentMaxWidth
            ? AppConstants.authFieldMaxWidth
            : panelConstraints.maxWidth * 0.9;
        
        // Responsive spacing
        final fieldSpacing = sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.md 
            : AppSpacing.lg;
        final buttonSpacing = sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.md 
            : AppSpacing.lg;
        final sectionSpacing = sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.lg 
            : AppSpacing.xl;

        // Calculate spacing from bottom to place Google button below wave
        // Wave is positioned at bottom: -8 (waveOffset)
        // Wave image height is approximately 80-100px, add extra spacing
        final waveHeight = sizeClass == ScreenSizeClass.compact ? 80.0 : 100.0;
        final spacingFromBottom = waveHeight + (sizeClass == ScreenSizeClass.compact 
            ? AppSpacing.xl + AppSpacing.md
            : AppSpacing.xxl + AppSpacing.lg);
        
        // Calculate spacer height to push Google button down
        // Estimate total content height: email + password + button + divider + toggle = ~350px
        // Button height = ~70px, spacing = ~120px
        // Remaining space = panelHeight - 350 - buttonHeight - spacingFromBottom
        final estimatedContentHeight = 350.0;
        final buttonHeight = AppConstants.authButtonHeight;
        final spacerHeight = (panelConstraints.maxHeight > estimatedContentHeight + buttonHeight + spacingFromBottom)
            ? panelConstraints.maxHeight - estimatedContentHeight - buttonHeight - spacingFromBottom
            : AppSpacing.xl;

        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                // Email field
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AppColors.primarySoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: BorderSide(color: AppColors.borderSoft),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: BorderSide(color: AppColors.borderSoft),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    style: AppTypography.titleM,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: fieldSpacing),

                // Password field
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _handleEmailAuth(),
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: AppColors.primarySoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: BorderSide(color: AppColors.borderSoft),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: BorderSide(color: AppColors.borderSoft),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    style: AppTypography.titleM,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (_isSignUp && value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: sectionSpacing),

                // Submit button
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    minHeight: AppConstants.authButtonMinHeight,
                  ),
                  child: AppPrimaryButton(
                    label: isLoading
                        ? (_isSignUp ? 'Đang đăng ký...' : 'Đang đăng nhập...')
                        : (_isSignUp ? 'Đăng ký' : 'Đăng nhập'),
                    background: AppColors.primary,
                    onPressed: isLoading ? null : _handleEmailAuth,
                  ),
                ),
                SizedBox(height: buttonSpacing),

                // Divider
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppColors.borderStrong,
                          thickness: 2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'or',
                          style: AppTypography.titleM,
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppColors.borderStrong,
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: buttonSpacing),

                // Toggle sign up / sign in
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: _isSignUp
                              ? 'Đã có tài khoản? '
                              : 'Chưa có tài khoản? ',
                        ),
                        TextSpan(
                          text: _isSignUp ? 'Đăng nhập' : 'Đăng ký',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Spacer to push Google button to bottom
                // Use SizedBox instead of Spacer to avoid unbounded constraints error
                SizedBox(height: spacerHeight > 0 ? spacerHeight : AppSpacing.xs),
                
                // Google sign in button - positioned at bottom, below wave
                // Use padding from bottom to position below wave image
                Padding(
                  padding: EdgeInsets.only(bottom: spacingFromBottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      minHeight: AppConstants.authButtonHeight,
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
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
