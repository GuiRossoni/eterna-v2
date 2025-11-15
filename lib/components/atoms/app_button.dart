import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final String? semanticLabel;
  final Key? buttonKey;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.semanticLabel,
    this.buttonKey,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      textStyle: const TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: ElevatedButton(
        key: buttonKey,
        style: style,
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
