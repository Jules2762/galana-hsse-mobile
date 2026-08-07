import 'package:flutter/material.dart';

class SettingsNavigationTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const SettingsNavigationTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Container(
        height: 56,

        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFF1F5F9),
            ),
          ),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF64748B),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                ),
              ),

            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }
}