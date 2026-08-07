import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/profile/widget/profile_info_row.dart';
import 'package:gestion_hsse/views/home/profile/widget/profile_menu_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // =======================
          // HEADER
          // =======================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 24, bottom: 30),

            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),

            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(radius: 42, child: Icon(Icons.person)),

                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  "Jules Rakoto",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Inspecteur HSSE",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // =======================
          // INFOS
          // =======================
          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Column(
                    children: [
                      ProfileInfoRow(
                        label: "E-mail",
                        value: "jules.rakoto@galana.mg",
                      ),

                      SizedBox(height: 14),

                      ProfileInfoRow(
                        label: "Téléphone",
                        value: "+261 34 12 345 67",
                      ),

                      SizedBox(height: 14),

                      ProfileInfoRow(
                        label: "Fonction",
                        value: "Superviseur terrain",
                      ),

                      SizedBox(height: 14),

                      ProfileInfoRow(label: "Département", value: "Opérations"),

                      SizedBox(height: 14),

                      ProfileInfoRow(label: "Rôle", value: "Inspecteur"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =======================
                // MENU
                // =======================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.person_outline,
                        title: "Modifier le profil",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.editProfile);
                        },
                      ),

                      Divider(height: 1, color: Colors.grey.shade200),

                      ProfileMenuTile(
                        icon: Icons.lock_outline,
                        title: "Changer le mot de passe",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.changePassword);
                        },
                      ),

                      Divider(height: 1, color: Colors.grey.shade200),

                      ProfileMenuTile(
                        icon: Icons.settings_outlined,
                        title: "Paramètres",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =======================
                // LOGOUT
                // =======================
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE2E2),

                      foregroundColor: const Color(0xFFEF4444),

                      elevation: 0,
                    ),

                    onPressed: () {},

                    child: const Text(
                      "Déconnexion",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
