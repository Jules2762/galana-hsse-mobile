import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

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

  /// Ouvre un volet inférieur interactif permettant de rechercher et sélectionner un personnel Galana
  static Future<PersonnelItem?> showPersonnelPicker(
    BuildContext context, {
    String? currentName,
    String title = "Choisir le responsable",
  }) async {
    final all = await getPersonnels();
    if (!context.mounted) return null;

    return showModalBottomSheet<PersonnelItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = "";
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = all.where((p) {
              final q = query.toLowerCase().trim();
              if (q.isEmpty) return true;
              return p.fullName.toLowerCase().contains(q) ||
                  p.fonction.toLowerCase().contains(q) ||
                  p.direction.toLowerCase().contains(q) ||
                  p.email.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.people_alt,
                              color: Color(0xFF1D4ED8), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "Sélectionner parmi le personnel Galana (${all.length} membres)",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: AppColors.textSecondary),
                        hintText: "Rechercher par nom, fonction, direction...",
                        hintStyle: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setSheetState(() => query = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_off_outlined,
                                    size: 40, color: AppColors.textSecondary),
                                const SizedBox(height: 8),
                                Text(
                                  "Aucun personnel trouvé pour \"$query\"",
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, index) =>
                                const Divider(height: 1, indent: 64),
                            itemBuilder: (ctx, idx) {
                              final p = filtered[idx];
                              final isSel = currentName != null &&
                                  (p.fullName.toLowerCase() ==
                                          currentName.toLowerCase() ||
                                      "${p.fullName} (${p.fonction})"
                                              .toLowerCase() ==
                                          currentName.toLowerCase() ||
                                      currentName
                                          .toLowerCase()
                                          .contains(p.fullName.toLowerCase()));
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  backgroundColor: isSel
                                      ? AppColors.primary
                                      : const Color(0xFFE2E8F0),
                                  foregroundColor: isSel
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  child: Text(
                                    (p.firstName.isNotEmpty
                                            ? p.firstName[0]
                                            : '') +
                                        (p.lastName.isNotEmpty
                                            ? p.lastName[0]
                                            : ''),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                                title: Text(
                                  p.fullName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isSel
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  [p.fonction, p.direction]
                                      .where((s) => s.isNotEmpty)
                                      .join(" • "),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                                trailing: isSel
                                    ? const Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 22)
                                    : const Icon(Icons.arrow_forward_ios,
                                        size: 14, color: AppColors.border),
                                onTap: () {
                                  Navigator.pop(ctx, p);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
