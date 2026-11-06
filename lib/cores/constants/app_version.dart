class AppVersion {
  /// Version sémantique de l'application
  static const String currentVersion = '2.1.2';

  /// Numéro de build interne (ex: AAAAMMJJ)
  static const int currentBuildNumber = 20261032;

  /// Date de mise en production de cette version
  static const String releaseDate = '30/10/2026';

  /// Libellé complet affiché dans les paramètres
  static String get fullDisplay => '$currentVersion (Build $currentBuildNumber)';
}
