import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/constants/app_version.dart';
import 'package:gestion_hsse/cores/extensions/context_extensions.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/app_settings_service.dart';
import 'package:gestion_hsse/cores/services/app_update_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/settings/widget/settings_navigation_tile.dart';
import 'package:gestion_hsse/views/home/settings/widget/settings_switch_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool darkMode;
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool biometricAuth = true;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    darkMode = AppSettingsService.instance.isDarkMode;
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

  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdate) return;

    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final info = await AppUpdateService.instance.checkForUpdates();

      if (!mounted) return;
      setState(() {
        _isCheckingUpdate = false;
      });

      if (info.isUpdateAvailable && info.currentVersion != info.latestVersion) {
        _showUpdateAvailableDialog(info);
      } else {
        _showUpToDateDialog(info);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingUpdate = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.updateError,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: context.l10n.retry,
            textColor: Colors.white,
            onPressed: _checkForUpdates,
          ),
        ),
      );
    }
  }

  void _showUpToDateDialog(AppUpdateInfo info) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF10B981),
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.appUpToDate,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.appUpToDateMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.currentVersionLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          'v${info.currentVersion}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Build',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '#${info.currentBuildNumber}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statut',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 12),
                              SizedBox(width: 4),
                              Text(
                                'À jour',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.l10n.close,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateAvailableDialog(AppUpdateInfo info) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.l10n.updateAvailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.updateAvailableMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                // Version transition banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.currentVersionLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'v${info.currentVersion}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.newVersionLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'v${info.latestVersion}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (info.changelog.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.releaseNotes,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: info.changelog.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4, right: 8),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.cloud_download_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.l10n.downloadDriveNotice,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                if (!info.forceUpdate)
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        context.l10n.updateLater,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                if (!info.forceUpdate) const SizedBox(width: 8),
                Expanded(
                  flex: info.forceUpdate ? 1 : 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final ok = await AppUpdateService.instance.launchDownload(info.downloadUrl);
                      if (!ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Impossible d'ouvrir le lien Google Drive"),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      context.l10n.updateNow,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.termsOfService),
        content: const SingleChildScrollView(
          child: Text(
            "L'utilisation de l'application GALANA HSSE est strictement réservée au personnel habilité et aux prestataires autorisés par Galana Madagascar.\n\n"
            "Toutes les données collectées (inspections, anomalies, photos, coordonnées GPS) sont la propriété exclusive de Galana Distribution & Raffinerie Madagascar.",
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.privacyPolicy),
        content: const SingleChildScrollView(
          child: Text(
            "La politique de confidentialité de Galana assure la protection des données professionnelles et de géolocalisation. "
            "Les coordonnées GPS ne sont relevées que lors de la saisie d'inspections de sécurité, audits et signalements d'urgences.",
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.contactSupport),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assistance technique et support HSSE Galana Madagascar :",
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text("support-hsse@galana.mg", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text("+261 20 22 404 00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(context.l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context.l10n.general),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  SettingsNavigationTile(
                    icon: Icons.language_rounded,
                    title: context.l10n.language,
                    value: AppSettingsService.instance.languageName,
                    onTap: _showLanguageDialog,
                  ),
                  SettingsSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: context.l10n.darkMode,
                    value: darkMode,
                    showDivider: false,
                    onChanged: (value) async {
                      await AppSettingsService.instance.setDarkMode(value);
                      setState(() {
                        darkMode = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle(context.l10n.notifications.toUpperCase()),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  SettingsSwitchTile(
                    icon: Icons.notifications_none_rounded,
                    title: context.l10n.pushNotifications,
                    value: pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        pushNotifications = value;
                      });
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.email_outlined,
                    title: context.l10n.emailNotifications,
                    value: emailNotifications,
                    showDivider: false,
                    onChanged: (value) {
                      setState(() {
                        emailNotifications = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle(context.l10n.security.toUpperCase()),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  SettingsSwitchTile(
                    icon: Icons.fingerprint_rounded,
                    title: context.l10n.biometricAuth,
                    value: biometricAuth,
                    onChanged: (value) {
                      setState(() {
                        biometricAuth = value;
                      });
                    },
                  ),
                  SettingsNavigationTile(
                    icon: Icons.shield_outlined,
                    title: "Code PIN",
                    showDivider: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle("DONNÉES & SYNCHRONISATION"),
            const SizedBox(height: 8),

            ListenableBuilder(
              listenable: SyncService.instance,
              builder: (context, _) {
                final sync = SyncService.instance;
                final count = sync.pendingCount;
                final isSyncing = sync.isSyncing;
                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      SettingsNavigationTile(
                        icon: Icons.sync_rounded,
                        title: "File des inspections hors-ligne",
                        value: isSyncing
                            ? "Synchronisation en cours..."
                            : (count > 0 ? "$count en attente" : "Toutes synchronisées"),
                        trailing: count > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "$count",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        showDivider: false,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.syncQueue);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            _sectionTitle(context.l10n.about.toUpperCase()),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Mise à jour de l'application
                  SettingsNavigationTile(
                    icon: Icons.system_update_rounded,
                    title: context.l10n.checkForUpdates,
                    value: _isCheckingUpdate ? context.l10n.checkingForUpdates : null,
                    trailing: _isCheckingUpdate
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onTap: _isCheckingUpdate ? null : _checkForUpdates,
                  ),

                  // Version de l'application
                  SettingsNavigationTile(
                    icon: Icons.info_outline_rounded,
                    title: context.l10n.version,
                    value: AppVersion.fullDisplay,
                    onTap: _isCheckingUpdate ? null : _checkForUpdates,
                  ),

                  // Conditions d'utilisation
                  SettingsNavigationTile(
                    icon: Icons.description_outlined,
                    title: context.l10n.termsOfService,
                    onTap: _showTermsDialog,
                  ),

                  // Politique de confidentialité
                  SettingsNavigationTile(
                    icon: Icons.privacy_tip_outlined,
                    title: context.l10n.privacyPolicy,
                    onTap: _showPrivacyDialog,
                  ),

                  // Support HSSE
                  SettingsNavigationTile(
                    icon: Icons.support_agent_rounded,
                    title: context.l10n.contactSupport,
                    showDivider: false,
                    onTap: _showSupportDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }
}
