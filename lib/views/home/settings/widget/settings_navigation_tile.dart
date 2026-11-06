import 'package:flutter/material.dart';

class SettingsNavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const SettingsNavigationTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: dividerColor,
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: valueColor,
              ),
          ],
        ),
      ),
    );
  }
}
