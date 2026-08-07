import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';

class ReportCard extends StatelessWidget {
  final String category;
  final String title;
  final String inspector;
  final String date;
  final int conformity;

  const ReportCard({
    super.key,
    required this.category,
    required this.title,
    required this.inspector,
    required this.date,
    required this.conformity,
  });

  Color get badgeColor {
    if (conformity >= 90) {
      return const Color(0xFF22C55E);
    }

    if (conformity >= 75) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF1F5F9),
                  borderRadius:
                      BorderRadius.circular(
                    6,
                  ),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                date,
                style: const TextStyle(
                  color: Color(
                    0xFF94A3B8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Inspecteur: $inspector",
            style: const TextStyle(
              color: Color(
                0xFF94A3B8,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Text(
                "Conformité:",
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: badgeColor.withValues(
                    alpha: .15,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),

                child: Text(
                  "$conformity%",
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.reportDetails);
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                ),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.download_outlined,
                ),
              ),

              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.share_outlined,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}