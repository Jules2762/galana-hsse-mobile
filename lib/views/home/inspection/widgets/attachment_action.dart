import 'package:flutter/material.dart';

class AttachmentAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const AttachmentAction({
    super.key,
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
      height: 80,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: selected ? const Color(0xFF0F9D58) : const Color(0xFFE2E8F0),
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: selected ? const Color(0xFF0F9D58) : Colors.black54,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: selected ? const Color(0xFF0F9D58) : Colors.black87,
            ),
          ),
        ],
      ),
    )
  ,
    );}
}
