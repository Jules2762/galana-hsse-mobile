import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const ActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color: statusColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                Icons.description_outlined,
                color: statusColor,
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
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),

              decoration: BoxDecoration(
                color:
                    statusColor.withOpacity(.15),
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}