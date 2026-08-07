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
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: .12,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    color: Color(
                      0xFF94A3B8,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(
                      0xFF94A3B8,
                    ),
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