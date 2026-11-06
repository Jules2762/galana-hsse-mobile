import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final bool unread;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unread
            ? (isDark
                ? const Color(0xFF064E2A).withValues(alpha: 0.3)
                : const Color(0xFFF0FDF4))
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unread
              ? (isDark ? const Color(0xFF15803D) : const Color(0xFF86EFAC))
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: unread ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          if (unread)
            Container(
              width: 8,
              height: 8,

              decoration:
                  const BoxDecoration(
                color: Color(
                  0xFF2563EB,
                ),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}