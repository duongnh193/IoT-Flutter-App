import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/responsive_typography.dart';
import '../../../shared/layout/app_scaffold.dart';
import '../../../shared/layout/content_scaffold.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/scene_provider.dart';
import 'scene_card.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenesAsync = ref.watch(sceneControllerProvider);
    final sizeClass = context.screenSizeClass;

    return ContentScaffold(
      title: 'Ngữ cảnh',
      subtitle: 'Tự động hóa theo kịch bản',
      panelHeightFactor: sizeClass == ScreenSizeClass.expanded ? 0.85 : 0.80,
      horizontalPaddingFactor: 0.06,
      scrollable: true,
      onRefresh: () async {
        await ref.read(sceneControllerProvider.notifier).refresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add_task_rounded),
          tooltip: 'Thêm ngữ cảnh',
        ),
      ],
      body: (context, constraints) {
        return scenesAsync.when(
          data: (scenes) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TipCard(),
              SizedBox(height: sizeClass == ScreenSizeClass.compact 
                  ? AppSpacing.md 
                  : AppSpacing.lg),
              if (scenes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Text(
                      'Chưa có ngữ cảnh nào',
                      style: context.responsiveBodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...scenes.map((scene) => Padding(
                  padding: EdgeInsets.only(
                    bottom: sizeClass == ScreenSizeClass.compact 
                        ? AppSpacing.md 
                        : AppSpacing.lg,
                  ),
                  child: SceneCard(
                    scene: scene,
                    onToggle: () => ref
                        .read(sceneControllerProvider.notifier)
                        .toggle(scene.id),
                  ),
                )),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Lỗi: $error',
                style: context.responsiveBodyM,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    
    return AppCard(
      padding: EdgeInsets.all(
        sizeClass == ScreenSizeClass.expanded 
            ? AppSpacing.xl 
            : AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              sizeClass == ScreenSizeClass.expanded 
                  ? AppSpacing.lg 
                  : AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(
              Icons.auto_mode,
              color: AppColors.primary,
              size: sizeClass == ScreenSizeClass.expanded ? 28 : 24,
            ),
          ),
          SizedBox(width: sizeClass == ScreenSizeClass.compact 
              ? AppSpacing.md 
              : AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tự động hóa',
                  style: context.responsiveTitleM.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: sizeClass == ScreenSizeClass.compact 
                    ? AppSpacing.xs 
                    : AppSpacing.sm),
                Text(
                  'Gắn ngữ cảnh vào cảm biến hoặc lịch trình để bắn lệnh tự động.',
                  style: context.responsiveBodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
