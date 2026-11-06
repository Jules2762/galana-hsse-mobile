import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class InspectionProgressBar extends StatelessWidget {
  final double progress;

  const InspectionProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: const Color(0xFFE5E7EB),
        
        valueColor: const AlwaysStoppedAnimation(
          AppColors.primary,
        ),
      ),
    );
  }
}