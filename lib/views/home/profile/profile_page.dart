import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/profile/widget/profile_info_row.dart';
import 'package:gestion_hsse/views/home/profile/widget/profile_menu_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
              SizedBox(width: 10),
              Text(
                "Déconnexion",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            "Êtes-vous sûr de vouloir vous déconnecter de votre compte Galana HSSE ?",
            style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Annuler", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await ApiClient.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                }
              },
              child: const Text("Se déconnecter", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiClient.currentUser;
    final String fullName = user?['name']?.toString() ??
        ("${user?['first_name'] ?? 'Jules'} ${user?['last_name'] ?? 'ARIMANANA'}").trim();
    final String email = user?['email']?.toString() ?? "julesari_ext@galana.mg";
    final String role = user?['role']?.toString() ?? "Inspecteur HSSE";
    final String department = user?['department']?.toString() ?? "Opérations & Sûreté";
    final String function = user?['job_title']?.toString() ?? "Superviseur Terrain HSSE";
    final String phone = user?['phone']?.toString() ?? "+261 34 12 345 67";

    String initials = "GA";
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
    } else if (fullName.isNotEmpty) {
      initials = fullName[0].toUpperCase();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // ============================================
          // HEADER PROFILE BANNER
          // ============================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 24, bottom: 28, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F9D58),
                  Color(0xFF0B7A45),
                  Color(0xFF064E2A),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================
          // INFORMATIONS COLLABORATEUR
          // ============================================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "Informations professionnelles",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      ProfileInfoRow(label: "E-mail officiel", value: email),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      ProfileInfoRow(label: "Téléphone", value: phone),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      ProfileInfoRow(label: "Fonction", value: function),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      ProfileInfoRow(label: "Département", value: department),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),
                      const ProfileInfoRow(label: "Entité / Dépôt", value: "Galana Tamatave"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ============================================
                // MENU DE NAVIGATION & PARAMÈTRES
                // ============================================
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "Compte & Sécurité",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.person_outline_rounded,
                        title: "Modifier mes informations",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.editProfile);
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ProfileMenuTile(
                        icon: Icons.lock_outline_rounded,
                        title: "Changer le mot de passe",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.changePassword);
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ProfileMenuTile(
                        icon: Icons.sync_rounded,
                        title: "Gestion de la synchronisation & stockage",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // BOUTON DE DÉCONNEXION
                // ============================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2),
                      foregroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      "Déconnexion du compte",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Version
                const Center(
                  child: Text(
                    "Galana HSSE Mobile • v1.0.0 (Build 2026.10)\nGalana Madagascar",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
