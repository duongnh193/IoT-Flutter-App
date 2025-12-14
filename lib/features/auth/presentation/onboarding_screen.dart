import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  final _pages = const [
    _OnboardingPage(
      title: 'Quản Lý Điện Năng\nTiêu Thụ',
      imagePath:
          'assets/images/ilustracion-3d-mano-dinero-blanco-removebg-preview 1.png',
    ),
    _OnboardingPage(
      title: 'Điều Khiển Ngôi\nNhà Trong Tầm\nTay Bạn',
      imagePath:
          'assets/images/bank-card-mobile-phone-online-payment-removebg-preview 1.png',
    ),
  ];

  void _next() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushNamed(AppRoute.login.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = AppColors.primary;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),
            AppSpacing.h16,
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl + 4,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  AppPrimaryButton(
                    label: 'Tiếp Tục',
                    background: Colors.white,
                    foreground: Colors.black87,
                    onPressed: _next,
                  ),
                  AppSpacing.h16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        width: isActive ? 10 : 8,
                        height: isActive ? 10 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.teal.shade600
                              : Colors.teal.shade200,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.imagePath,
  });

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl + 12,
            left: AppSpacing.lg + 4,
            right: AppSpacing.lg + 4,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineL,
          ),
        ),
        AppSpacing.h24,
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 12),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl + 4),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
