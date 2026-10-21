import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/models/emergency_contact_model.dart';
import 'package:gestion_hsse/cores/services/emergency_contact_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/emergency/components/emergency_map_view.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isMapMode = false;
  List<EmergencyContactModel> _allContacts = [];
  List<EmergencyContactModel> _filteredContacts = [];
  List<EmergencySiteModel> _allSites = [];

  String _selectedType = 'ALL';
  String? _selectedLocality;
  EmergencySiteModel? _selectedSite;

  final List<Map<String, String>> _categories = const [
    {'key': 'ALL', 'label': 'Tous', 'emoji': '🚨'},
    {'key': 'POMPIER', 'label': 'Pompiers', 'emoji': '🚒'},
    {'key': 'HOPITAL', 'label': 'Hôpitaux', 'emoji': '🏥'},
    {'key': 'AMBULANCE', 'label': 'SAMU / Ambulances', 'emoji': '🚑'},
    {'key': 'POLICE', 'label': 'Police', 'emoji': '👮'},
    {'key': 'GENDARMERIE', 'label': 'Gendarmerie', 'emoji': '🛡️'},
  ];

  final List<Map<String, String>> _speedDials = const [
    {
      'label': 'Pompiers',
      'number': '118',
      'emoji': '🚒',
      'color': '0xFFDC2626',
      'sub': 'Incendie & Secours'
    },
    {
      'label': 'SAMU',
      'number': '124',
      'emoji': '🚑',
      'color': '0xFF0284C7',
      'sub': 'Urgences médicales'
    },
    {
      'label': 'Police',
      'number': '117',
      'emoji': '👮',
      'color': '0xFF4F46E5',
      'sub': 'Police Secours'
    },
    {
      'label': 'Gendarmerie',
      'number': '119',
      'emoji': '🛡️',
      'color': '0xFF7C3AED',
      'sub': 'Axes nationaux'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final mapData = await EmergencyContactService.getMapData();
      final contacts = mapData['contacts'] as List<EmergencyContactModel>? ?? [];
      final sites = mapData['sites'] as List<EmergencySiteModel>? ?? [];

      if (mounted) {
        setState(() {
          _allContacts = contacts;
          _allSites = sites;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (_) {
      final fallback = EmergencyContactService.defaultEmergencyContacts;
      if (mounted) {
        setState(() {
          _allContacts = fallback;
          _applyFilters();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _allContacts.where((item) {
      if (_selectedType != 'ALL' &&
          item.type.toUpperCase() != _selectedType.toUpperCase()) {
        return false;
      }

      if (_selectedLocality != null && _selectedLocality!.isNotEmpty) {
        if (!item.locality
            .toLowerCase()
            .contains(_selectedLocality!.toLowerCase())) {
          return false;
        }
      }

      if (_selectedSite != null) {
        final siteNameLower = _selectedSite!.name.toLowerCase();
        final matchesSite = item.siteNames
            .any((s) => s.toLowerCase().contains(siteNameLower));
        final matchesSiteLocality = _selectedSite!.locality != null &&
            item.locality
                .toLowerCase()
                .contains(_selectedSite!.locality!.toLowerCase());

        if (!matchesSite && !matchesSiteLocality) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final inName = item.name.toLowerCase().contains(query);
        final inLocality = item.locality.toLowerCase().contains(query);
        final inProvince =
            (item.province ?? '').toLowerCase().contains(query);
        final inPhone = item.contact1.contains(query) ||
            (item.contact2 != null && item.contact2!.contains(query)) ||
            (item.contact3 != null && item.contact3!.contains(query));
        final inSites =
            item.siteNames.any((s) => s.toLowerCase().contains(query));
        final inNotes = (item.notes ?? '').toLowerCase().contains(query);

        if (!inName &&
            !inLocality &&
            !inProvince &&
            !inPhone &&
            !inSites &&
            !inNotes) {
          return false;
        }
      }

      return true;
    }).toList();

    setState(() {
      _filteredContacts = filtered;
    });
  }

  void _selectType(String typeKey) {
    setState(() {
      _selectedType = typeKey;
    });
    _applyFilters();
  }

  void _showSiteFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String filterQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sites = _allSites.where((s) {
              if (filterQuery.isEmpty) return true;
              return s.name.toLowerCase().contains(filterQuery.toLowerCase()) ||
                  (s.locality ?? '')
                      .toLowerCase()
                      .contains(filterQuery.toLowerCase());
            }).toList();

            return Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtrer par Station Galana",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Chercher une station, ville...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        filterQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_selectedSite != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextButton.icon(
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text("Effacer le filtre station"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedSite = null;
                          });
                          _applyFilters();
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  Expanded(
                    child: sites.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucune station trouvée",
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.separated(
                            itemCount: sites.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final site = sites[index];
                              final isSelected =
                                  _selectedSite?.id == site.id;

                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.local_gas_station_rounded,
                                    size: 20,
                                    color: isSelected
                                        ? const Color(0xFF0F9D58)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                                title: Text(
                                  site.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF0F9D58)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                subtitle: site.locality != null
                                    ? Text(
                                        site.locality!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B)),
                                      )
                                    : null,
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: Color(0xFF0F9D58), size: 20)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedSite = site;
                                  });
                                  _applyFilters();
                                  Navigator.pop(ctx);
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

  void _showDetailBottomSheet(EmergencyContactModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée de glissement
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header secours
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item.typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: item.typeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.typeEmoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.typeLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: item.typeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              '${item.locality}${item.province != null ? ' (${item.province})' : ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Boutons d'appel pour chaque ligne
              const Text(
                "LIGNES D'APPEL DIRECT",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              _buildCallTile(
                title: "Ligne Principale (Prioritaire)",
                number: item.contact1,
                color: item.typeColor,
                isPrimary: true,
              ),

              if (item.contact2 != null && item.contact2!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildCallTile(
                  title: "Ligne Secondaire",
                  number: item.contact2!,
                  color: const Color(0xFF2563EB),
                ),
              ],

              if (item.contact3 != null && item.contact3!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildCallTile(
                  title: "Ligne Tertiaire / Mobile",
                  number: item.contact3!,
                  color: const Color(0xFF0D9488),
                ),
              ],

              // Informations complémentaires
              if (item.address != null && item.address!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  icon: Icons.map_outlined,
                  title: "Adresse géographique",
                  content: item.address!,
                ),
              ],

              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoSection(
                  icon: Icons.info_outline,
                  title: "Consignes & Périmètre d'intervention",
                  content: item.notes!,
                ),
              ],

              if (item.siteNames.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  "STATIONS GALANA COUVERTES",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.siteNames.map((siteName) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_gas_station,
                              size: 13, color: Color(0xFF0F9D58)),
                          const SizedBox(width: 4),
                          Text(
                            siteName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallTile({
    required String title,
    required String number,
    required Color color,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? color.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          width: isPrimary ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? color : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.phone_in_talk, size: 16),
            label: const Text("Appeler"),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => EmergencyContactService.callPhone(number, context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Contacts d'Urgence",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              "Secours & Stations Galana",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: SyncService.instance,
            builder: (context, _) {
              final isOnline = SyncService.instance.isOnline;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOnline
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFFCD34D),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? "EN LIGNE" : "HORS-LIGNE",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isOnline
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            tooltip: "Actualiser",
            onPressed: _loadData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isMapMode) setState(() => _isMapMode = false);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: !_isMapMode ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !_isMapMode
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.28),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 16,
                              color: !_isMapMode ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Liste",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: !_isMapMode ? FontWeight.w700 : FontWeight.w600,
                                color: !_isMapMode ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: !_isMapMode
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${_filteredContacts.length}",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: !_isMapMode ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_isMapMode) setState(() => _isMapMode = true);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _isMapMode ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _isMapMode
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.28),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              size: 16,
                              color: _isMapMode ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Carte",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _isMapMode ? FontWeight.w700 : FontWeight.w600,
                                color: _isMapMode ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _isMapMode
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${_allSites.length} stations",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _isMapMode ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _isMapMode
              ? EmergencyMapView(
                  contacts: _allContacts,
                  sites: _allSites,
                  selectedType: _selectedType,
                  selectedSite: _selectedSite,
                  onSelectType: _selectType,
                  onShowDetail: _showDetailBottomSheet,
                  onDirectCall: (phone, name) =>
                      EmergencyContactService.callPhone(phone, context),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. COMPOSITEURS RAPIDES MADAGASCAR (SPEED DIAL)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "NUMÉROS D'URGENCE NATIONAUX",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "Appel gratuit",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: _speedDials.map((sd) {
                  final color = Color(int.parse(sd['color']!));
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          EmergencyContactService.callPhone(sd['number']!, context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                sd['emoji']!,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sd['number']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sd['label']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 2. RECHERCHE & FILTRES RAPIDES
              // ==========================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher par nom, ville, station, tél...",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F9D58),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Sélecteur de Station Galana
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showSiteFilterDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedSite != null
                        ? const Color(0xFFDCFCE7)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedSite != null
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_gas_station_rounded,
                        size: 20,
                        color: _selectedSite != null
                            ? const Color(0xFF0F9D58)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedSite != null
                              ? "Station : ${_selectedSite!.name}"
                              : "Filtrer les secours par Station Galana...",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedSite != null
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: _selectedSite != null
                                ? const Color(0xFF15803D)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      if (_selectedSite != null)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSite = null;
                            });
                            _applyFilters();
                          },
                          child: const Icon(Icons.close,
                              size: 18, color: Color(0xFF15803D)),
                        )
                      else
                        const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Filtres catégories (Pills défilantes)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedType == cat['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat['emoji']!,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(cat['label']!),
                          ],
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF0F9D58),
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0F9D58)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (_) => _selectType(cat['key']!),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // ==========================================
              // 3. EN-TÊTE DU RÉPERTOIRE
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ANNUAIRE DES SECOURS (${_filteredContacts.length})",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (_allContacts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Mode Hors-ligne OK",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // ==========================================
              // 4. LISTE DES CONTACTS D'URGENCE
              // ==========================================
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                      color: Color(0xFF0F9D58),
                    ),
                  ),
                )
              else if (_filteredContacts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Aucun contact d'urgence trouvé",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Essayez de modifier votre recherche ou de réinitialiser vos filtres.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.restart_alt, size: 16),
                        label: const Text("Réinitialiser les filtres"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9D58),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedType = 'ALL';
                            _selectedLocality = null;
                            _selectedSite = null;
                          });
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredContacts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _filteredContacts[index];
                    return _buildContactCard(item);
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContactModel item) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDetailBottomSheet(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bandeau supérieur coloré fin
              Container(
                height: 4,
                width: double.infinity,
                color: item.typeColor,
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge type & Localité
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.typeEmoji,
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                item.typeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: item.typeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                item.locality,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Nom du secours
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),

                    if (item.address != null && item.address!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],

                    // Stations couvertes (pills)
                    if (item.siteNames.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: item.siteNames.take(3).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_gas_station,
                                    size: 11, color: Color(0xFF0F9D58)),
                                const SizedBox(width: 3),
                                Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Bouton d'appel principal & lignes secondaires
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.phone_forwarded, size: 18),
                            label: Text(
                              "Appeler (${item.contact1})",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.typeColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => EmergencyContactService.callPhone(
                                item.contact1, context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Bouton détails
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _showDetailBottomSheet(item),
                          child: const Icon(Icons.more_horiz,
                              color: Color(0xFF475569)),
                        ),
                      ],
                    ),

                    // Lignes secondaires raccourcis
                    if (item.contact2 != null || item.contact3 != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (item.contact2 != null &&
                              item.contact2!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () => EmergencyContactService.callPhone(
                                    item.contact2!, context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 11, color: Color(0xFF2563EB)),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Ligne 2: ${item.contact2}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (item.contact3 != null &&
                              item.contact3!.isNotEmpty)
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => EmergencyContactService.callPhone(
                                  item.contact3!, context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 11, color: Color(0xFF0D9488)),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Ligne 3: ${item.contact3}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
