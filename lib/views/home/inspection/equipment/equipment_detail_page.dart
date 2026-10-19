import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/services/camera_service.dart';
import 'package:gestion_hsse/cores/services/equipment_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';

class EquipmentDetailPage extends StatefulWidget {
  final EquipmentMonitoringData? monitoring;
  final EquipmentItemData? equipment;

  const EquipmentDetailPage({
    super.key,
    this.monitoring,
    this.equipment,
  });

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  late EquipmentMonitoringData _monitoring;
  bool _initialized = false;
  String _selectedFilter = 'Tous'; // 'Tous', 'Conformes', 'Anomalies'
  String? _selectedCategory; // category filter chip

  @override
  void initState() {
    super.initState();
    if (widget.monitoring != null) {
      _monitoring = widget.monitoring!;
      _initialized = true;
    } else if (widget.equipment != null) {
      final e = widget.equipment!;
      _monitoring = EquipmentMonitoringData(
        id: e.monitoringId ?? e.id ?? 1,
        reference: e.tagNumber,
        siteName: e.site,
        date: e.lastControlDate,
        status: e.inspectionStatus,
        inspector: "Inspecteur HSSE",
        items: [e],
      );
      _initialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is EquipmentMonitoringData) {
        setState(() {
          _monitoring = args;
          _initialized = true;
        });
      } else if (args is EquipmentItemData) {
        setState(() {
          _monitoring = EquipmentMonitoringData(
            id: args.monitoringId ?? args.id ?? 1,
            reference: args.tagNumber,
            siteName: args.site,
            date: args.lastControlDate,
            status: args.inspectionStatus,
            inspector: "Inspecteur HSSE",
            items: [args],
          );
          _initialized = true;
        });
      } else {
        // Fallback par défaut
        setState(() {
          _monitoring = const EquipmentMonitoringData(
            id: 1,
            reference: "#EQ-1",
            siteName: "Station Majunga",
            date: "16 Oct 2026",
            status: "En cours",
            inspector: "Jules Rakoto",
            items: [],
          );
          _initialized = true;
        });
      }
    }
  }

  Future<void> _refreshMonitoring() async {
    final updated = await EquipmentService.getMonitoringById(_monitoring.id);
    if (updated != null && mounted) {
      setState(() {
        _monitoring = updated;
      });
    }
  }

  List<EquipmentItemData> get _filteredItems {
    return _monitoring.items.where((it) {
      if (_selectedFilter == 'Conformes' && !it.conformity) return false;
      if (_selectedFilter == 'Anomalies' && it.conformity) return false;
      if (_selectedCategory != null && _selectedCategory != 'Tous') {
        if (it.type != _selectedCategory) return false;
      }
      return true;
    }).toList();
  }

  Color get _statusBgColor {
    final s = _monitoring.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFFEF3C7);
    } else if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFFDBEAFE);
    } else if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed') {
      return const Color(0xFFDCFCE7);
    } else if (s.contains('annul') || s == 'cancelled') {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFF1F5F9);
  }

  Color get _statusTextColor {
    final s = _monitoring.status.toLowerCase();
    if (s.contains('planifi') || s.contains('brouillon') || s == 'draft') {
      return const Color(0xFFB45309);
    } else if (s.contains('cours') || s == 'in_progress') {
      return const Color(0xFF1D4ED8);
    } else if (s.contains('termin') || s.contains('clôtur') || s.contains('clotur') || s == 'completed') {
      return const Color(0xFF15803D);
    } else if (s.contains('annul') || s == 'cancelled') {
      return const Color(0xFFB91C1C);
    }
    return const Color(0xFF475569);
  }

  Color get _complianceColor {
    final rate = _monitoring.calculatedRate;
    if (rate >= 90) return const Color(0xFF10B981);
    if (rate >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  void _changeStatus(String newStatus) async {
    final updated = await EquipmentService.updateMonitoringStatus(_monitoring.id, newStatus);
    if (updated != null && mounted) {
      setState(() {
        _monitoring = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Statut du suivi mis à jour : $newStatus"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleItemConformity(EquipmentItemData item) async {
    final newConformity = !item.conformity;
    final updatedItem = await EquipmentService.updateItemConformity(
      _monitoring.id,
      item,
      newConformity,
    );

    final updatedItems = List<EquipmentItemData>.from(_monitoring.items);
    final idx = updatedItems.indexWhere((i) =>
        (item.id != null && i.id != null && i.id == item.id) || i.tagNumber == item.tagNumber);
    if (idx != -1) {
      updatedItems[idx] = updatedItem;
    }

    final total = updatedItems.length;
    final confCount = updatedItems.where((i) => i.conformity).length;
    final newRate = total > 0 ? (confCount / total) * 100.0 : 100.0;

    setState(() {
      _monitoring = _monitoring.copyWith(
        items: updatedItems,
        conformityRate: newRate,
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.designation} marqué ${newConformity ? 'Conforme ✓' : 'Non-conforme ⚠'}"),
        backgroundColor: newConformity ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteItem(EquipmentItemData item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer ce matériel ?"),
        content: Text("Voulez-vous retirer '${item.designation}' de cette session de contrôle ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await EquipmentService.deleteItemFromMonitoring(_monitoring.id, item);
      final updatedItems = List<EquipmentItemData>.from(_monitoring.items);
      updatedItems.removeWhere((i) =>
          (item.id != null && i.id != null && i.id == item.id) || i.tagNumber == item.tagNumber);

      final total = updatedItems.length;
      final confCount = updatedItems.where((i) => i.conformity).length;
      final newRate = total > 0 ? (confCount / total) * 100.0 : 100.0;

      setState(() {
        _monitoring = _monitoring.copyWith(
          items: updatedItems,
          conformityRate: newRate,
        );
      });
    }
  }

  void _addItemPhoto(EquipmentItemData item) async {
    final path = await CameraService.pickImage(context);
    if (path != null) {
      final updatedItem = await EquipmentService.updateItemConformity(
        _monitoring.id,
        item,
        item.conformity,
        newPhotoPaths: [path],
      );

      final updatedItems = List<EquipmentItemData>.from(_monitoring.items);
      final idx = updatedItems.indexWhere((i) =>
          (item.id != null && i.id != null && i.id == item.id) || i.tagNumber == item.tagNumber);
      if (idx != -1) {
        updatedItems[idx] = updatedItem;
      }
      setState(() {
        _monitoring = _monitoring.copyWith(items: updatedItems);
      });
    }
  }

  /// Dialogue de confirmation pour clôturer le suivi matériel
  void _showClosureDialog() {
    final int total = _monitoring.totalEquipments;
    final int anomalies = _monitoring.anomalyCount;
    final double rate = _monitoring.calculatedRate;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_outline, color: Color(0xFF15803D), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Clôturer le suivi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vous êtes sur le point de clôturer ce suivi matériel pour ${_monitoring.siteName} :",
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Matériels contrôlés :", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Text("$total", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Taux de conformité :", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Text(
                        "${rate.toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: rate >= 90 ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  if (anomalies > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Anomalies constatées :", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text("$anomalies", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFDC2626))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Le statut sera marqué comme 'Clôturée'. Vous pourrez toujours consulter les données.",
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _changeStatus("Clôturée");
            },
            icon: const Icon(Icons.check, size: 18, color: Colors.white),
            label: const Text(
              "Confirmer la clôture",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet d'ajout d'équipement unitaire sur le terrain (sans saisie de quantité)
  void _showAddEquipmentSheet() {
    final nameController = TextEditingController();
    final locationController = TextEditingController(text: "Piste distribution");
    final commentController = TextEditingController();
    String selectedType = "Extincteur P50";
    bool isConforme = true;
    final List<String> localPhotos = [];

    final types = const [
      "Extincteur P50",
      "Extincteur P9",
      "Extincteur P6",
      "Extincteur CO2",
      "RIA",
      "Cuves & Bacs",
      "Matériel & Outils",
      "Déchets & Poubelles",
      "Sécurité Incendie",
      "Signalétique",
      "Autre / Divers",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.90,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_moderator_rounded,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ajouter un matériel à contrôler",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  "Contrôle unitaire sur le terrain (1 matériel = 1 unité)",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // 1. Nom / Désignation
                      const Text(
                        "Désignation du matériel *",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Ex: Extincteur 50kg Poudre Îlot 1",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.build_circle_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Type & Emplacement
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Type d'équipement *",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedType,
                                      isExpanded: true,
                                      items: types.map((t) {
                                        return DropdownMenuItem(
                                          value: t,
                                          child: Text(t, style: const TextStyle(fontSize: 12)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setModalState(() => selectedType = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Emplacement *",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: locationController,
                                  decoration: InputDecoration(
                                    hintText: "Ex: Piste, Boutique...",
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Conformité
                      const Text(
                        "Conformité constatée *",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => isConforme = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isConforme ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isConforme ? const Color(0xFF16A34A) : Colors.grey.shade300,
                                    width: isConforme ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: isConforme ? const Color(0xFF15803D) : Colors.grey.shade500,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Conforme",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isConforme ? const Color(0xFF15803D) : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => isConforme = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isConforme ? const Color(0xFFFEE2E2) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !isConforme ? const Color(0xFFDC2626) : Colors.grey.shade300,
                                    width: !isConforme ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: !isConforme ? const Color(0xFFB91C1C) : Colors.grey.shade500,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Non-conforme",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: !isConforme ? const Color(0xFFB91C1C) : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4. Observation
                      const Text(
                        "Observations / Anomalies",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: commentController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Ex: Pression OK, goupille vérifiée...",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 5. Photos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Photos justificatives",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final p = await CameraService.pickImage(ctx);
                              if (p != null) {
                                setModalState(() => localPhotos.add(p));
                              }
                            },
                            icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                            label: const Text("Ajouter"),
                          ),
                        ],
                      ),
                      if (localPhotos.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: localPhotos.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (c, i) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(localPhotos[i]),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: InkWell(
                                      onTap: () => setModalState(() => localPhotos.removeAt(i)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Bouton Valider
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final name = nameController.text.trim().isNotEmpty
                                ? nameController.text.trim()
                                : selectedType;

                            final newItem = await EquipmentService.addItemToMonitoring(
                              _monitoring.id,
                              name: name,
                              type: selectedType,
                              isConforme: isConforme,
                              location: locationController.text.trim(),
                              comment: commentController.text.trim().isNotEmpty
                                  ? commentController.text.trim()
                                  : null,
                              photoPaths: localPhotos,
                            );

                            final updatedItems = List<EquipmentItemData>.from(_monitoring.items);
                            updatedItems.insert(0, newItem);
                            final total = updatedItems.length;
                            final confCount = updatedItems.where((i) => i.conformity).length;
                            final newRate = total > 0 ? (confCount / total) * 100.0 : 100.0;

                            final isPlanifiee = _monitoring.status.toLowerCase().contains('planifi') ||
                                _monitoring.rawStatus.toUpperCase() == 'DRAFT';
                            final nextStatus = isPlanifiee ? 'En cours' : _monitoring.status;
                            final nextRawStatus = isPlanifiee ? 'IN_PROGRESS' : _monitoring.rawStatus;

                            setState(() {
                              _monitoring = _monitoring.copyWith(
                                items: updatedItems,
                                conformityRate: newRate,
                                status: nextStatus,
                                rawStatus: nextRawStatus,
                              );
                            });

                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            "Enregistrer le matériel",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImageDialog(String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: path.startsWith('http')
                  ? Image.network(path, fit: BoxFit.contain)
                  : Image.file(File(path), fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int total = _monitoring.totalEquipments;
    final int conformes = _monitoring.conformeCount;
    final int anomalies = _monitoring.anomalyCount;
    final double rate = _monitoring.calculatedRate;
    final items = _filteredItems;
    final categoryCounts = _monitoring.categoryCounts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _monitoring.siteName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "${_monitoring.reference} • ${_monitoring.date}",
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_monitoring.status != 'Clôturée')
            IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded, size: 24),
              onPressed: _showClosureDialog,
              tooltip: "Clôturer le suivi",
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'Planifiée' || val == 'En cours' || val == 'Clôturée' || val == 'Annulée') {
                _changeStatus(val);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                enabled: false,
                child: Text("Changer le statut :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const PopupMenuItem(value: 'Planifiée', child: Text("Planifiée")),
              const PopupMenuItem(value: 'En cours', child: Text("En cours")),
              const PopupMenuItem(value: 'Clôturée', child: Text("Clôturer le suivi")),
              const PopupMenuItem(value: 'Annulée', child: Text("Annuler")),
            ],
          ),
        ],
      ),
      floatingActionButton: _monitoring.status == 'Clôturée'
          ? null
          : FloatingActionButton.extended(
              heroTag: 'fab_add_equipment',
              onPressed: _showAddEquipmentSheet,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
              label: const Text(
                "+ Matériel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
      body: RefreshIndicator(
        onRefresh: _refreshMonitoring,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== 1. EN-TÊTE SESSION DE CONTRÔLE ====================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _monitoring.siteName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _monitoring.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _monitoring.inspector,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _monitoring.date,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    if (_monitoring.observations != null && _monitoring.observations!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _monitoring.observations!,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
                      ),
                    ],
                    if (_monitoring.status != 'Clôturée') ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showClosureDialog,
                          icon: const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF15803D)),
                          label: const Text(
                            "Clôturer ce suivi matériel",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D), fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF16A34A)),
                            backgroundColor: const Color(0xFFF0FDF4),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_rounded, color: Color(0xFF15803D), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Suivi matériel clôturé (${_monitoring.calculatedRate.toStringAsFixed(0)}% conforme)",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================== 2. SCORECARD DE CONFORMITÉ & CATÉGORIES ====================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Taux de conformité global",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          total > 0 ? "${rate.toStringAsFixed(0)}%" : "N/A",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _complianceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: total > 0 ? rate / 100.0 : 0.0,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(_complianceColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Badges de comptage
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                Text("$total", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const Text("Matériels", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text("✓ $conformes",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF15803D))),
                                const Text("Conformes", style: TextStyle(fontSize: 10, color: Color(0xFF15803D))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: anomalies > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: anomalies > 0 ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text("⚠ $anomalies",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: anomalies > 0 ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
                                    )),
                                Text(
                                  "Anomalies",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: anomalies > 0 ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Répartition par catégorie (comptage dynamique count())
                    if (categoryCounts.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        "Inventaire contrôlé par type :",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: categoryCounts.entries.map((entry) {
                          final isCatSelected = _selectedCategory == entry.key;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (_selectedCategory == entry.key) {
                                  _selectedCategory = null;
                                } else {
                                  _selectedCategory = entry.key;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCatSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCatSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Text(
                                "${entry.value} ${entry.key}",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isCatSelected ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== 3. SECTION MATÉRIELS CONTRÔLÉS ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Matériels contrôlés (${items.length})",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  // Filtres Conforme / Anomalie
                  Row(
                    children: [
                      _buildFilterPill("Tous"),
                      const SizedBox(width: 4),
                      _buildFilterPill("Conformes"),
                      const SizedBox(width: 4),
                      _buildFilterPill("Anomalies"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Liste des équipements
              if (items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        "Aucun matériel dans cette session",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Ajoutez les équipements présents sur place pour démarrer votre contrôle unitaire.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddEquipmentSheet,
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text(
                          "Ajouter un matériel",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final item = items[idx];
                    return _buildEquipmentItemCard(item);
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentItemCard(EquipmentItemData item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.conformity
              ? AppColors.border.withValues(alpha: 0.8)
              : const Color(0xFFFCA5A5),
          width: item.conformity ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Nom + Bouton Toggle Conformité
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.designation,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.type,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            item.location,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bouton toggle conformité
              InkWell(
                onTap: () => _toggleItemConformity(item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.conformity ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.conformity ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.conformity ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                        size: 14,
                        color: item.conformity ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.conformity ? "Conforme" : "Non-conforme",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.conformity ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Observation
          if (item.comment != null && item.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.comment!,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
              ),
            ),
          ],

          // Galerie Photos
          if (item.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 55,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.attachments.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (ctx, pIdx) {
                  final photoUrl = item.attachments[pIdx];
                  return InkWell(
                    onTap: () => _showImageDialog(photoUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: photoUrl.startsWith('http')
                          ? Image.network(photoUrl, width: 55, height: 55, fit: BoxFit.cover)
                          : Image.file(File(photoUrl), width: 55, height: 55, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 6),

          // Actions du matériel (+ Photo, Supprimer)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _addItemPhoto(item),
                icon: const Icon(Icons.add_a_photo_outlined, size: 14),
                label: const Text("Photo", style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _deleteItem(item),
                icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                label: const Text("Retirer", style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
