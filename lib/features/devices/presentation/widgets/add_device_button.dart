import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/layout/app_scaffold.dart';

/// Floating action button for adding devices
/// Used across all room screens
class AddDeviceButton extends StatelessWidget {
  const AddDeviceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.screenSizeClass;
    final buttonSize = sizeClass == ScreenSizeClass.expanded ? 64.0 : 56.0;
    final iconSize = sizeClass == ScreenSizeClass.expanded ? 28.0 : 24.0;
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: () {
            // TODO: Navigate to add device screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tính năng thêm thiết bị đang được phát triển'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

