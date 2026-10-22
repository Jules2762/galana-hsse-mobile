import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:url_launcher/url_launcher.dart';
import 'package:gestion_hsse/cores/models/inspection_map_item.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/inspection_map_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class InspectionsMapView extends StatefulWidget {
  final InspectionType? initialTypeFilter;
  final String? focusedSite;
  final VoidCallback? onSwitchToList;

  const InspectionsMapView({
    super.key,
    this.initialTypeFilter,
    this.focusedSite,
    this.onSwitchToList,
  });

  @override
  State<InspectionsMapView> createState() => _InspectionsMapViewState();
}

class _InspectionsMapViewState extends State<InspectionsMapView> {
  late final MapController _mapController;

  bool _isLoading = true;
  List<InspectionMapItem> _allInspections = [];
  InspectionMapItem? _selectedInspection;

  // Filtres
  InspectionType? _selectedType;
  String _searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();

  static const LatLng _madagascarCenter = LatLng(-18.8792, 47.5079);
  static const double _defaultZoom = 7.2;

  final Map<String, LatLng> _cityCenters = {
    'Madagascar': const LatLng(-18.8792, 47.5079),
    'Antananarivo': const LatLng(-18.8792, 47.5079),
    'Antsirabe': const LatLng(-19.8659, 47.0333),
    'Toamasina': const LatLng(-18.1492, 49.4023),
    'Mahajanga': const LatLng(-15.7167, 46.3167),
    'Fianarantsoa': const LatLng(-21.4527, 47.0857),
    'Toliara': const LatLng(-23.3516, 43.6675),
    'Antsiranana': const LatLng(-12.2833, 49.2833),
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedType = widget.initialTypeFilter;
    _loadMapData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    try {
      final items = await InspectionMapService.getAllInspectionMapItems();
      if (!mounted) return;

      setState(() {
        _allInspections = items;
        _isLoading = false;
      });

      // Si un site spécifique est demandé, centrer dessus
      if (widget.focusedSite != null && widget.focusedSite!.isNotEmpty) {
        final match = items.where((it) =>
            it.site.toLowerCase().contains(widget.focusedSite!.toLowerCase()));
        if (match.isNotEmpty) {
          final first = match.first;
          _selectedInspection = first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(
              LatLng(first.latitude, first.longitude),
              13.5,
            );
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<InspectionMapItem> get _filteredInspections {
    return _allInspections.where((it) {
      if (_selectedType != null && it.type != _selectedType) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matches = it.title.toLowerCase().contains(q) ||
            it.site.toLowerCase().contains(q) ||
            it.reference.toLowerCase().contains(q) ||
            it.inspector.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  int get _countChecklist =>
      _allInspections.where((i) => i.type == InspectionType.checklist).length;
  int get _countVmc =>
      _allInspections.where((i) => i.type == InspectionType.vmc).length;
  int get _countEquipment =>
      _allInspections.where((i) => i.type == InspectionType.equipment).length;

  void _openInspectionDetails(InspectionMapItem item) {
    switch (item.type) {
      case InspectionType.checklist:
        Navigator.pushNamed(
          context,
          AppRoutes.checklistDetail,
          arguments: item.rawData,
        );
        break;
      case InspectionType.vmc:
        Navigator.pushNamed(
          context,
          AppRoutes.vmcDetail,
          arguments: item.rawData,
        );
        break;
      case InspectionType.equipment:
        Navigator.pushNamed(
          context,
          AppRoutes.equipmentDetail,
          arguments: item.rawData,
        );
        break;
    }
  }

  Future<void> _openGoogleMapsItinerary(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir l'application de cartographie"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredInspections;

    // Construction des markers
    final markers = filtered.map((item) {
      final isSelected = _selectedInspection?.id == item.id;
      final color = item.typeColor;

      return Marker(
        point: LatLng(item.latitude, item.longitude),
        width: isSelected ? 56 : 44,
        height: isSelected ? 62 : 48,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedInspection = item;
            });
            _mapController.move(LatLng(item.latitude, item.longitude), 13.0);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isSelected ? 46 : 36,
                height: isSelected ? 46 : 36,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : color,
                    width: isSelected ? 3 : 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isSelected ? 0.45 : 0.25),
                      blurRadius: isSelected ? 10 : 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    item.typeIcon,
                    size: isSelected ? 22 : 18,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
              // Petite flèche sous le pin
              ClipPath(
                clipper: _PinTriangleClipper(),
                child: Container(
                  width: isSelected ? 12 : 8,
                  height: isSelected ? 8 : 6,
                  color: isSelected ? color : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        // 1. CARTE PRINCIPALE OPENSTREETMAP
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _madagascarCenter,
            initialZoom: _defaultZoom,
            minZoom: 5.0,
            maxZoom: 18.0,
            onTap: (_, _) {
              if (_selectedInspection != null) {
                setState(() => _selectedInspection = null);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'mg.galana.gestion_hsse',
            ),

            // Halo de rayon autour de l'inspection sélectionnée
            if (_selectedInspection != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(
                      _selectedInspection!.latitude,
                      _selectedInspection!.longitude,
                    ),
                    radius: 2000,
                    useRadiusInMeter: true,
                    color: _selectedInspection!.typeColor.withValues(alpha: 0.12),
                    borderColor: _selectedInspection!.typeColor,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

            MarkerLayer(markers: markers),
          ],
        ),

        // 2. SPINNER DE CHARGEMENT
        if (_isLoading)
          Container(
            color: Colors.white.withValues(alpha: 0.6),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),

        // 3. BARRE SUPÉRIEURE DE FILTRAGE
        Positioned(
          top: 10,
          left: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne recherche + bouton retour liste (si disponible)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: "Rechercher site, référence, titre...",
                          hintStyle: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.search,
                              size: 18, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = "");
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      ),
                    ),
                  ),
                  if (widget.onSwitchToList != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: widget.onSwitchToList,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.view_list_rounded,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              "Liste",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Chips de types d'inspection (Tous, VMC, Checklists, Suivi Matériel)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTypeChip(
                      label: "Toutes (${_allInspections.length})",
                      type: null,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    _buildTypeChip(
                      label: "VMC ($_countVmc)",
                      type: InspectionType.vmc,
                      color: const Color(0xFFEA580C),
                      icon: Icons.verified_user_rounded,
                    ),
                    const SizedBox(width: 6),
                    _buildTypeChip(
                      label: "Checklists ($_countChecklist)",
                      type: InspectionType.checklist,
                      color: const Color(0xFF2563EB),
                      icon: Icons.fact_check_rounded,
                    ),
                    const SizedBox(width: 6),
                    _buildTypeChip(
                      label: "Matériel ($_countEquipment)",
                      type: InspectionType.equipment,
                      color: const Color(0xFF059669),
                      icon: Icons.fire_extinguisher_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. BOUTONS D'ACTION FLOTTANTS (ZOOM, RECENTRER, VILLES)
        Positioned(
          right: 12,
          bottom: _selectedInspection != null ? 210 : 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton sélecteur de région / ville
              FloatingActionButton.small(
                heroTag: 'fab_city_jump',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 3,
                tooltip: "Aller à une région",
                onPressed: _showCityPickerBottomSheet,
                child: const Icon(Icons.explore_outlined, size: 20),
              ),
              const SizedBox(height: 8),

              // Zoom In
              FloatingActionButton.small(
                heroTag: 'fab_zoom_in',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 3,
                onPressed: () {
                  final cur = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, cur + 1);
                },
                child: const Icon(Icons.add, size: 20),
              ),
              const SizedBox(height: 8),

              // Zoom Out
              FloatingActionButton.small(
                heroTag: 'fab_zoom_out',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 3,
                onPressed: () {
                  final cur = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, cur - 1);
                },
                child: const Icon(Icons.remove, size: 20),
              ),
              const SizedBox(height: 8),

              // Recenter Madagascar
              FloatingActionButton.small(
                heroTag: 'fab_recenter',
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                tooltip: "Recentrer Madagascar",
                onPressed: () {
                  _mapController.move(_madagascarCenter, _defaultZoom);
                },
                child: const Icon(Icons.my_location, size: 18),
              ),
            ],
          ),
        ),

        // 5. CARTE DE PRÉVISUALISATION FLOTTANTE (AU CLIC SUR UN PIN)
        if (_selectedInspection != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildInspectionPreviewCard(_selectedInspection!),
          ),
      ],
    );
  }

  Widget _buildTypeChip({
    required String label,
    required InspectionType? type,
    required Color color,
    IconData? icon,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFCBD5E1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionPreviewCard(InspectionMapItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.typeColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Badge type + Bouton fermer
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.typeIcon, size: 13, color: item.typeColor),
                    const SizedBox(width: 4),
                    Text(
                      item.typeLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item.typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item.statusColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: () => setState(() => _selectedInspection = null),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Titre de l'inspection
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Emplacement & Site
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${item.site} • GPS: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Inspecteur & Date
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                item.inspector,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today,
                  size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                item.date,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              if (item.conformityRate != null) ...[
                const Spacer(),
                Text(
                  "Conformité : ${item.conformityRate!.toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.conformityRate! >= 80
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Boutons d'action (Ouvrir inspection + Itinéraire)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.typeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text(
                    "Ouvrir l'inspection",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _openInspectionDetails(item),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.directions, size: 16, color: AppColors.primary),
                  label: const Text(
                    "Itinéraire",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () =>
                      _openGoogleMapsItinerary(item.latitude, item.longitude),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCityPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.explore, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Centrer la carte sur une région",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cityCenters.entries.map((e) {
                  return ActionChip(
                    label: Text(e.key),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _mapController.move(
                        e.value,
                        e.key == 'Madagascar' ? 6.5 : 12.5,
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _PinTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
