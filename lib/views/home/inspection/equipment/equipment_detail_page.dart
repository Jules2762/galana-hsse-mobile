import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/equipment_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/inspection/equipment/equipment_list_view.dart';


class EquipmentDetailPage extends StatefulWidget {
  final EquipmentItemData? equipment;

  const EquipmentDetailPage({super.key, this.equipment});

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  late EquipmentItemData equipment;

  // Points de contrôle visuel
  bool sealIntact = true;
  bool pinIntact = true;
  bool hoseGood = true;
  bool pressureOk = true;
  bool accessibilityOk = true;
  bool signageOk = true;

  int photoCount = 0;
  late List<Map<String, String>> inspectionHistory;

  @override
  void initState() {
    super.initState();
    equipment = widget.equipment ??
        const EquipmentItemData(
          tagNumber: "EXT-P50-01",
          designation: "Extincteur 50kg Poudre sur roues",
          type: "Extincteur P50",
          site: "Terminal Pétrolier Toamasina",
          location: "Zone Cuves Sud - Poste Chargement",
          lastControlDate: "12 Oct 2026",
          nextDueDate: "12 Nov 2026",
          status: "Conforme",
          pressureStatus: "Normal (14 bars)",
        );

    final isNonConforme =
        equipment.status.toLowerCase().contains('non-conforme') ||
        equipment.status.toLowerCase().contains('requis');
    if (isNonConforme) {
      pinIntact = false;
      pressureOk = false;
    }

    inspectionHistory = [
      {
        "date": equipment.lastControlDate,
        "inspector": "Jules Rakoto (Inspecteur HSSE)",
        "type": "Contrôle Périodique Terrain",
        "status": equipment.status,
      },
      {
        "date": "14 Sep 2026",
        "inspector": "Marie Razafi (Maintenance)",
        "type": "Vérification Pression & Scellé",
        "status": "Conforme",
      },
      {
        "date": "15 Avr 2026",
        "inspector": "Bureau Veritas Madagascar",
        "type": "Audit Annuel & Poids de Charge",
        "status": "Conforme Certifié",
      },
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is EquipmentItemData) {
      setState(() {
        equipment = args;
        final isNonConforme =
            equipment.status.toLowerCase().contains('non-conforme') ||
            equipment.status.toLowerCase().contains('requis');
        if (isNonConforme) {
          pinIntact = false;
          pressureOk = false;
        }
      });
    }
  }

