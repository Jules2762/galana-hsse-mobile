import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/app_settings_service.dart';
import 'package:gestion_hsse/cores/services/onesignal_service.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_theme.dart';
import 'package:gestion_hsse/l10n/app_localizations.dart';
import 'cores/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignalService.navigatorKey = MainApp.navigatorKey;
  await OneSignalService.instance.init();
  await ApiClient.init();
  await SyncService.instance.init();
  await AppSettingsService.instance.init();

  // Écoute des déconnexions forcées (compte désactivé ou session expirée)
  ApiClient.onSessionExpired = (bool isAccountDisabled) {
    final nav = MainApp.navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      final ctx = MainApp.navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).clearSnackBars();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAccountDisabled
                        ? 'Votre compte a été désactivé par un administrateur.'
                        : 'Votre session a expiré. Veuillez vous reconnecter.',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  };

  RealtimeService.instance.start();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService.instance,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: AppSettingsService.instance.themeMode,
          locale: AppSettingsService.instance.currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: AppRoutes.login,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
