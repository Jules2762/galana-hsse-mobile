# GALANA HSSE - Application Mobile Terrain (Flutter)

Ce sous-projet constitue l'application mobile de terrain de la plateforme **GALANA HSSE (Hygiène, Sécurité, Sûreté et Environnement)**. Conçue pour les inspecteurs de sécurité, auditeurs HSSE et chefs de site, elle permet de réaliser des inspections sur les installations pétrolières et stations-service de Galana Madagascar, de capturer des preuves photographiques, de cartographier les constats et de générer des actions correctives immédiates.

---

## 📑 Sommaire

1. [Architecture Mobile](#-architecture-mobile)
2. [Arborescence du Code Source](#-arborescence-du-code-source)
3. [Modules Fonctionnels & Parcours Utilisateur](#-modules-fonctionnels--parcours-utilisateur)
4. [Moteur Cartographique Embarqué (Flutter Map)](#-moteur-cartographique-embarqué-flutter-map)
5. [Génération & Impression de Rapports PDF](#-génération--impression-de-rapports-pdf)
6. [Mode Hors-Ligne & Synchronisation](#-mode-hors-ligne--synchronisation)
7. [Configuration Réseau & Permissions Android](#-configuration-réseau--permissions-android)
8. [Installation & Démarrage en Développement](#-installation--démarrage-en-développement)
9. [Génération de l'APK de Production (Release)](#-génération-de-lapk-de-production-release)

---

## 🏛 Architecture Mobile

L'application est développée avec **Flutter 3** et **Dart 3**, articulée autour d'une architecture modulaire claire séparant l'état, la logique métier et la présentation :

```
gestion-hsse-mobile/
├── android/                           # Projet natif Android (Manifest, Gradle, ressources)
├── ios/                               # Projet natif iOS (Info.plist, Runner)
├── assets/                            # Logos Galana, icônes adaptatives, images d'accueil
└── lib/
    ├── cores/                         # Noyau transversal de l'application
    │   ├── api/                       # Client HTTP Dio et intercepteurs
    │   ├── models/                    # Modèles de données Dart typés
    │   ├── routes/                    # Constantes de navigation AppRoutes
    │   ├── services/                  # Logique métier et échanges API
    │   └── themes/                    # Charte graphique, polices et couleurs Galana
    ├── views/                         # Écrans organisés par domaine fonctionnel
    │   ├── auth/                      # Écrans de connexion et réinitialisation
    │   ├── home/                      # Espace principal authentifié
    │   │   ├── dashboard/             # Indicateurs clés et progression
    │   │   ├── emergency/             # Annuaire et cartographie des urgences
    │   │   ├── inspection/            # Modules VMC, Checklists, Suivi matériel
    │   │   ├── notification/          # Notifications push / locales
    │   │   ├── profile/               # Consultation du profil utilisateur
    │   │   ├── rapport/               # Synthèse et exports de rapports
    │   │   └── settings/              # Configuration de l'IP du serveur API
    │   ├── layouts/                   # Gabarit HomeLayout (BottomNavigationBar)
    │   └── onBoarding/                # Écrans de présentation au premier lancement
    ├── widgets/                       # Composants réutilisables (Boutons, Cartes, Champs)
    └── main.dart                      # Point d'entrée de l'application
```

---

## 📱 Modules Fonctionnels & Parcours Utilisateur

### 1. 📋 Module Inspections de Terrain (`views/home/inspection/`)
L'application prend en charge les trois grandes typologies d'inspections HSSE :

* **Visites Managériales Comportementales (VMC)** :
  * Évaluation des comportements observés : situations sécuritaires vs comportements à risque.
  * Prise de vue photographique instantanée via l'appareil photo (`camera_service.dart`).
  * Déclenchement guidé d'actions correctives avec assignation immédiate d'un responsable et d'un délai.
* **Checklists d'Audit Périodique** :
  * Formulaire guidé étape par étape selon la grille de contrôle sélectionnée.
  * Saisie par critères (Conforme, Non-conforme, N/A, Remarque).
  * Calcul automatique du score et du pourcentage global de conformité.
* **Suivi des Équipements de Sécurité (Extincteurs, RIA, Alarmes)** :
  * Sélection du site grâce au sélecteur intelligent avec barre de recherche, filtres par localité et ajout direct de site personnalisé.
  * Contrôle de conformité de chaque équipement (numéro, type, état physique, pression, date de visite, date de péremption).
  * Création automatique d'actions correctives en cas de non-conformité.

### 2. 🗺️ Cartographie Mobile Interactive (`inspections_map_view.dart`)
* Visualisation sur carte OpenStreetMap de tous les sites et inspections réalisés.
* Marqueurs distincts selon le type d'inspection (VMC, Checklist, Équipement) et statut de conformité.
* Cercles de périmètre d'intervention (rayon en mètres) autour des stations ou dépôts.
* Raccourci vers les grandes agglomérations malgaches (Antananarivo, Tamatave, Majunga, Diego, Toliara, Antsirabe, Fianarantsoa).

### 3. 🚨 Module d'Urgence (`emergency_map_view.dart`)
* Répertoire complet des contacts d'urgence (Pompiers, SAMU, Police, Gendarmerie, Postes de commandement Galana).
* Déclenchement immédiat de l'appel téléphonique en 1 clic grâce au paquet `url_launcher`.
* Affichage spatial des stations-service avec indication de la distance d'intervention.

### 4. 📊 Tableau de Bord Mobile & Profil
* Vue synthétique des audits réalisés et des actions en attente de traitement.
* Barres de progression réelles basées sur les inspections terminées vs planifiées.
* Gestion des préférences et réglage direct de l'adresse du serveur API (utile pour le passage du Wi-Fi local au serveur distant).

---

## 🗺️ Moteur Cartographique Embarqué (Flutter Map)

La cartographie repose sur **`flutter_map` (v8.3.2)** et **`latlong2`**.

Afin de garantir un fonctionnement infaillible sur le terrain (notamment sur les réseaux mobiles 3G/4G malgaches ou en zone de connectivité instable), la couche de tuiles intègre une politique de tolérance aux pannes :

```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.mobile',
  maxZoom: 19,
  fallbackUrl: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
)
```

* **Serveur Principal** : OpenStreetMap France / International.
* **Serveur Miroir de Secours (`fallbackUrl`)** : CartoDB Voyager Raster Tiles, garantissant l'affichage même si OpenStreetMap standard est saturé ou inaccessible.
* **Identification Conforme** : `userAgentPackageName` aligné sur le package Android (`com.example.mobile`) pour respecter la politique d'utilisation des serveurs cartographiques publics.

---

## 📄 Génération & Impression de Rapports PDF

L'application intègre un moteur complet de génération de documents PDF vectoriels hors-ligne grâce aux bibliothèques `pdf` et `printing` :

* **[vmc_pdf_service.dart](file:///home/debian/Téléchargements/GESTION_HSSE_20261022_1440/GESTION_HSSE/gestion-hsse-mobile/lib/cores/services/vmc_pdf_service.dart)** : Fiche complète de Visite Managériale Comportementale avec entête officielle Galana, tableau des constats et signatures.
* **[checklist_pdf_service.dart](file:///home/debian/Téléchargements/GESTION_HSSE_20261022_1440/GESTION_HSSE/gestion-hsse-mobile/lib/cores/services/checklist_pdf_service.dart)** : Rapport détaillé d'audit par section avec calcul des taux de conformité.
* **[report_pdf_service.dart](file:///home/debian/Téléchargements/GESTION_HSSE_20261022_1440/GESTION_HSSE/gestion-hsse-mobile/lib/cores/services/report_pdf_service.dart)** : Synthèse globale d'inspection imprimable sur imprimante Bluetooth/Wi-Fi ou partageable par email/messagerie.

---

## 💾 Mode Hors-Ligne & Synchronisation

Pour répondre aux contraintes des dépôts pétroliers et stations isolées où la couverture réseau peut être faible ou absente :

* **[offline_storage_service.dart](file:///home/debian/Téléchargements/GESTION_HSSE_20261022_1440/GESTION_HSSE/gestion-hsse-mobile/lib/cores/services/offline_storage_service.dart)** : Sauvegarde locale dans `SharedPreferences` et sur le stockage sécurisé du terminal des formulaires d'inspection en cours de rédaction.
* **[sync_service.dart](file:///home/debian/Téléchargements/GESTION_HSSE_20261022_1440/GESTION_HSSE/gestion-hsse-mobile/lib/cores/services/sync_service.dart)** : File d'attente intelligente de synchronisation qui transmet automatiquement les fiches d'inspection et leurs pièces jointes vers l'API Laravel dès la restauration de la connexion Internet.

---

## 🔒 Configuration Réseau & Permissions Android

Pour permettre le bon fonctionnement de la cartographie et des appels API sur un terminal physique en mode **Release**, les autorisations suivantes sont expressément déclarées dans [AndroidManifest.xml](file:///home/debian/Téléchargements/GESTION_HSSE_20261022_1440/GESTION_HSSE/gestion-hsse-mobile/android/app/src/main/AndroidManifest.xml) :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions réseau obligatoires en mode Release -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Géolocalisation pour centrer la carte sur le terrain -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <!-- Prise de vue photographique des constats et équipements -->
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="GALANA HSSE"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        ...
    </application>
</manifest>
```

> [!IMPORTANT]
> L'attribut `android:usesCleartextTraffic="true"` autorise les communications HTTP non chiffrées durant les phases de tests lorsque le serveur API est hébergé sur une adresse IP locale (ex: `http://192.168.x.x:8000`).

---

## ⚙️ Installation & Démarrage en Développement

### 1. Prérequis
* Flutter SDK >= 3.24 (Dart >= 3.5)
* Android Studio / SDK Android configuré (API Level 21 minimum, API 34+ recommandée)
* Câble USB avec débogage USB activé sur votre smartphone, ou un émulateur Android fonctionnel

### 2. Récupération des dépendances
```bash
cd gestion-hsse-mobile
flutter pub get
```

### 3. Configuration de l'adresse de l'API
* **Sur émulateur Android officiel** : L'adresse de l'API Laravel qui tourne sur votre PC est accessible via `http://10.0.2.2:8000/api`.
* **Sur un téléphone physique connecté au même réseau Wi-Fi** : Renseignez l'IP locale de votre machine de développement (ex: `http://192.168.1.50:8000/api`). Vous pouvez la modifier directement depuis l'écran **Paramètres** de l'application mobile.

### 4. Lancement en mode débogage
```bash
# Vérifier la détection du terminal
flutter devices

# Lancer l'application
flutter run
```

---

## 📦 Génération de l'APK de Production (Release)

Pour générer un fichier APK autonome directement installable sur n'importe quel smartphone Android :

```bash
# 1. Nettoyer les builds antérieurs
flutter clean
flutter pub get

# 2. Vérifier l'analyse statique du code
dart analyze lib/

# 3. Compiler l'APK de production optimisé
flutter build apk --release
```

Une fois la compilation terminée, le fichier exécutable prêt à être déployé est disponible sous :
📍 `build/app/outputs/flutter-apk/app-release.apk`

Pour générer un format optimisé destiné au Google Play Store :
```bash
flutter build appbundle --release
```
Le bundle sera situé sous `build/app/outputs/bundle/release/app-release.aab`.
