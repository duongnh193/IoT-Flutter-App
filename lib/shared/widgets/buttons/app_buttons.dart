import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background,
    this.foreground,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = background ?? colorScheme.primary;
    final fg = foreground ?? colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return bg.withAlpha(230);
            }
            if (states.contains(WidgetState.hovered)) {
              return bg.withAlpha(242);
            }
            return bg;
          }),
          foregroundColor: WidgetStateProperty.all(fg),
          overlayColor: WidgetStateProperty.all(fg.withAlpha(15)),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 2;
            if (states.contains(WidgetState.hovered)) return 6;
            return 3;
          }),
          shadowColor: WidgetStateProperty.all(bg.withAlpha(76)),
          padding:
              WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          textStyle: WidgetStateProperty.all(
            Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.leading,
    required this.background,
    required this.textColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget leading;
  final Color background;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final baseBorder = borderColor ?? Colors.transparent;
    final hoverBorder = baseBorder.withAlpha(230);
    final pressBorder = baseBorder.withAlpha(255);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return background.withAlpha(242);
            }
            if (states.contains(WidgetState.hovered)) {
              return background.withAlpha(247);
            }
            return background;
          }),
          overlayColor: WidgetStateProperty.all(
            Colors.black.withAlpha(10),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return BorderSide(color: pressBorder, width: 1.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return BorderSide(color: hoverBorder, width: 1.3);
            }
            return BorderSide(color: baseBorder, width: 1.2);
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          textStyle: WidgetStateProperty.all(
            Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: textColor),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
