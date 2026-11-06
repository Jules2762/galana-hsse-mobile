import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/extensions/context_extensions.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/app_settings_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/profile/widget/profile_info_row.dart';
import 'package:gestion_hsse/views/home/profile/widget/profile_menu_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final updated = await ApiClient.fetchCurrentUser();
    if (updated != null && mounted) {
      setState(() {});
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
              const SizedBox(width: 10),
              Text(
                context.l10n.logout,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            context.l10n.logoutConfirm,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.l10n.cancel, style: const TextStyle(color: Color(0xFF64748B))),
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
              child: Text(context.l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.language_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                context.l10n.selectLanguage,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppSettingsService.supportedLanguages.entries.map((entry) {
              final isSelected = AppSettingsService.instance.currentLanguage == entry.key;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
                title: Text(
                  entry.value,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
                    : null,
                onTap: () async {
                  await AppSettingsService.instance.setLanguage(entry.key);
                  if (mounted) setState(() {});
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final sectionTitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF0F172A);

    final user = ApiClient.currentUser;
    final String fullName = ApiClient.currentUserName;
    final String email = user?['email']?.toString() ?? "";
    final String role = user?['role']?.toString() ?? "Inspecteur HSSE";
    final String department = user?['department']?.toString() ?? "Opérations & Dépôt";
    final String function = user?['job_title']?.toString() ?? (user?['job']?.toString() ?? "Inspecteur HSSE");

    // Extraction robuste du numéro de téléphone depuis plusieurs clés possibles
    final String rawPhone = user?['phone_number']?.toString() ??
        (user?['phone']?.toString() ?? (user?['telephone']?.toString() ?? ""));
    final String phone = rawPhone.trim().isNotEmpty ? rawPhone.trim() : "Non renseigné";

    String initials = "GA";
    final parts = fullName.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
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
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    context.l10n.professionalInfo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: sectionTitleColor,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      ProfileInfoRow(label: context.l10n.officialEmail, value: email),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: borderColor),
                      const SizedBox(height: 12),
                      ProfileInfoRow(
                        label: context.l10n.phone,
                        value: phone,
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: borderColor),
                      const SizedBox(height: 12),
                      ProfileInfoRow(label: context.l10n.jobFunction, value: function),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: borderColor),
                      const SizedBox(height: 12),
                      ProfileInfoRow(label: context.l10n.department, value: department),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: borderColor),
                      const SizedBox(height: 12),
                      ProfileInfoRow(label: context.l10n.entityOrDepot, value: "Galana Madagascar"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ============================================
                // MENU DE NAVIGATION & PARAMÈTRES
                // ============================================
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    context.l10n.accountAndPreferences,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: sectionTitleColor,
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.person_outline_rounded,
                        title: context.l10n.editMyInfo,
                        onTap: () async {
                          await Navigator.pushNamed(context, AppRoutes.editProfile);
                          _loadProfile();
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      ProfileMenuTile(
                        icon: Icons.language_rounded,
                        title: "${context.l10n.language} (${AppSettingsService.instance.languageName})",
                        onTap: _showLanguageDialog,
                      ),
                      Divider(height: 1, color: borderColor),
                      ProfileMenuTile(
                        icon: Icons.settings_outlined,
                        title: context.l10n.settings,
                        onTap: () async {
                          await Navigator.pushNamed(context, AppRoutes.settings);
                          if (mounted) setState(() {});
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      ProfileMenuTile(
                        icon: Icons.lock_outline_rounded,
                        title: context.l10n.changePassword,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.changePassword);
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
                      backgroundColor: isDark
                          ? const Color(0xFF7F1D1D).withValues(alpha: 0.25)
                          : const Color(0xFFFEF2F2),
                      foregroundColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                      elevation: 0,
                      side: BorderSide(
                        color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(
                      context.l10n.logout,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Version
                const Center(
                  child: Text(
                    "Galana HSSE Mobile • v1.0.0 (Build 2026.10)\nGalana Distribution Madagascar",
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
