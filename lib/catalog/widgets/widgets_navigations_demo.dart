import 'package:flutter/material.dart';

Widget widget_DrawerTile(
  BuildContext context, {
  required IconData icon,
  required String text,
  required bool selected,
  VoidCallback? onTap,
}) {
  const iconColor = Color(0xFF42a6ee);
  final surfaceColor = Theme.of(context).colorScheme.surface;
  final defaultTextColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
  return Container(
    decoration: BoxDecoration(
      color: selected ? surfaceColor : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
    ),
    child: ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(
          color: selected ? iconColor : defaultTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        onTap?.call();
        Navigator.pop(context);
      },
    ),
  );
}
