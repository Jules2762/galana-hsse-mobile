import 'package:flutter/material.dart';

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showBadge;
  final String badgeValue;
  final VoidCallback? onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.showBadge = false,
    this.badgeValue = "0",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 75,
        child: Column(
          children: [
            Badge(
              isLabelVisible: showBadge,
              label: Text(badgeValue),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F9D58).withValues(alpha: 0.2)
                      : const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0F9D58),
                  size: 24,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}