import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:gestion_hsse/cores/models/emergency_contact_model.dart';

class EmergencyMapView extends StatefulWidget {
  final List<EmergencyContactModel> contacts;
  final List<EmergencySiteModel> sites;
  final String selectedType;
  final EmergencySiteModel? selectedSite;
  final Function(String typeKey) onSelectType;
  final Function(EmergencyContactModel item) onShowDetail;
  final Function(String number, String name) onDirectCall;

  const EmergencyMapView({
    super.key,
    required this.contacts,
    required this.sites,
    required this.selectedType,
    this.selectedSite,
    required this.onSelectType,
    required this.onShowDetail,
    required this.onDirectCall,
  });

  @override
  State<EmergencyMapView> createState() => _EmergencyMapViewState();
}

class _EmergencyMapViewState extends State<EmergencyMapView> {
  late final MapController _mapController;

  EmergencyContactModel? _highlightedContact;
  EmergencySiteModel? _highlightedSite;
  bool _showLegend = false;
  String _nearbyFilterType = 'ALL';

  // Centre par défaut : Antananarivo, Madagascar
  static const LatLng _defaultCenter = LatLng(-18.8920, 47.5238);
  static const double _defaultZoom = 12.0;

  final List<Map<String, String>> _categories = const [
    {'key': 'ALL', 'label': 'Tous', 'emoji': '🚨'},
    {'key': 'POMPIER', 'label': 'Pompiers', 'emoji': '🚒'},
    {'key': 'HOPITAL', 'label': 'Hôpitaux', 'emoji': '🏥'},
    {'key': 'AMBULANCE', 'label': 'SAMU', 'emoji': '🚑'},
    {'key': 'POLICE', 'label': 'Police', 'emoji': '👮'},
    {'key': 'GENDARMERIE', 'label': 'Gendarmerie', 'emoji': '🛡️'},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.selectedSite != null) {
      _highlightedSite = widget.selectedSite;
    }
  }

  @override
  void didUpdateWidget(covariant EmergencyMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSite != oldWidget.selectedSite && widget.selectedSite != null) {
      _highlightedSite = widget.selectedSite;
      if (widget.selectedSite!.latitude != null && widget.selectedSite!.longitude != null) {
        _mapController.move(
          LatLng(widget.selectedSite!.latitude!, widget.selectedSite!.longitude!),
          13.5,
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ==========================================
  // CALCULS DE DISTANCES & PROXIMITÉ GÉODÉSIQUE
  // ==========================================

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // math.pi / 180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R, R = 6371 km
  }

  String _formatDistance(double km) {
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return "$meters m";
    }
    return "${km.toStringAsFixed(1)} km";
  }

  List<EmergencyContactModel> _getNearbyContactsForSite(EmergencySiteModel site) {
    if (site.latitude == null || site.longitude == null) return [];

    final List<EmergencyContactModel> list = [];
    for (final c in widget.contacts) {
      if (c.latitude == null || c.longitude == null) continue;
      final dist = _calculateDistanceKm(
        site.latitude!,
        site.longitude!,
        c.latitude!,
        c.longitude!,
      );
      list.add(c.copyWith(distanceKm: dist));
    }

    list.sort((a, b) => (a.distanceKm ?? 99999).compareTo(b.distanceKm ?? 99999));
    return list;
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _recenterMap() {
    if (_highlightedSite != null &&
        _highlightedSite!.latitude != null &&
        _highlightedSite!.longitude != null) {
      _mapController.move(
        LatLng(_highlightedSite!.latitude!, _highlightedSite!.longitude!),
        13.5,
      );
    } else if (widget.selectedSite != null &&
        widget.selectedSite!.latitude != null &&
        widget.selectedSite!.longitude != null) {
      _mapController.move(
        LatLng(widget.selectedSite!.latitude!, widget.selectedSite!.longitude!),
        13.5,
      );
    } else {
      _mapController.move(_defaultCenter, _defaultZoom);
    }
  }

  // ==========================================
  // GÉNÉRATION DES MARQUEURS
  // ==========================================

  List<Marker> _buildMarkers(Map<dynamic, double> nearbyDistMap) {
    final List<Marker> markers = [];

    // 1. Marqueurs des Stations Galana
    for (final site in widget.sites) {
      if (site.latitude == null || site.longitude == null) continue;
      final isSelected = _highlightedSite?.id == site.id;

      markers.add(
        Marker(
          point: LatLng(site.latitude!, site.longitude!),
          width: isSelected ? 60 : 42,
          height: isSelected ? 60 : 42,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _highlightedSite = site;
                _highlightedContact = null;
                _nearbyFilterType = 'ALL';
              });
              _mapController.move(LatLng(site.latitude!, site.longitude!), 13.5);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: const Color(0xFF0F9D58),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFEF08A) : Colors.white,
                  width: isSelected ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF0F9D58).withValues(alpha: 0.6)
                        : const Color(0xFF0F9D58).withValues(alpha: 0.4),
                    blurRadius: isSelected ? 14 : 6,
                    spreadRadius: isSelected ? 2 : 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.local_gas_station_rounded,
                  color: Colors.white,
                  size: isSelected ? 28 : 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Marqueurs des Services de Secours
    for (final contact in widget.contacts) {
      if (contact.latitude == null || contact.longitude == null) continue;

      if (widget.selectedType != 'ALL' &&
          contact.type.toUpperCase() != widget.selectedType.toUpperCase()) {
        continue;
      }

      final isSelected = _highlightedContact?.id == contact.id;
      final isNearSelectedSite = nearbyDistMap.containsKey(contact.id);
      final distKm = nearbyDistMap[contact.id];
      final pinColor = contact.typeColor;

      markers.add(
        Marker(
          point: LatLng(contact.latitude!, contact.longitude!),
          width: isNearSelectedSite ? 60 : (isSelected ? 48 : 38),
          height: isNearSelectedSite ? 66 : (isSelected ? 56 : 46),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _highlightedContact = contact;
              });
              _mapController.move(LatLng(contact.latitude!, contact.longitude!), 14.5);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge distance si ce secours est parmi les plus proches de la station sélectionnée
                if (isNearSelectedSite && distKm != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      _formatDistance(distKm),
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isNearSelectedSite ? 38 : (isSelected ? 40 : 32),
                  height: isNearSelectedSite ? 38 : (isSelected ? 40 : 32),
                  decoration: BoxDecoration(
                    color: pinColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFEF08A)
                          : (isNearSelectedSite ? const Color(0xFFF59E0B) : Colors.white),
                      width: isNearSelectedSite ? 3 : (isSelected ? 3 : 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isNearSelectedSite
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                            : pinColor.withValues(alpha: 0.4),
                        blurRadius: isNearSelectedSite || isSelected ? 10 : 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      contact.typeEmoji,
                      style: TextStyle(
                        fontSize: isNearSelectedSite ? 17 : (isSelected ? 18 : 13),
                      ),
                    ),
                  ),
                ),
                // Pointe du pin
                CustomPaint(
                  size: Size(
                    isNearSelectedSite ? 10 : (isSelected ? 10 : 8),
                    isNearSelectedSite ? 7 : (isSelected ? 8 : 6),
                  ),
                  painter: _TrianglePainter(color: pinColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // Calculer les secours proches si une station est sélectionnée
    final List<EmergencyContactModel> nearbyForSite = _highlightedSite != null
        ? _getNearbyContactsForSite(_highlightedSite!)
        : [];

    // Map des 6 secours les plus proches pour le badge dynamique sur la carte
    final Map<dynamic, double> nearbyDistMap = {
      for (final c in nearbyForSite.take(6)) c.id: c.distanceKm ?? 0.0
    };

    final markers = _buildMarkers(nearbyDistMap);

    // Déterminer la position des boutons flottants pour ne pas chevaucher la fiche du bas
    final double floatingBottom = _highlightedSite != null
        ? 345
        : (_highlightedContact != null ? 220 : 20);

    return Stack(
      children: [
        // ==========================================
        // 1. CARTE OPENSTREETMAP INTERACTIVE
        // ==========================================
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: _defaultZoom,
            minZoom: 5.0,
            maxZoom: 18.0,
            onTap: (_, _) {
              if (_highlightedContact != null || _highlightedSite != null) {
                setState(() {
                  _highlightedContact = null;
                  _highlightedSite = null;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'mg.galana.gestion_hsse',
            ),

            // Cercle de périmètre d'intervention de la station sélectionnée
            if (_highlightedSite != null &&
                _highlightedSite!.latitude != null &&
                _highlightedSite!.longitude != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(_highlightedSite!.latitude!, _highlightedSite!.longitude!),
                    radius: 3500,
                    useRadiusInMeter: true,
                    color: const Color(0xFF0F9D58).withValues(alpha: 0.08),
                    borderColor: const Color(0xFF0F9D58).withValues(alpha: 0.45),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),

            MarkerLayer(markers: markers),
          ],
        ),

        // ==========================================
        // 2. BARRE SUPÉRIEURE DE FILTRES PAR TYPE
        // ==========================================
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = widget.selectedType == cat['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () {
                          widget.onSelectType(cat['key']!);
                          setState(() {
                            _highlightedContact = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F9D58) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0F9D58) : const Color(0xFFCBD5E1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat['emoji']!, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Text(
                                cat['label']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Badge indicateur du nombre de repères affichés
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pin_drop_rounded, size: 13, color: Color(0xFF0F9D58)),
                    const SizedBox(width: 4),
                    Text(
                      "${markers.length} points (Stations Galana & Secours)",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ==========================================
        // 3. BOUTONS DE CONTRÔLE FLOTTANTS (ZOOM & LÉGENDE)
        // ==========================================
        Positioned(
          right: 14,
          bottom: floatingBottom,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFloatingBtn(
                icon: Icons.add,
                tooltip: "Zoom avant",
                onTap: _zoomIn,
              ),
              const SizedBox(height: 6),
              _buildFloatingBtn(
                icon: Icons.remove,
                tooltip: "Zoom arrière",
                onTap: _zoomOut,
              ),
              const SizedBox(height: 6),
              _buildFloatingBtn(
                icon: Icons.my_location_rounded,
                tooltip: "Recentrer sur la sélection",
                onTap: _recenterMap,
                color: const Color(0xFF0F9D58),
                iconColor: Colors.white,
              ),
              const SizedBox(height: 6),
              _buildFloatingBtn(
                icon: _showLegend ? Icons.layers_clear_rounded : Icons.layers_rounded,
                tooltip: "Légende",
                onTap: () => setState(() => _showLegend = !_showLegend),
              ),
            ],
          ),
        ),

        // ==========================================
        // 4. PANNEAU DE LÉGENDE FLOTTANT
        // ==========================================
        if (_showLegend)
          Positioned(
            left: 14,
            bottom: floatingBottom,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "LÉGENDE CARTE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendRow(const Color(0xFF0F9D58), "Station Galana", icon: Icons.local_gas_station_rounded),
                  _buildLegendRow(const Color(0xFFDC2626), "Pompiers (118)", emoji: "🚒"),
                  _buildLegendRow(const Color(0xFF0284C7), "SAMU / Ambulance (124)", emoji: "🚑"),
                  _buildLegendRow(const Color(0xFF059669), "Hôpital / Clinique", emoji: "🏥"),
                  _buildLegendRow(const Color(0xFF4F46E5), "Police Nationale (117)", emoji: "👮"),
                  _buildLegendRow(const Color(0xFF7C3AED), "Gendarmerie (119)", emoji: "🛡️"),
                ],
              ),
            ),
          ),

        // ==========================================
        // 5. CARTE DE DÉTAIL EN BAS (CONTACT SÉLECTIONNÉ)
        // ==========================================
        if (_highlightedContact != null && _highlightedSite == null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _highlightedContact!.typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(_highlightedContact!.typeEmoji, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _highlightedContact!.typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _highlightedContact!.typeLabel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: _highlightedContact!.typeColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _highlightedContact!.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${_highlightedContact!.locality} • ${_highlightedContact!.province ?? 'Madagascar'}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _highlightedContact = null),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Boutons d'action : Appel direct & fiche
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone_in_talk, size: 16, color: Colors.white),
                          label: Text(
                            "Appeler ${_highlightedContact!.contact1}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _highlightedContact!.typeColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () => widget.onDirectCall(
                            _highlightedContact!.contact1,
                            _highlightedContact!.name,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () => widget.onShowDetail(_highlightedContact!),
                        child: const Text(
                          "Détails",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // ==========================================
        // 6. CARTE DES SECOURS PROCHES POUR LA STATION SÉLECTIONNÉE
        // ==========================================
        if (_highlightedSite != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildNearbySosCard(_highlightedSite!, nearbyForSite),
          ),
      ],
    );
  }

  // ==========================================
  // COMPOSANT : PANNEAU DES SOS PROCHES DE LA STATION
  // ==========================================

  Widget _buildNearbySosCard(EmergencySiteModel site, List<EmergencyContactModel> nearbyAll) {
    // Filtrage des secours de la station par catégorie sélectionnée
    final nearbyFiltered = nearbyAll.where((c) {
      if (_nearbyFilterType == 'ALL') return true;
      if (_nearbyFilterType == 'POMPIER') return c.type.toUpperCase() == 'POMPIER';
      if (_nearbyFilterType == 'SANTE') {
        final t = c.type.toUpperCase();
        return t == 'HOPITAL' || t == 'AMBULANCE';
      }
      if (_nearbyFilterType == 'FORCES') {
        final t = c.type.toUpperCase();
        return t == 'POLICE' || t == 'GENDARMERIE';
      }
      return true;
    }).toList();

    final countPompiers = nearbyAll.where((c) => c.type.toUpperCase() == 'POMPIER').length;
    final countSante = nearbyAll.where((c) {
      final t = c.type.toUpperCase();
      return t == 'HOPITAL' || t == 'AMBULANCE';
    }).length;
    final countForces = nearbyAll.where((c) {
      final t = c.type.toUpperCase();
      return t == 'POLICE' || t == 'GENDARMERIE';
    }).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.44,
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0F9D58).withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la Station Galana
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F9D58).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.local_gas_station_rounded, color: Color(0xFF0F9D58), size: 24),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "STATION GALANA",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                        if (site.code != null && site.code!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            "[${site.code}]",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      site.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${site.locality ?? 'Madagascar'} • ${site.province ?? 'Zone Galana'}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _highlightedSite = null),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // En-tête section Secours & Filtres rapides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("🚨", style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  const Text(
                    "SECOURS LES PLUS PROCHES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${nearbyFiltered.length} contact(s)",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Onglets filtres rapides par catégorie de secours
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildNearbyFilterChip('ALL', "Tous (${nearbyAll.length})"),
                _buildNearbyFilterChip('POMPIER', "🚒 Pompiers ($countPompiers)"),
                _buildNearbyFilterChip('SANTE', "🏥 Santé ($countSante)"),
                _buildNearbyFilterChip('FORCES', "🛡️ Forces ($countForces)"),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liste défilante des contacts d'urgence proches
          Flexible(
            child: nearbyFiltered.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Aucun secours répertorié dans ce rayon.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickDialBtn("118", "Pompiers", const Color(0xFFDC2626)),
                            const SizedBox(width: 8),
                            _buildQuickDialBtn("117", "Police", const Color(0xFF4F46E5)),
                            const SizedBox(width: 8),
                            _buildQuickDialBtn("124", "SAMU", const Color(0xFF0284C7)),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: nearbyFiltered.length,
                    separatorBuilder: (_, _) => const Divider(height: 8, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final item = nearbyFiltered[index];
                      return InkWell(
                        onTap: () {
                          if (item.latitude != null && item.longitude != null) {
                            _mapController.move(
                              LatLng(item.latitude!, item.longitude!),
                              15.0,
                            );
                          }
                          widget.onShowDetail(item);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Row(
                            children: [
                              // Avatar type secours
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: item.typeColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    item.typeEmoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Infos & distance
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (item.distanceKm != null) ...[
                                          const SizedBox(width: 6),
                                          _buildDistanceBadge(item.distanceKm!),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${item.typeLabel} • ${item.locality}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Bouton d'appel direct
                              ElevatedButton.icon(
                                icon: const Icon(Icons.phone_in_talk, size: 13, color: Colors.white),
                                label: Text(
                                  item.contact1,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: item.typeColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => widget.onDirectCall(item.contact1, item.name),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyFilterChip(String key, String label) {
    final isSelected = _nearbyFilterType == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _nearbyFilterType = key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F9D58) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF0F9D58) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceBadge(double distanceKm) {
    final Color bg;
    final Color fg;
    if (distanceKm < 5.0) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (distanceKm < 15.0) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me_rounded, size: 9, color: fg),
          const SizedBox(width: 2),
          Text(
            _formatDistance(distanceKm),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDialBtn(String number, String label, Color color) {
    return InkWell(
      onTap: () => widget.onDirectCall(number, label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              "$label $number",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color iconColor = const Color(0xFF1E293B),
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, {IconData? icon, String? emoji}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: emoji != null
                  ? Text(emoji, style: const TextStyle(fontSize: 9))
                  : Icon(icon, color: Colors.white, size: 11),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
