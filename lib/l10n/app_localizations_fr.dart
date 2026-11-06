// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GESTION HSSE';

  @override
  String get home => 'Accueil';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get inspections => 'Inspections';

  @override
  String get reports => 'Rapports';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get emergency => 'Urgences';

  @override
  String get sos => 'SOS';

  @override
  String get online => 'EN LIGNE';

  @override
  String get offline => 'HORS-LIGNE';

  @override
  String get syncing => 'SYNCHRO...';

  @override
  String get pendingSync => 'EN ATTENTE';

  @override
  String get pressBackAgainToExit => 'Appuyez de nouveau pour quitter';

  @override
  String get login => 'Connexion';

  @override
  String get loginTitle => 'Portail Sécurisé HSSE';

  @override
  String get loginSubtitle => 'Système Intégré d\'Inspections & Audits Terrain';

  @override
  String get professionalId => 'Identifiant professionnel';

  @override
  String get password => 'Mot de passe';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get loginError => 'Identifiant ou mot de passe incorrect.';

  @override
  String get emptyCredentials =>
      'Veuillez renseigner votre email et mot de passe.';

  @override
  String get connectionError =>
      'Impossible de se connecter au serveur. Vérifiez votre connexion.';

  @override
  String get serverConfig => 'Configuration Serveur & Réseau';

  @override
  String get serverUrl => 'Adresse URL de l\'API Serveur';

  @override
  String get saveServer => 'Enregistrer & Tester';

  @override
  String get allRightsReserved => 'Galana Madagascar • Tous droits réservés';

  @override
  String get helloUser => 'Bonjour';

  @override
  String get connectedServerRealtime =>
      'Connecté au serveur • Synchronisation temps réel';

  @override
  String offlinePendingInspections(int count) {
    return 'Mode Hors-ligne • $count inspection(s) en attente';
  }

  @override
  String offlinePendingBanner(int count) {
    return '$count inspection(s) effectuée(s) hors-ligne. Envoi automatique dès reconnexion.';
  }

  @override
  String get sendNow => 'Envoyer';

  @override
  String get inProgress => 'En cours';

  @override
  String get galanaPillars => 'Piliers d\'Inspection Galana';

  @override
  String get visits => 'visites';

  @override
  String get sheets => 'fiches';

  @override
  String get trackings => 'suivis';

  @override
  String get alerts => 'Alertes';

  @override
  String get inspectionsMap => 'Carte des Inspections';

  @override
  String get inspectionsMapSubtitle =>
      'Voir VMC, Checklists & Matériel sur la carte';

  @override
  String get emergencyBannerTitle => 'Contacts d\'Urgence & Secours';

  @override
  String get emergencyBannerSubtitle =>
      'Pompiers 118 • SAMU 124 • Police 117 • Gendarmerie 119';

  @override
  String get complianceRate => 'Taux de conformité';

  @override
  String get deviationsFound => 'Écarts relevés';

  @override
  String get totalActions => 'Total actions';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get recentActivities => 'Activités récentes';

  @override
  String get vmc => 'VMC';

  @override
  String get checklists => 'Checklists';

  @override
  String get equipment => 'Matériel';

  @override
  String get equipmentMonitoring => 'Suivi Matériel';

  @override
  String get listView => 'Liste';

  @override
  String get mapView => 'Carte';

  @override
  String get all => 'Tous';

  @override
  String get allFemale => 'Toutes';

  @override
  String get completed => 'Terminée';

  @override
  String get planned => 'Planifiée';

  @override
  String get closed => 'Clôturée';

  @override
  String get cancelled => 'Annulée';

  @override
  String get validated => 'Validée';

  @override
  String get rejected => 'Rejetée';

  @override
  String get assignedToMe => 'Assignées à moi';

  @override
  String get noChecklistsFound => 'Aucune checklist trouvée';

  @override
  String get noVmcsFound => 'Aucune visite VMC trouvée';

  @override
  String get noEquipmentsFound => 'Aucun équipement trouvé';

  @override
  String get searchChecklist => 'Rechercher une checklist, un site...';

  @override
  String get searchVmc => 'Rechercher une visite VMC, un site...';

  @override
  String get searchEquipment => 'Rechercher un équipement, code...';

  @override
  String get newInspection => 'Nouvelle Inspection';

  @override
  String get newVmc => 'Nouvelle VMC';

  @override
  String get newEquipmentCheck => 'Nouveau Contrôle';

  @override
  String get details => 'Détails';

  @override
  String get site => 'Site / Dépôt';

  @override
  String get inspector => 'Inspecteur';

  @override
  String get date => 'Date';

  @override
  String get status => 'Statut';

  @override
  String get progress => 'Progression';

  @override
  String get sections => 'Sections';

  @override
  String get questions => 'Questions';

  @override
  String get conform => 'Conforme';

  @override
  String get nonConform => 'Non conforme';

  @override
  String get na => 'Non applicable';

  @override
  String get comments => 'Commentaires';

  @override
  String get addComment => 'Ajouter un commentaire...';

  @override
  String get attachments => 'Pièces jointes';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get validateInspection => 'Valider et signer';

  @override
  String get closeInspection => 'Clôturer le contrôle';

  @override
  String get confirmClose =>
      'Êtes-vous sûr de vouloir clôturer cette inspection ?';

  @override
  String get inspectionClosedSuccess => 'Contrôle clôturé avec succès';

  @override
  String get correctiveActions => 'Actions correctives';

  @override
  String get addAction => 'Ajouter une action';

  @override
  String get actionTitle => 'Titre de l\'action';

  @override
  String get actionDescription => 'Description';

  @override
  String get actionPriority => 'Priorité';

  @override
  String get actionDueDate => 'Échéance';

  @override
  String get actionAssignee => 'Responsable';

  @override
  String get lowPriority => 'Faible';

  @override
  String get mediumPriority => 'Moyenne';

  @override
  String get highPriority => 'Haute';

  @override
  String get criticalPriority => 'Critique';

  @override
  String get emergencyContacts => 'Contacts d\'urgence';

  @override
  String get allEmergencyContacts => 'Tous les contacts';

  @override
  String get firefighters => 'Pompiers';

  @override
  String get hospitals => 'Hôpitaux';

  @override
  String get ambulances => 'SAMU / Ambulances';

  @override
  String get police => 'Police';

  @override
  String get gendarmerie => 'Gendarmerie';

  @override
  String get searchEmergency =>
      'Rechercher un service, une ville, une région...';

  @override
  String get call => 'Appeler';

  @override
  String get directions => 'Itinéraire';

  @override
  String get speedDials => 'Numéros rapides nationaux';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get allNotificationsRead =>
      'Toutes les notifications sont marquées comme lues.';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get reportsAndMinutes => 'Rapports & PV';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get allCategories => 'Toutes';

  @override
  String get safetyCategory => 'Sécurité';

  @override
  String get environmentCategory => 'Environnement';

  @override
  String get operationsCategory => 'Opérations';

  @override
  String get auditCategory => 'Audit';

  @override
  String get securityCategory => 'Sûreté';

  @override
  String get averageConformity => 'Conformité moyenne';

  @override
  String get totalNonConformities => 'Non-conformités';

  @override
  String get downloadPdf => 'Télécharger le PDF';

  @override
  String get shareReport => 'Partager le rapport';

  @override
  String get professionalInfo => 'Informations professionnelles';

  @override
  String get officialEmail => 'E-mail officiel';

  @override
  String get phone => 'Numéro de téléphone';

  @override
  String get jobFunction => 'Fonction';

  @override
  String get department => 'Département';

  @override
  String get entityOrDepot => 'Entité / Dépôt';

  @override
  String get notSpecified => 'Non renseigné';

  @override
  String get accountAndPreferences => 'Compte & Préférences';

  @override
  String get editMyInfo => 'Modifier mes informations';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get fullName => 'Nom complet';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get profileSaved => 'Profil mis à jour avec succès';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get success => 'Succès';

  @override
  String get error => 'Erreur';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get darkModeSubtitle => 'Activer le thème sombre pour l\'application';

  @override
  String get language => 'Langue';

  @override
  String get languageSubtitle => 'Choisir la langue de l\'application';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get emailNotifications => 'E-mail de rappel';

  @override
  String get biometricAuth => 'Authentification biométrique';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get general => 'GÉNÉRAL';

  @override
  String get security => 'SÉCURITÉ';

  @override
  String get appUpdates => 'Mises à jour';

  @override
  String get checkForUpdates => 'Vérifier les mises à jour';

  @override
  String get checkingForUpdates => 'Recherche de mise à jour...';

  @override
  String get appUpToDate => 'Application à jour';

  @override
  String get appUpToDateMessage =>
      'Votre application est à jour. Vous disposez de la version la plus récente.';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String get updateAvailableMessage =>
      'Une nouvelle version de l\'application est disponible au téléchargement.';

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateError =>
      'Impossible de vérifier les mises à jour. Vérifiez votre connexion.';

  @override
  String get currentVersionLabel => 'Version actuelle';

  @override
  String get newVersionLabel => 'Nouvelle version';

  @override
  String get releaseNotes => 'Nouveautés';

  @override
  String get downloadDriveNotice =>
      'Le téléchargement du fichier APK débutera via Google Drive.';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get contactSupport => 'Contacter le support HSSE';
}
