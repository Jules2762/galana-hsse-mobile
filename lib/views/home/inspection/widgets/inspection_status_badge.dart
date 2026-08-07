import 'package:flutter/material.dart';

class InspectionStatusBadge extends StatelessWidget {
  final String status;

  const InspectionStatusBadge({
    super.key,
    required this.status,
  });

  Color get backgroundColor {
    switch (status.toLowerCase()) {
      case 'terminée':
        return const Color(0xFFDDF7E5);

      case 'en cours':
        return const Color(0xFFE8F0FF);

      case 'planifiée':
        return const Color(0xFFF5F5F5);

      case 'critique':
        return const Color(0xFFFEE2E2);

      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color get textColor {
    switch (status.toLowerCase()) {
      case 'terminée':
        return const Color(0xFF22C55E);

      case 'en cours':
        return const Color(0xFF3B82F6);

      case 'planifiée':
        return const Color(0xFF94A3B8);

      case 'critique':
        return const Color(0xFFEF4444);

      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),

      alignment: Alignment.center,

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),

      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}