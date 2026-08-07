import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class InspectionFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const InspectionFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : Colors.white,

          borderRadius: BorderRadius.circular(50),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : const Color(0xFFD9DEE5),
            width: 1,
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),

              const SizedBox(width: 6),
            ],

            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}