  void _showPerformControlBottomSheet() {
    final observationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isCurrentlyAllConforme = pressureOk &&
                pinIntact &&
                sealIntact &&
                hoseGood &&
                signageOk &&
                accessibilityOk;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fact_check,
                                color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Contrôle Mensuel de Sécurité",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  "${equipment.tagNumber} • ${equipment.type}",
                                  style: const TextStyle(
                                    fontSize: 12,
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
                      const Text(
                        "Grille de conformité terrain :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildCheckTile(
                        title:
                            "1. Manomètre de pression dans la plage verte (14 bars)",
                        value: pressureOk,
                        onChanged: (val) =>
                            setModalState(() => pressureOk = val ?? true),
                      ),
                      _buildCheckTile(
                        title: "2. Goupille de sécurité engagée et non forcée",
                        value: pinIntact,
                        onChanged: (val) =>
                            setModalState(() => pinIntact = val ?? true),
                      ),
                      _buildCheckTile(
                        title: "3. Scellé de garantie plastique intact et daté",
                        value: sealIntact,
                        onChanged: (val) =>
                            setModalState(() => sealIntact = val ?? true),
                      ),
                      _buildCheckTile(
                        title:
                            "4. Flexible, lance et buse en parfait état sans fissure",
                        value: hoseGood,
                        onChanged: (val) =>
                            setModalState(() => hoseGood = val ?? true),
                      ),
                      _buildCheckTile(
                        title:
                            "5. Signalétique d'identification visible et classe ABC conforme",
                        value: signageOk,
                        onChanged: (val) =>
                            setModalState(() => signageOk = val ?? true),
                      ),
                      _buildCheckTile(
                        title:
                            "6. Dégagement et accessibilité immédiate (rayon de 1m)",
                        value: accessibilityOk,
                        onChanged: (val) =>
                            setModalState(() => accessibilityOk = val ?? true),
                      ),

                      // ==================== ALERTE EN CAS D'ANOMALIE ====================
                      if (!isCurrentlyAllConforme) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFDC2626), size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Anomalie détectée : L'extincteur sera classé Non-conforme.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF991B1B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.correctiveAction,
                                  );
                                },
                                child: const Text(
                                  "Action",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Observation terrain
                      TextField(
                        controller: observationController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText:
                              "Remarques ou observations terrain (ex: scellé repositionné)...",
                          prefixIcon: Icon(Icons.comment_outlined, size: 18),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Photo justificative
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setModalState(() {
                                photoCount++;
                              });
                            },
                            icon: const Icon(Icons.camera_alt_outlined, size: 16),
                            label: Text(
                              photoCount > 0
                                  ? "$photoCount photo(s) jointe(s)"
                                  : "Preuve photo",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            isCurrentlyAllConforme
                                ? "Statut : Conforme"
                                : "Statut : Non-conforme",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCurrentlyAllConforme
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Annuler"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrentlyAllConforme
                                    ? AppColors.primary
                                    : const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text(
                                "Valider l'inspection",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context);
                                final isAllConforme = pressureOk &&
                                    pinIntact &&
                                    sealIntact &&
                                    hoseGood &&
                                    signageOk &&
                                    accessibilityOk;

                                final updated = await EquipmentService.performControl(
                                  equipment,
                                  isConforme: isAllConforme,
                                  pressureStatus: pressureOk ? "Normal (14 bars)" : "Pression anormale",
                                  observation: observationController.text.trim().isNotEmpty
                                      ? observationController.text.trim()
                                      : null,
                                  photoCount: photoCount,
                                );

                                if (!mounted) return;
                                setState(() {
                                  equipment = updated;
                                  inspectionHistory.insert(0, {
                                    "date": "Aujourd'hui (14 Oct 2026)",
                                    "inspector": "Jules Rakoto (Inspecteur HSSE)",
                                    "type": "Contrôle Mensuel Réglementaire",
                                    "status": isAllConforme ? "Conforme" : "Non-conforme",
                                  });
                                });

                                final isOnline = SyncService.instance.isOnline;
                                messenger.showSnackBar(

                                  SnackBar(
                                    duration: const Duration(seconds: 4),
                                    content: Row(
                                      children: [
                                        Icon(isOnline ? Icons.check_circle : Icons.cloud_off, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isOnline
                                                ? "Contrôle de ${equipment.tagNumber} enregistré et synchronisé avec l'API Galana !"
                                                : "Contrôle de ${equipment.tagNumber} enregistré en mode Hors-ligne ! Synchronisation automatique dès la reconnexion.",
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: isAllConforme ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                                  ),
                                );
                              },

                            ),
                          ),
                        ],
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

  Widget _buildCheckTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontSize: 12, height: 1.3)),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isConforme = equipment.status.toLowerCase() == 'conforme';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pop(context, equipment),
          ),
          title: Text(equipment.tagNumber),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: "Vignette de contrôle",
              onPressed: () {
                _showVignetteDialog();
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Exportation de la fiche d'équipement..."),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== HERO CARD ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.fire_extinguisher,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                equipment.tagNumber,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                equipment.designation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isConforme
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            equipment.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isConforme
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${equipment.site} • ${equipment.location}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== CARACTÉRISTIQUES TECHNIQUES ====================
              const Text(
                "Spécifications Techniques",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSpecRow("Type d'équipement", equipment.type),
                    _buildDivider(),
                    _buildSpecRow("Numéro de série", "SN-2021-GLN-0498"),
                    _buildDivider(),
                    _buildSpecRow("Fabricant / Marque", "Desautel Sécurité"),
                    _buildDivider(),
                    _buildSpecRow("Date de mise en service", "15/04/2021"),
                    _buildDivider(),
                    _buildSpecRow("Pression nominale", equipment.pressureStatus),
                    _buildDivider(),
                    _buildSpecRow(
                        "Dernière inspection", equipment.lastControlDate),
                    _buildDivider(),
                    _buildSpecRow("Prochaine échéance", equipment.nextDueDate),
                    _buildDivider(),
                    _buildSpecRow("Épreuve décennale", "15/04/2031"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== POINTS DE CONTRÔLE RÉCENTS ====================
              const Text(
                "Points de Contrôle de Sécurité",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildStatusItem(
                      title: "Manomètre de pression",
                      desc: pressureOk
                          ? "Aiguille dans la zone verte (14 bars)"
                          : "Pression anormale détectée",
                      isOk: pressureOk,
                    ),
                    _buildDivider(),
                    _buildStatusItem(
                      title: "Goupille de déclenchement",
                      desc: pinIntact
                          ? "En place, non déformée"
                          : "Goupille absente ou forcée",
                      isOk: pinIntact,
                    ),
                    _buildDivider(),
                    _buildStatusItem(
                      title: "Scellé de sécurité",
                      desc: sealIntact
                          ? "Plastique intact d'origine Galana"
                          : "Scellé rompu",
                      isOk: sealIntact,
                    ),
                    _buildDivider(),
                    _buildStatusItem(
                      title: "Flexible & Tromblon",
                      desc: hoseGood
                          ? "Caoutchouc souple sans craquelure"
                          : "Fissure détectée",
                      isOk: hoseGood,
                    ),
                    _buildDivider(),
                    _buildStatusItem(
                      title: "Panneau & Signalétique",
                      desc: signageOk
                          ? "Visible et identifié classe ABC"
                          : "Signalétique absente",
                      isOk: signageOk,
                    ),
                    _buildDivider(),
                    _buildStatusItem(
                      title: "Accessibilité physique",
                      desc: accessibilityOk
                          ? "Zone dégagée sans encombrement"
                          : "Accès encombré",
                      isOk: accessibilityOk,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== HISTORIQUE DES CONTRÔLES ====================
              const Text(
                "Historique des Inspections Terrain",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: List.generate(inspectionHistory.length, (index) {
                    final item = inspectionHistory[index];
                    final isLast = index == inspectionHistory.length - 1;
                    return Column(
                      children: [
                        _buildHistoryItem(
                          date: item["date"] ?? "",
                          inspector: item["inspector"] ?? "",
                          type: item["type"] ?? "",
                          status: item["status"] ?? "",
                        ),
                        if (!isLast) _buildDivider(),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  "Réaliser un Contrôle Terrain",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: _showPerformControlBottomSheet,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVignetteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Vignette de Contrôle", style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      "GALANA RUBIS - CONTRÔLE HSSE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      equipment.tagNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Dernier contrôle : ${equipment.lastControlDate}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Text(
                      "Prochaine échéance : ${equipment.nextDueDate}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.qr_code, size: 80, color: AppColors.textPrimary),
                    const SizedBox(height: 6),
                    const Text(
                      "Scannez pour consulter l'historique complet",
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Envoi vers l'imprimante thermique étiquettes..."),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text("Imprimer étiquette"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String desc,
    required bool isOk,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: isOk ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isOk ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isOk ? "Conforme" : "Anomalie",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOk ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String inspector,
    required String type,
    required String status,
  }) {
    final isOk = status.toLowerCase().contains("conforme");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isOk ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            child: Icon(
              isOk ? Icons.check : Icons.warning_amber,
              size: 14,
              color: isOk ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$date • $inspector",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOk ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOk ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
