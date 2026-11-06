import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'GESTION HSSE'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @inspections.
  ///
  /// In fr, this message translates to:
  /// **'Inspections'**
  String get inspections;

  /// No description provided for @reports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get reports;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @emergency.
  ///
  /// In fr, this message translates to:
  /// **'Urgences'**
  String get emergency;

  /// No description provided for @sos.
  ///
  /// In fr, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @online.
  ///
  /// In fr, this message translates to:
  /// **'EN LIGNE'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In fr, this message translates to:
  /// **'HORS-LIGNE'**
  String get offline;

  /// No description provided for @syncing.
  ///
  /// In fr, this message translates to:
  /// **'SYNCHRO...'**
  String get syncing;

  /// No description provided for @pendingSync.
  ///
  /// In fr, this message translates to:
  /// **'EN ATTENTE'**
  String get pendingSync;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez de nouveau pour quitter'**
  String get pressBackAgainToExit;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Portail Sécurisé HSSE'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Système Intégré d\'Inspections & Audits Terrain'**
  String get loginSubtitle;

  /// No description provided for @professionalId.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant professionnel'**
  String get professionalId;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In fr, this message translates to:
  /// **'Se souvenir de moi'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signInButton;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe incorrect.'**
  String get loginError;

  /// No description provided for @emptyCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez renseigner votre email et mot de passe.'**
  String get emptyCredentials;

  /// No description provided for @connectionError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de se connecter au serveur. Vérifiez votre connexion.'**
  String get connectionError;

  /// No description provided for @serverConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration Serveur & Réseau'**
  String get serverConfig;

  /// No description provided for @serverUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse URL de l\'API Serveur'**
  String get serverUrl;

  /// No description provided for @saveServer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer & Tester'**
  String get saveServer;

  /// No description provided for @allRightsReserved.
  ///
  /// In fr, this message translates to:
  /// **'Galana Madagascar • Tous droits réservés'**
  String get allRightsReserved;

  /// No description provided for @helloUser.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get helloUser;

  /// No description provided for @connectedServerRealtime.
  ///
  /// In fr, this message translates to:
  /// **'Connecté au serveur • Synchronisation temps réel'**
  String get connectedServerRealtime;

  /// No description provided for @offlinePendingInspections.
  ///
  /// In fr, this message translates to:
  /// **'Mode Hors-ligne • {count} inspection(s) en attente'**
  String offlinePendingInspections(int count);

  /// No description provided for @offlinePendingBanner.
  ///
  /// In fr, this message translates to:
  /// **'{count} inspection(s) effectuée(s) hors-ligne. Envoi automatique dès reconnexion.'**
  String offlinePendingBanner(int count);

  /// No description provided for @sendNow.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get sendNow;

  /// No description provided for @inProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgress;

  /// No description provided for @galanaPillars.
  ///
  /// In fr, this message translates to:
  /// **'Piliers d\'Inspection Galana'**
  String get galanaPillars;

  /// No description provided for @visits.
  ///
  /// In fr, this message translates to:
  /// **'visites'**
  String get visits;

  /// No description provided for @sheets.
  ///
  /// In fr, this message translates to:
  /// **'fiches'**
  String get sheets;

  /// No description provided for @trackings.
  ///
  /// In fr, this message translates to:
  /// **'suivis'**
  String get trackings;

  /// No description provided for @alerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alerts;

  /// No description provided for @inspectionsMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte des Inspections'**
  String get inspectionsMap;

  /// No description provided for @inspectionsMapSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Voir VMC, Checklists & Matériel sur la carte'**
  String get inspectionsMapSubtitle;

  /// No description provided for @emergencyBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts d\'Urgence & Secours'**
  String get emergencyBannerTitle;

  /// No description provided for @emergencyBannerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pompiers 118 • SAMU 124 • Police 117 • Gendarmerie 119'**
  String get emergencyBannerSubtitle;

  /// No description provided for @complianceRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de conformité'**
  String get complianceRate;

  /// No description provided for @deviationsFound.
  ///
  /// In fr, this message translates to:
  /// **'Écarts relevés'**
  String get deviationsFound;

  /// No description provided for @totalActions.
  ///
  /// In fr, this message translates to:
  /// **'Total actions'**
  String get totalActions;

  /// No description provided for @quickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quickActions;

  /// No description provided for @recentActivities.
  ///
  /// In fr, this message translates to:
  /// **'Activités récentes'**
  String get recentActivities;

  /// No description provided for @vmc.
  ///
  /// In fr, this message translates to:
  /// **'VMC'**
  String get vmc;

  /// No description provided for @checklists.
  ///
  /// In fr, this message translates to:
  /// **'Checklists'**
  String get checklists;

  /// No description provided for @equipment.
  ///
  /// In fr, this message translates to:
  /// **'Matériel'**
  String get equipment;

  /// No description provided for @equipmentMonitoring.
  ///
  /// In fr, this message translates to:
  /// **'Suivi Matériel'**
  String get equipmentMonitoring;

  /// No description provided for @listView.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get listView;

  /// No description provided for @mapView.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get mapView;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all;

  /// No description provided for @allFemale.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get allFemale;

  /// No description provided for @completed.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get completed;

  /// No description provided for @planned.
  ///
  /// In fr, this message translates to:
  /// **'Planifiée'**
  String get planned;

  /// No description provided for @closed.
  ///
  /// In fr, this message translates to:
  /// **'Clôturée'**
  String get closed;

  /// No description provided for @cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get cancelled;

  /// No description provided for @validated.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get validated;

  /// No description provided for @rejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejetée'**
  String get rejected;

  /// No description provided for @assignedToMe.
  ///
  /// In fr, this message translates to:
  /// **'Assignées à moi'**
  String get assignedToMe;

  /// No description provided for @noChecklistsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune checklist trouvée'**
  String get noChecklistsFound;

  /// No description provided for @noVmcsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune visite VMC trouvée'**
  String get noVmcsFound;

  /// No description provided for @noEquipmentsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun équipement trouvé'**
  String get noEquipmentsFound;

  /// No description provided for @searchChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une checklist, un site...'**
  String get searchChecklist;

  /// No description provided for @searchVmc.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une visite VMC, un site...'**
  String get searchVmc;

  /// No description provided for @searchEquipment.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un équipement, code...'**
  String get searchEquipment;

  /// No description provided for @newInspection.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Inspection'**
  String get newInspection;

  /// No description provided for @newVmc.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle VMC'**
  String get newVmc;

  /// No description provided for @newEquipmentCheck.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Contrôle'**
  String get newEquipmentCheck;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @site.
  ///
  /// In fr, this message translates to:
  /// **'Site / Dépôt'**
  String get site;

  /// No description provided for @inspector.
  ///
  /// In fr, this message translates to:
  /// **'Inspecteur'**
  String get inspector;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @progress.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get progress;

  /// No description provided for @sections.
  ///
  /// In fr, this message translates to:
  /// **'Sections'**
  String get sections;

  /// No description provided for @questions.
  ///
  /// In fr, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @conform.
  ///
  /// In fr, this message translates to:
  /// **'Conforme'**
  String get conform;

  /// No description provided for @nonConform.
  ///
  /// In fr, this message translates to:
  /// **'Non conforme'**
  String get nonConform;

  /// No description provided for @na.
  ///
  /// In fr, this message translates to:
  /// **'Non applicable'**
  String get na;

  /// No description provided for @comments.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get comments;

  /// No description provided for @addComment.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un commentaire...'**
  String get addComment;

  /// No description provided for @attachments.
  ///
  /// In fr, this message translates to:
  /// **'Pièces jointes'**
  String get attachments;

  /// No description provided for @addPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir depuis la galerie'**
  String get chooseFromGallery;

  /// No description provided for @validateInspection.
  ///
  /// In fr, this message translates to:
  /// **'Valider et signer'**
  String get validateInspection;

  /// No description provided for @closeInspection.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer le contrôle'**
  String get closeInspection;

  /// No description provided for @confirmClose.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir clôturer cette inspection ?'**
  String get confirmClose;

  /// No description provided for @inspectionClosedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle clôturé avec succès'**
  String get inspectionClosedSuccess;

  /// No description provided for @correctiveActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions correctives'**
  String get correctiveActions;

  /// No description provided for @addAction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une action'**
  String get addAction;

  /// No description provided for @actionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre de l\'action'**
  String get actionTitle;

  /// No description provided for @actionDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get actionDescription;

  /// No description provided for @actionPriority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get actionPriority;

  /// No description provided for @actionDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get actionDueDate;

  /// No description provided for @actionAssignee.
  ///
  /// In fr, this message translates to:
  /// **'Responsable'**
  String get actionAssignee;

  /// No description provided for @lowPriority.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get lowPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get mediumPriority;

  /// No description provided for @highPriority.
  ///
  /// In fr, this message translates to:
  /// **'Haute'**
  String get highPriority;

  /// No description provided for @criticalPriority.
  ///
  /// In fr, this message translates to:
  /// **'Critique'**
  String get criticalPriority;

  /// No description provided for @emergencyContacts.
  ///
  /// In fr, this message translates to:
  /// **'Contacts d\'urgence'**
  String get emergencyContacts;

  /// No description provided for @allEmergencyContacts.
  ///
  /// In fr, this message translates to:
  /// **'Tous les contacts'**
  String get allEmergencyContacts;

  /// No description provided for @firefighters.
  ///
  /// In fr, this message translates to:
  /// **'Pompiers'**
  String get firefighters;

  /// No description provided for @hospitals.
  ///
  /// In fr, this message translates to:
  /// **'Hôpitaux'**
  String get hospitals;

  /// No description provided for @ambulances.
  ///
  /// In fr, this message translates to:
  /// **'SAMU / Ambulances'**
  String get ambulances;

  /// No description provided for @police.
  ///
  /// In fr, this message translates to:
  /// **'Police'**
  String get police;

  /// No description provided for @gendarmerie.
  ///
  /// In fr, this message translates to:
  /// **'Gendarmerie'**
  String get gendarmerie;

  /// No description provided for @searchEmergency.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un service, une ville, une région...'**
  String get searchEmergency;

  /// No description provided for @call.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get call;

  /// No description provided for @directions.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get directions;

  /// No description provided for @speedDials.
  ///
  /// In fr, this message translates to:
  /// **'Numéros rapides nationaux'**
  String get speedDials;

  /// No description provided for @markAllAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllAsRead;

  /// No description provided for @allNotificationsRead.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les notifications sont marquées comme lues.'**
  String get allNotificationsRead;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @reportsAndMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Rapports & PV'**
  String get reportsAndMinutes;

  /// No description provided for @thisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonth;

  /// No description provided for @allCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get allCategories;

  /// No description provided for @safetyCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get safetyCategory;

  /// No description provided for @environmentCategory.
  ///
  /// In fr, this message translates to:
  /// **'Environnement'**
  String get environmentCategory;

  /// No description provided for @operationsCategory.
  ///
  /// In fr, this message translates to:
  /// **'Opérations'**
  String get operationsCategory;

  /// No description provided for @auditCategory.
  ///
  /// In fr, this message translates to:
  /// **'Audit'**
  String get auditCategory;

  /// No description provided for @securityCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sûreté'**
  String get securityCategory;

  /// No description provided for @averageConformity.
  ///
  /// In fr, this message translates to:
  /// **'Conformité moyenne'**
  String get averageConformity;

  /// No description provided for @totalNonConformities.
  ///
  /// In fr, this message translates to:
  /// **'Non-conformités'**
  String get totalNonConformities;

  /// No description provided for @downloadPdf.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le PDF'**
  String get downloadPdf;

  /// No description provided for @shareReport.
  ///
  /// In fr, this message translates to:
  /// **'Partager le rapport'**
  String get shareReport;

  /// No description provided for @professionalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations professionnelles'**
  String get professionalInfo;

  /// No description provided for @officialEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail officiel'**
  String get officialEmail;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phone;

  /// No description provided for @jobFunction.
  ///
  /// In fr, this message translates to:
  /// **'Fonction'**
  String get jobFunction;

  /// No description provided for @department.
  ///
  /// In fr, this message translates to:
  /// **'Département'**
  String get department;

  /// No description provided for @entityOrDepot.
  ///
  /// In fr, this message translates to:
  /// **'Entité / Dépôt'**
  String get entityOrDepot;

  /// No description provided for @notSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get notSpecified;

  /// No description provided for @accountAndPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Compte & Préférences'**
  String get accountAndPreferences;

  /// No description provided for @editMyInfo.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mes informations'**
  String get editMyInfo;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logoutConfirm;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @profileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès'**
  String get profileSaved;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer le thème sombre pour l\'application'**
  String get darkModeSubtitle;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue de l\'application'**
  String get languageSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner la langue'**
  String get selectLanguage;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @pushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In fr, this message translates to:
  /// **'E-mail de rappel'**
  String get emailNotifications;

  /// No description provided for @biometricAuth.
  ///
  /// In fr, this message translates to:
  /// **'Authentification biométrique'**
  String get biometricAuth;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @general.
  ///
  /// In fr, this message translates to:
  /// **'GÉNÉRAL'**
  String get general;

  /// No description provided for @security.
  ///
  /// In fr, this message translates to:
  /// **'SÉCURITÉ'**
  String get security;

  /// No description provided for @appUpdates.
  ///
  /// In fr, this message translates to:
  /// **'Mises à jour'**
  String get appUpdates;

  /// No description provided for @checkForUpdates.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier les mises à jour'**
  String get checkForUpdates;

  /// No description provided for @checkingForUpdates.
  ///
  /// In fr, this message translates to:
  /// **'Recherche de mise à jour...'**
  String get checkingForUpdates;

  /// No description provided for @appUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'Application à jour'**
  String get appUpToDate;

  /// No description provided for @appUpToDateMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre application est à jour. Vous disposez de la version la plus récente.'**
  String get appUpToDateMessage;

  /// No description provided for @updateAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour disponible'**
  String get updateAvailable;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle version de l\'application est disponible au téléchargement.'**
  String get updateAvailableMessage;

  /// No description provided for @updateNow.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get updateLater;

  /// No description provided for @updateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de vérifier les mises à jour. Vérifiez votre connexion.'**
  String get updateError;

  /// No description provided for @currentVersionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version actuelle'**
  String get currentVersionLabel;

  /// No description provided for @newVersionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle version'**
  String get newVersionLabel;

  /// No description provided for @releaseNotes.
  ///
  /// In fr, this message translates to:
  /// **'Nouveautés'**
  String get releaseNotes;

  /// No description provided for @downloadDriveNotice.
  ///
  /// In fr, this message translates to:
  /// **'Le téléchargement du fichier APK débutera via Google Drive.'**
  String get downloadDriveNotice;

  /// No description provided for @termsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @contactSupport.
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support HSSE'**
  String get contactSupport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
