import 'package:flutter/material.dart';

import 'package:gestion_hsse/views/home/settings/widget/settings_navigation_tile.dart';
import 'package:gestion_hsse/views/home/settings/widget/settings_switch_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool biometricAuth = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("Paramètres"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _sectionTitle("GÉNÉRAL"),

            const SizedBox(height: 8),

            SettingsNavigationTile(
              icon: Icons.language,
              title: "Langue",
              value: "Français",
              onTap: () {},
            ),

            SettingsSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: "Mode sombre",
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
              },
            ),

            const SizedBox(height: 24),

            _sectionTitle("NOTIFICATIONS"),

            const SizedBox(height: 8),

            SettingsSwitchTile(
              icon: Icons.notifications_none,
              title: "Notifications push",
              value: pushNotifications,
              onChanged: (value) {
                setState(() {
                  pushNotifications = value;
                });
              },
            ),

            SettingsSwitchTile(
              icon: Icons.email_outlined,
              title: "E-mail de rappel",
              value: emailNotifications,
              onChanged: (value) {
                setState(() {
                  emailNotifications = value;
                });
              },
            ),

            const SizedBox(height: 24),

            _sectionTitle("SÉCURITÉ"),

            const SizedBox(height: 8),

            SettingsSwitchTile(
              icon: Icons.fingerprint,
              title: "Authentification biométrique",
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
              onTap: () {},
            ),

            const SizedBox(height: 24),

            _sectionTitle("À PROPOS"),

            const SizedBox(height: 8),

            const SettingsNavigationTile(
              icon: Icons.info_outline,
              title: "Version",
              value: "2.1.0",
            ),

            SettingsNavigationTile(
              icon: Icons.description_outlined,
              title: "Conditions d'utilisation",
              onTap: () {},
            ),

            SettingsNavigationTile(
              icon: Icons.privacy_tip_outlined,
              title: "Politique de confidentialité",
              onTap: () {},
            ),

            SettingsNavigationTile(
              icon: Icons.support_agent_outlined,
              title: "Contacter le support",
              onTap: () {},
            ),

            const SizedBox(height: 100),
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
