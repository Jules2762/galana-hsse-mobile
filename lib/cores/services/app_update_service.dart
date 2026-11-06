import 'package:dio/dio.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/constants/app_version.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final String latestVersion;
  final int buildNumber;
  final String downloadUrl;
  final String releaseDate;
  final String minSupportedVersion;
  final bool forceUpdate;
  final List<String> changelog;
  final bool isUpdateAvailable;
  final String currentVersion;
  final int currentBuildNumber;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.buildNumber,
    required this.downloadUrl,
    required this.releaseDate,
    required this.minSupportedVersion,
    required this.forceUpdate,
    required this.changelog,
    required this.isUpdateAvailable,
    required this.currentVersion,
    required this.currentBuildNumber,
  });

  String get latestFullDisplay => '$latestVersion (Build $buildNumber)';
}

class AppUpdateService {
  static final AppUpdateService instance = AppUpdateService._();
  AppUpdateService._();

  /// Vérifie la présence d'une nouvelle version sur l'API backend
  Future<AppUpdateInfo> checkForUpdates() async {
    try {
      final response = await ApiClient.dio.get(
        '/app/version',
        queryParameters: {
          'current_version': AppVersion.currentVersion,
          'build_number': AppVersion.currentBuildNumber,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> body = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {};
        final data = body['data'] as Map<String, dynamic>? ?? {};

        final serverVersion = (data['latest_version'] ?? AppVersion.currentVersion).toString().trim();
        final serverBuildNumber = int.tryParse(data['build_number']?.toString() ?? '') ?? AppVersion.currentBuildNumber;
        final downloadUrl = (data['download_url'] ?? '').toString().trim();
        final releaseDate = (data['release_date'] ?? AppVersion.releaseDate).toString().trim();
        final minSupportedVersion = (data['min_supported_version'] ?? '1.0.0').toString().trim();
        final forceUpdate = data['force_update'] == true;

        final rawChangelog = data['changelog'];
        final List<String> changelog = [];
        if (rawChangelog is List) {
          for (final item in rawChangelog) {
            changelog.add(item.toString());
          }
        }

        // Comparaison sémantique stricte des versions (ex: 2.1.2 > 2.1.1)
        final versionDiff = compareSemanticVersions(serverVersion, AppVersion.currentVersion);

        // Une mise à jour est disponible si et seulement si la version du serveur est STRICTEMENT supérieure
        final isUpdateAvailable = versionDiff > 0;

        return AppUpdateInfo(
          latestVersion: serverVersion,
          buildNumber: serverBuildNumber,
          downloadUrl: downloadUrl,
          releaseDate: releaseDate,
          minSupportedVersion: minSupportedVersion,
          forceUpdate: forceUpdate,
          changelog: changelog,
          isUpdateAvailable: isUpdateAvailable,
          currentVersion: AppVersion.currentVersion,
          currentBuildNumber: AppVersion.currentBuildNumber,
        );
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      rethrow;
    }
  }

  /// Compare deux versions sémantiques (ex: "2.1.2" vs "2.1.1").
  /// Retourne :
  ///  > 0 si v1 > v2 (v1 plus récente)
  ///  < 0 si v1 < v2 (v1 plus ancienne)
  ///  = 0 si v1 == v2 (versions identiques)
  static int compareSemanticVersions(String v1, String v2) {
    List<int> parse(String v) {
      final clean = v.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first.split('-').first;
      return clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    }

    final p1 = parse(v1);
    final p2 = parse(v2);
    final maxLen = p1.length > p2.length ? p1.length : p2.length;

    for (int i = 0; i < maxLen; i++) {
      final num1 = i < p1.length ? p1[i] : 0;
      final num2 = i < p2.length ? p2[i] : 0;
      if (num1 != num2) {
        return num1.compareTo(num2);
      }
    }
    return 0;
  }

  /// Ouvre l'URL de téléchargement (Google Drive APK) dans le navigateur ou application externe
  Future<bool> launchDownload(String downloadUrl) async {
    final trimmed = downloadUrl.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
    } catch (_) {
      try {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }
  }
}
