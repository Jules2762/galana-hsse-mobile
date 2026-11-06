// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HSSE MANAGEMENT';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get inspections => 'Inspections';

  @override
  String get reports => 'Reports';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get emergency => 'Emergency';

  @override
  String get sos => 'SOS';

  @override
  String get online => 'ONLINE';

  @override
  String get offline => 'OFFLINE';

  @override
  String get syncing => 'SYNCING...';

  @override
  String get pendingSync => 'PENDING';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get login => 'Sign In';

  @override
  String get loginTitle => 'Secure HSSE Portal';

  @override
  String get loginSubtitle => 'Integrated Field Inspections & Audits System';

  @override
  String get professionalId => 'Professional ID / Email';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signInButton => 'Sign In';

  @override
  String get loginError => 'Incorrect credentials.';

  @override
  String get emptyCredentials => 'Please enter your email and password.';

  @override
  String get connectionError =>
      'Unable to connect to the server. Check your connection.';

  @override
  String get serverConfig => 'Server & Network Configuration';

  @override
  String get serverUrl => 'Server API URL';

  @override
  String get saveServer => 'Save & Test';

  @override
  String get allRightsReserved => 'Galana Madagascar • All rights reserved';

  @override
  String get helloUser => 'Hello';

  @override
  String get connectedServerRealtime =>
      'Connected to server • Real-time synchronization';

  @override
  String offlinePendingInspections(int count) {
    return 'Offline Mode • $count inspection(s) pending';
  }

  @override
  String offlinePendingBanner(int count) {
    return '$count inspection(s) completed offline. Auto-synced upon reconnection.';
  }

  @override
  String get sendNow => 'Send';

  @override
  String get inProgress => 'In Progress';

  @override
  String get galanaPillars => 'Galana Inspection Pillars';

  @override
  String get visits => 'visits';

  @override
  String get sheets => 'audits';

  @override
  String get trackings => 'checks';

  @override
  String get alerts => 'Alerts';

  @override
  String get inspectionsMap => 'Inspections Map';

  @override
  String get inspectionsMapSubtitle =>
      'View BBSV, Checklists & Equipment on map';

  @override
  String get emergencyBannerTitle => 'Emergency & Rescue Contacts';

  @override
  String get emergencyBannerSubtitle =>
      'Firefighters 118 • SAMU 124 • Police 117 • Gendarmerie 119';

  @override
  String get complianceRate => 'Compliance Rate';

  @override
  String get deviationsFound => 'Deviations Noted';

  @override
  String get totalActions => 'Total Actions';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get vmc => 'BBSV';

  @override
  String get checklists => 'Checklists';

  @override
  String get equipment => 'Equipment';

  @override
  String get equipmentMonitoring => 'Equipment Monitoring';

  @override
  String get listView => 'List';

  @override
  String get mapView => 'Map';

  @override
  String get all => 'All';

  @override
  String get allFemale => 'All';

  @override
  String get completed => 'Completed';

  @override
  String get planned => 'Planned';

  @override
  String get closed => 'Closed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get validated => 'Validated';

  @override
  String get rejected => 'Rejected';

  @override
  String get assignedToMe => 'Assigned to me';

  @override
  String get noChecklistsFound => 'No checklists found';

  @override
  String get noVmcsFound => 'No BBSV visits found';

  @override
  String get noEquipmentsFound => 'No equipment found';

  @override
  String get searchChecklist => 'Search checklist, site...';

  @override
  String get searchVmc => 'Search BBSV visit, site...';

  @override
  String get searchEquipment => 'Search equipment, code...';

  @override
  String get newInspection => 'New Inspection';

  @override
  String get newVmc => 'New BBSV';

  @override
  String get newEquipmentCheck => 'New Check';

  @override
  String get details => 'Details';

  @override
  String get site => 'Site / Depot';

  @override
  String get inspector => 'Inspector';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get progress => 'Progress';

  @override
  String get sections => 'Sections';

  @override
  String get questions => 'Questions';

  @override
  String get conform => 'Compliant';

  @override
  String get nonConform => 'Non-compliant';

  @override
  String get na => 'N/A';

  @override
  String get comments => 'Comments';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get attachments => 'Attachments';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get validateInspection => 'Validate & Sign';

  @override
  String get closeInspection => 'Close inspection';

  @override
  String get confirmClose => 'Are you sure you want to close this inspection?';

  @override
  String get inspectionClosedSuccess => 'Inspection closed successfully';

  @override
  String get correctiveActions => 'Corrective Actions';

  @override
  String get addAction => 'Add Action';

  @override
  String get actionTitle => 'Action Title';

  @override
  String get actionDescription => 'Description';

  @override
  String get actionPriority => 'Priority';

  @override
  String get actionDueDate => 'Due Date';

  @override
  String get actionAssignee => 'Assignee';

  @override
  String get lowPriority => 'Low';

  @override
  String get mediumPriority => 'Medium';

  @override
  String get highPriority => 'High';

  @override
  String get criticalPriority => 'Critical';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get allEmergencyContacts => 'All Contacts';

  @override
  String get firefighters => 'Firefighters';

  @override
  String get hospitals => 'Hospitals';

  @override
  String get ambulances => 'Ambulances';

  @override
  String get police => 'Police';

  @override
  String get gendarmerie => 'Gendarmerie';

  @override
  String get searchEmergency => 'Search service, city, region...';

  @override
  String get call => 'Call';

  @override
  String get directions => 'Directions';

  @override
  String get speedDials => 'National Emergency Numbers';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get allNotificationsRead => 'All notifications marked as read.';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get reportsAndMinutes => 'Reports & Minutes';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get allCategories => 'All';

  @override
  String get safetyCategory => 'Safety';

  @override
  String get environmentCategory => 'Environment';

  @override
  String get operationsCategory => 'Operations';

  @override
  String get auditCategory => 'Audit';

  @override
  String get securityCategory => 'Security';

  @override
  String get averageConformity => 'Average Compliance';

  @override
  String get totalNonConformities => 'Non-conformities';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get shareReport => 'Share Report';

  @override
  String get professionalInfo => 'Professional Information';

  @override
  String get officialEmail => 'Official Email';

  @override
  String get phone => 'Phone Number';

  @override
  String get jobFunction => 'Job Title';

  @override
  String get department => 'Department';

  @override
  String get entityOrDepot => 'Entity / Depot';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get accountAndPreferences => 'Account & Preferences';

  @override
  String get editMyInfo => 'Edit my info';

  @override
  String get changePassword => 'Change password';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get profileSaved => 'Profile updated successfully';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Enable dark theme for the application';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose application language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get emailNotifications => 'Reminder emails';

  @override
  String get biometricAuth => 'Biometric authentication';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get general => 'GENERAL';

  @override
  String get security => 'SECURITY';

  @override
  String get appUpdates => 'Updates';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkingForUpdates => 'Checking for updates...';

  @override
  String get appUpToDate => 'Application is up to date';

  @override
  String get appUpToDateMessage =>
      'Your application is up to date. You are using the latest version.';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get updateAvailableMessage =>
      'A new version of the application is available for download.';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateError =>
      'Unable to check for updates. Please check your connection.';

  @override
  String get currentVersionLabel => 'Current version';

  @override
  String get newVersionLabel => 'New version';

  @override
  String get releaseNotes => 'What\'s new';

  @override
  String get downloadDriveNotice =>
      'The APK file download will start via Google Drive.';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get contactSupport => 'Contact HSSE Support';
}
