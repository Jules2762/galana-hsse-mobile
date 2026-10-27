import 'package:flutter/material.dart';

class AnswerOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const AnswerOptionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),

        height: 58,

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: .08)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(16),

          border: Border.all(
            color: selected
                ? color
                : const Color(
                    0xFFE2E8F0,
                  ),
            width: 1.5,
          ),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected
                      ? color
                      : const Color(
                          0xFF334155,
                        ),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}