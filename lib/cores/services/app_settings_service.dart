import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends ChangeNotifier {
  static final AppSettingsService instance = AppSettingsService._();
  AppSettingsService._();

  static const String _keyDarkMode = 'app_dark_mode';
  static const String _keyLanguage = 'app_language';

  bool _isDarkMode = false;
  String _currentLanguage = 'fr'; // 'fr' ou 'en'

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  String get currentLanguage => _currentLanguage;
  Locale get currentLocale => Locale(_currentLanguage);

  String get languageName {
    switch (_currentLanguage) {
      case 'en':
        return 'English';
      case 'fr':
      default:
        return 'Français';
    }
  }

  static const Map<String, String> supportedLanguages = {
    'fr': 'Français',
    'en': 'English',
  };

  /// Initialisation depuis SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
      final savedLang = prefs.getString(_keyLanguage) ?? 'fr';
      _currentLanguage = (savedLang == 'en') ? 'en' : 'fr';
      notifyListeners();
    } catch (_) {}
  }

  /// Basculer ou définir le mode sombre
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, _isDarkMode);
    } catch (_) {}
  }

  /// Changer la langue (uniquement 'fr' ou 'en')
  Future<void> setLanguage(String langCode) async {
    final targetLang = (langCode == 'en') ? 'en' : 'fr';
    if (_currentLanguage == targetLang) return;
    _currentLanguage = targetLang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, _currentLanguage);
    } catch (_) {}
  }

  /// Dictionnaire de traductions simples
  static final Map<String, Map<String, String>> _translations = {
    // Général & Navigation
    'settings': {
      'fr': 'Paramètres',
      'en': 'Settings',
    },
    'language': {
      'fr': 'Langue',
      'en': 'Language',
    },
    'dark_mode': {
      'fr': 'Mode sombre',
      'en': 'Dark mode',
    },
    'notifications': {
      'fr': 'Notifications',
      'en': 'Notifications',
    },
    'security': {
      'fr': 'Sécurité',
      'en': 'Security',
    },
    'profile': {
      'fr': 'Profil',
      'en': 'Profile',
    },
    'logout': {
      'fr': 'Déconnexion',
      'en': 'Logout',
    },
    'cancel': {
      'fr': 'Annuler',
      'en': 'Cancel',
    },
    'save': {
      'fr': 'Enregistrer',
      'en': 'Save',
    },
    'confirm': {
      'fr': 'Confirmer',
      'en': 'Confirm',
    },
    // Modules HSSE
    'inspections': {
      'fr': 'Inspections & Contrôles',
      'en': 'Inspections & Audits',
    },
    'equipment_monitoring': {
      'fr': 'Suivi matériel',
      'en': 'Equipment monitoring',
    },
    'emergency_contacts': {
      'fr': 'Contacts d\'urgence',
      'en': 'Emergency contacts',
    },
    'actions': {
      'fr': 'Actions correctives',
      'en': 'Corrective actions',
    },
    'reports': {
      'fr': 'Rapports & PV',
      'en': 'Reports',
    },
    'planned': {
      'fr': 'Planifiée',
      'en': 'Planned',
    },
    'in_progress': {
      'fr': 'En cours',
      'en': 'In progress',
    },
    'completed': {
      'fr': 'Clôturée',
      'en': 'Completed',
    },
    'conforme': {
      'fr': 'Conforme',
      'en': 'Compliant',
    },
    'non_conforme': {
      'fr': 'Non conforme',
      'en': 'Non-compliant',
    },
    'phone': {
      'fr': 'Téléphone',
      'en': 'Phone',
    },
  };

  /// Obtenir la traduction d'une clé selon la langue active
  String t(String key) {
    final entry = _translations[key];
    if (entry == null) return key;
    return entry[_currentLanguage] ?? entry['fr'] ?? key;
  }

  /// Raccourci statique
  static String tr(String key) => instance.t(key);
}
