import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class UserLocationService {
  static StreamSubscription<Position>? _positionSubscription;
  static Position? _lastKnownPosition;

  static Position? get lastKnownPosition => _lastKnownPosition;

  /// Vérifie et demande les autorisations de géolocalisation
  static Future<bool> requestPermission(BuildContext? context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Veuillez activer le service de localisation (GPS) sur votre appareil.",
            ),
            action: SnackBarAction(
              label: "Paramètres",
              onPressed: () => Geolocator.openLocationSettings(),
            ),
            backgroundColor: const Color(0xFFD97706),
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("L'autorisation de géolocalisation a été refusée."),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "L'autorisation GPS est définitivement refusée. Veuillez l'activer dans les paramètres.",
            ),
            action: SnackBarAction(
              label: "Paramètres",
              onPressed: () => Geolocator.openAppSettings(),
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Obtient la position actuelle de manière ponctuelle
  static Future<Position?> getCurrentPosition({BuildContext? context}) async {
    final hasPermission = await requestPermission(context);
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastKnownPosition = position;
      return position;
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          _lastKnownPosition = last;
          return last;
        }
      } catch (_) {}
      return null;
    }
  }

  /// Écoute les changements de position en temps réel
  static Stream<Position> getPositionStream({
    int distanceFilterMeters = 3,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Convertit une Position Geolocator en LatLng (latlong2)
  static LatLng toLatLng(Position pos) {
    return LatLng(pos.latitude, pos.longitude);
  }

  /// Arrête tout abonnement actif
  static void cancelSubscription() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
