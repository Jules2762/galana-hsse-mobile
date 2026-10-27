import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class ChecklistSectionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const ChecklistSectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.borderColor,
    this.onTap,
  });

  @override
  State<ChecklistSectionTile> createState() =>
      _ChecklistSectionTileState();
}

class _ChecklistSectionTileState
    extends State<ChecklistSectionTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFFE2E8F0),
          width: widget.borderColor != null ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),

        childrenPadding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 16,
        ),

        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),

        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),

        onExpansionChanged: (value) {
          setState(() {
            expanded = value;
          });
        },

        leading: CircleAvatar(
          radius: 16,
          backgroundColor:
              widget.iconColor.withValues(
            alpha: .12,
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: widget.iconColor,
          ),
        ),

        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),

        subtitle: Text(
          widget.subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),

        trailing: Icon(
          expanded
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
          color: AppColors.textSecondary,
        ),

        children: [
          QuestionItem(
            title:
                "Les extincteurs sont disponibles ?",
            onTap: widget.onTap,
          ),

          QuestionItem(
            title:
                "Les voies d'évacuation sont dégagées ?",
            onTap: widget.onTap,
          ),

          QuestionItem(
            title:
                "La signalisation est visible ?",
            onTap: widget.onTap,
          ),

          QuestionItem(
            title:
                "Les équipements sont conformes ?",
            onTap: widget.onTap,
          ),
        ],
      ),
    );
  }
}

class QuestionItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const QuestionItem({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: onTap ??
          () {
            Navigator.pushNamed(
              context,
              AppRoutes.inspectionQuestion,
            );
          },

      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 6,
        ),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}