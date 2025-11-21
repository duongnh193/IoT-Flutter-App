import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/main_layout.dart';
import '../providers/scene_provider.dart';
import 'scene_card.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneControllerProvider);

    return MainLayout(
      title: 'Ngữ cảnh',
      subtitle: 'Tự động hóa theo kịch bản',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add_task_rounded),
        ),
      ],
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 12),
        itemCount: scenes.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _TipCard();
          }
          final scene = scenes[index - 1];
          return SceneCard(
            scene: scene,
            onToggle: () =>
                ref.read(sceneControllerProvider.notifier).toggle(scene.id),
          );
        },
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tự động hóa',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gắn ngữ cảnh vào cảm biến hoặc lịch trình để bắn lệnh tự động.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
