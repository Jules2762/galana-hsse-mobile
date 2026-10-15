import 'package:gestion_hsse/cores/api/api_client.dart';

class PersonnelItem {
  final dynamic id;
  final String firstName;
  final String lastName;
  final String fonction;
  final String email;
  final String direction;

  PersonnelItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fonction,
    required this.email,
    this.direction = '',
  });

  String get fullName => '$firstName $lastName'.trim();

  factory PersonnelItem.fromJson(Map<String, dynamic> json) {
    return PersonnelItem(
      id: json['id'],
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fonction: json['fonction']?.toString() ?? 'Opérateur',
      email: json['email']?.toString() ?? '',
      direction: json['direction']?.toString() ?? '',
    );
  }
}

class PersonnelService {
  static const List<Map<String, dynamic>> _defaultSeedPersonnels = [
    {
      'id': 1,
      'first_name': 'ARIMANANA',
      'last_name': 'Maherison Jules',
      'fonction': 'Inspecteur HSSE',
      'email': 'julesari_ext@galana.mg',
    },
    {
      'id': 2,
      'first_name': 'Mireille',
      'last_name': 'Ratsimbazafy',
      'fonction': 'Superviseur HSSE',
      'email': 'mireille.r@galana.mg',
    },
    {
      'id': 3,
      'first_name': 'Jean',
      'last_name': 'Rakoto',
      'fonction': 'Chef de Quart Dépôt',
      'email': 'jean.rakoto@galana.mg',
    },
    {
      'id': 4,
      'first_name': 'Alain',
      'last_name': 'Rajaona',
      'fonction': 'Chef Dépôt Antsirabe',
      'email': 'alain.r@galana.mg',
    },
    {
      'id': 5,
      'first_name': 'Tahina',
      'last_name': 'Andriamihaja',
      'fonction': 'Opérateur Dépotage',
      'email': 'tahina.a@galana.mg',
    },
    {
      'id': 6,
      'first_name': 'Faly',
      'last_name': 'Randria',
      'fonction': 'Conducteur Citerne',
      'email': 'faly.r@galana.mg',
    },
    {
      'id': 7,
      'first_name': 'Hery',
      'last_name': 'Razafindrakoto',
      'fonction': 'Pompiste / Chef Piste',
      'email': 'hery.r@galana.mg',
    },
    {
      'id': 8,
      'first_name': 'Lova',
      'last_name': 'Rakotomalala',
      'fonction': 'Technicien Maintenance',
      'email': 'lova.m@galana.mg',
    },
  ];

  static Future<List<PersonnelItem>> getPersonnels() async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/personnels/all');
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data is List
            ? response.data
            : (response.data['data'] is List ? response.data['data'] : []);
        if (raw.isNotEmpty) {
          return raw
              .map<PersonnelItem>((p) =>
                  PersonnelItem.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        }
      }
    } catch (_) {}

    // Repli hors-ligne avec la liste officielle Galana
    return _defaultSeedPersonnels
        .map((p) => PersonnelItem.fromJson(p))
        .toList();
  }
}
