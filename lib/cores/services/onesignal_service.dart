import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  OneSignalService._();
  static final OneSignalService instance = OneSignalService._();

  // OneSignal App ID
  static const String defaultAppId = '0b20e85e-e894-4e36-a1db-8043782a4dc7';

  /// Référence globale pour la navigation lors du clic sur une notification
  static GlobalKey<NavigatorState>? navigatorKey;

  bool _isInitialized = false;

  /// Initialise OneSignal si l'ID d'application est configuré
  Future<void> init([String? appId]) async {
    final id = appId ?? defaultAppId;

    if (id.isEmpty || id == 'VOTRE_ONESIGNAL_APP_ID') {
      debugPrint('[OneSignalService] OneSignal App ID non renseigné. Notifications push système en attente de configuration.');
      return;
    }

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      } else {
        OneSignal.Debug.setLogLevel(OSLogLevel.none);
      }

      OneSignal.initialize(id);

      // Demande de permission notification (Android 13+ & iOS)
      await OneSignal.Notifications.requestPermission(true);

      _isInitialized = true;
      debugPrint('[OneSignalService] OneSignal initialisé avec succès.');

      // Écouteur de clic sur notification
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('[OneSignalService] Notification cliquée: ${event.notification.title}');
        final data = event.notification.additionalData;
        if (data != null) {
          debugPrint('[OneSignalService] Données additionnelles: $data');
          final type = data['type']?.toString().toUpperCase();
          final link = data['link']?.toString();
          final nav = navigatorKey?.currentState;

          if (nav != null) {
            if (type == 'UPDATE' || link == '/settings') {
              nav.pushNamed(AppRoutes.settings);
            } else if (type == 'INSPECTION' || type == 'CHECKLIST' || type == 'VMC' || type == 'EQUIPMENT') {
              nav.pushNamed(AppRoutes.inspections);
            }
          }
        }
      });
    } catch (e) {
      debugPrint('[OneSignalService] Erreur lors de l\'initialisation: $e');
    }
  }

  /// Associe l'appareil au compte de l'utilisateur connecté sur Laravel
  Future<void> login(dynamic userId) async {
    if (!_isInitialized || userId == null) return;
    try {
      final userExternalId = userId.toString();
      await OneSignal.login(userExternalId);
      debugPrint('[OneSignalService] Utilisateur OneSignal associé: $userExternalId');
    } catch (e) {
      debugPrint('[OneSignalService] Erreur lors de l\'association utilisateur: $e');
    }
  }

  /// Dissocie l'appareil lors de la déconnexion
  Future<void> logout() async {
    if (!_isInitialized) return;
    try {
      await OneSignal.logout();
      debugPrint('[OneSignalService] Utilisateur OneSignal déconnecté.');
    } catch (e) {
      debugPrint('[OneSignalService] Erreur lors de la déconnexion OneSignal: $e');
    }
  }
}
