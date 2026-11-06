import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/extensions/context_extensions.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class InspectionSegmentTab extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final int vmcCount;
  final int checklistCount;
  final int equipmentCount;

  const InspectionSegmentTab({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.vmcCount = 14,
    this.checklistCount = 8,
    this.equipmentCount = 45,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          _buildSegmentItem(
            index: 0,
            icon: Icons.verified_user_outlined,
            label: "VMC",
            count: vmcCount,
            isDark: isDark,
          ),
          _buildSegmentItem(
            index: 1,
            icon: Icons.fact_check_outlined,
            label: "Checklists",
            count: checklistCount,
            isDark: isDark,
          ),
          _buildSegmentItem(
            index: 2,
            icon: Icons.fire_extinguisher_outlined,
            label: context.l10n.equipment,
            count: equipmentCount,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem({
    required int index,
    required IconData icon,
    required String label,
    required int count,
    bool isDark = false,
  }) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
