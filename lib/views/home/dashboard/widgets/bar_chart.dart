import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  final double value;
  final String day;

  const BarChart({
    super.key,
    required this.value,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.end,

      children: [
        Container(
          width: 12,
          height: value,

          decoration: BoxDecoration(
            color: const Color(0xFF0F9D58),
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}