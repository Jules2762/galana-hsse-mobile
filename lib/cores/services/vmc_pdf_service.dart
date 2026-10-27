import 'package:flutter/services.dart';
import 'package:gestion_hsse/views/home/inspection/vmc/vmc_list_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class VmcPdfService {
  /// Vert corporate officiel Galana
  static const PdfColor galanaGreen = PdfColor.fromInt(0xFF0F9D58);
  static const PdfColor tableHeaderGreen = PdfColor.fromInt(0xFFE6F4EA);
  static const PdfColor headerTeal = PdfColor.fromInt(0xFF007A78);
  static const PdfColor borderBlack = PdfColors.black;

  /// Génère le document PDF de la fiche officielle Galana (100% conforme aux 5 photos du classeur)
  static Future<Uint8List> generateVmcPdf(VmcItemData vmc,
      {List<Map<String, dynamic>>? customItems}) async {
    final pdf = pw.Document();

    // Tentative de chargement du logo Galana
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/logo-galana.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      try {
        final logoBytes = await rootBundle.load('assets/logo-galana.webp');
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (_) {
        logoImage = null;
      }
    }

    final String officialCode = getCodeForType(vmc.type);
    final List<Map<String, dynamic>> items = customItems ?? getItemsForVmc(vmc);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          if (officialCode == 'FOR01-HSSE-ACC') {
            // PHOTO 1: FICHE DE REMONTEE
            return _buildSafetyReportPdf(vmc, logoImage);
          } else if (officialCode == 'SAFETY MOMENTS') {
            // PHOTO 3: QUART D'HEURE SECURITE
            return _buildSafetyMomentsPdf(vmc, items);
          } else if (officialCode == 'SAFETY TRAINING' || officialCode == 'SAFETY AWARENESS') {
            // PHOTO 6: SAFETY TRAINING / SAFETY AWARENESS
            return _buildSafetyAwarenessPdf(vmc, items);
          } else {
            // PHOTO 5, 2, 4: INSPECTIONS (Station-Service, Camion, Magasins)
            return _buildInspectionPdf(vmc, items, logoImage, officialCode);
          }
        },
      ),
    );

    return pdf.save();
  }

  /// Ouvre l'interface native d'impression et de téléchargement PDF
  static Future<void> printOrShareVmc(VmcItemData vmc,
      {List<Map<String, dynamic>>? customItems}) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async =>
          generateVmcPdf(vmc, customItems: customItems),
      name: 'Fiche_VMC_${vmc.reference.replaceAll("#", "")}.pdf',
    );
  }

  // =========================================================================
  // 1. FICHE DE REMONTÉE (PHOTO 1 : FOR01-HSSE-ACC)
  // =========================================================================
  static pw.Widget _buildSafetyReportPdf(
      VmcItemData vmc, pw.MemoryImage? logoImage) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // En-tête à 3 compartiments
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 1.2),
          ),
          child: pw.Row(
            children: [
              // 1. Logo Galana (28%)
              pw.Container(
                width: 120,
                height: 52,
                padding: const pw.EdgeInsets.all(5),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(color: borderBlack, width: 1.2),
                  ),
                ),
                alignment: pw.Alignment.center,
                child: _buildLogoWidget(logoImage),
              ),
              // 2. Titre central (58%)
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 6),
                      child: pw.Text(
                        "FICHE DE REMONTEE",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: borderBlack,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: borderBlack, width: 1),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(3),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                      color: borderBlack, width: 1),
                                ),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "Galana Distribution Pétrolière",
                                style: const pw.TextStyle(fontSize: 7.5),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(3),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                      color: borderBlack, width: 1),
                                ),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "Date : 11/01/22",
                                style: const pw.TextStyle(fontSize: 7.5),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(3),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "Version : 02",
                                style: const pw.TextStyle(fontSize: 7.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 3. Code FOR01-HSSE-ACC (14%)
              pw.Container(
                width: 70,
                height: 52,
                padding: const pw.EdgeInsets.all(4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: borderBlack, width: 1.2),
                  ),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "FOR01-\nHSSE-ACC",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 8),

        // Section 1: Informations générales
        _buildSectionHeader("1. Informations générales"),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Expanded(child: _buildFormField("Filiale:", "Galana Madagascar")),
                  pw.Expanded(child: _buildFormField("Lieu/ ville:", vmc.site)),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildFormField("Date de l'évènement (aaaa/mm/jj):", vmc.date)),
                  pw.Expanded(child: _buildFormField("Heure:", "10:30")),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildFormField("Type d'évènement:", "Presqu'accident / Condition dangereuse")),
                  pw.Expanded(child: _buildFormField("Niveau de gravité:", "2 / 5 (Modéré - Échelle 0 à 5)")),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 6),

        // Section 2: Émetteur
        _buildSectionHeader("2. Emetteur"),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(child: _buildFormField("Nom:", vmc.inspector)),
              pw.Expanded(child: _buildFormField("Prénom:", "Jean")),
              pw.Expanded(child: _buildFormField("Fonction:", "Superviseur HSSE")),
              pw.Expanded(child: _buildFormField("Société:", "Galana")),
            ],
          ),
        ),

        pw.SizedBox(height: 6),

        // Section 3: Description détaillée des circonstances
        _buildSectionHeader("3. Description détaillée des circonstances (avec les mesures mises sur place pour assurer la sécurité, arrivée des secours,...)"),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          height: 65,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 70,
                child: _buildFormField("Heure:", "10:30"),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Description :", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Constat d'un suintement d'hydrocarbures sur le joint de bride de vanne lors de la ronde matinale. Isolement immédiat de la ligne et mise en place d'un bac de rétention.",
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 6),

        // Section 4: Conséquences
        _buildSectionHeader("4. Conséquences (humain, matériel, environmental, image...)"),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          height: 40,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Text(
            "Aucune conséquence corporelle ni blessure. Environnement : produit contenu dans le bac de rétention étanche, aucune pollution des sols.",
            style: const pw.TextStyle(fontSize: 7.5),
          ),
        ),

        pw.SizedBox(height: 6),

        // Section 5: Causes
        _buildSectionHeader("5. a) Causes immédiates"),
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          height: 32,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Text(
            "Usure du joint d'étanchéité sous pression cyclique.",
            style: const pw.TextStyle(fontSize: 7.5),
          ),
        ),
        _buildSectionHeader("b) Causes fondamentales"),
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          height: 32,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Text(
            "Périodicité de remplacement préventif à réajuster dans la GMAO pour les brides exposées aux intempéries.",
            style: const pw.TextStyle(fontSize: 7.5),
          ),
        ),

        pw.SizedBox(height: 6),

        // Section 6: Actions immédiates & plan d'actions
        _buildSectionHeader("6. Actions immédiates & plan d'actions"),
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          height: 45,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Text(
            "1. Isolement vanne amont & pose de boudins absorbants (Effectué immédiatement)\n2. Remplacement du joint de bride #ACT-041 (Assigné à Maintenance - Échéance 24h)\n3. Test d'étanchéité et remise en service contrôlée.",
            style: const pw.TextStyle(fontSize: 7.5),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. SAFETY MOMENTS (PHOTO 3 : QUART D'HEURE SECURITE)
  // =========================================================================
  static pw.Widget _buildSafetyMomentsPdf(
      VmcItemData vmc, List<Map<String, dynamic>> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bandeau titre bleu-vert pétrole officiel
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: const pw.BoxDecoration(color: headerTeal),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "SAFETY MOMENTS",
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.white,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "QUART D'HEURE SECURITE",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 10),

        // Détails du rassemblement
        pw.Text(
          "Détails du rassemblement",
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF9FAFB),
            border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Expanded(child: _buildFormField("Date :", vmc.date)),
                  pw.Expanded(child: _buildFormField("Heure :", "08:00")),
                ],
              ),
              pw.SizedBox(height: 4),
              _buildFormField("Site (Station Service/Camion/Agence/Magasin) :", vmc.site),
              pw.SizedBox(height: 4),
              _buildFormField("Animateur :", vmc.inspector),
            ],
          ),
        ),

        pw.SizedBox(height: 10),

        // Participants (Tableau des 13 lignes exactes comme sur la photo)
        pw.Text(
          "Participants:",
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: borderBlack, width: 0.8),
          columnWidths: const {
            0: pw.FixedColumnWidth(26),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(3),
            4: pw.FlexColumnWidth(2.5),
            5: pw.FixedColumnWidth(40),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: tableHeaderGreen),
              children: [
                _buildHeaderCell("N°", alignCenter: true),
                _buildHeaderCell("Nom"),
                _buildHeaderCell("Prénom"),
                _buildHeaderCell("Fonction"),
                _buildHeaderCell("Entité"),
                _buildHeaderCell("Visa", alignCenter: true),
              ],
            ),
            ...List.generate(13, (index) {
              Map<String, dynamic>? participant;
              if (items.isNotEmpty && items.first.containsKey('role') && index < items.length) {
                final it = items[index];
                final parts = (it["name"] ?? "").toString().split(" ");
                participant = {
                  "nom": parts.isNotEmpty ? parts.first : "",
                  "prenom": parts.length > 1 ? parts.sublist(1).join(" ") : "",
                  "fonction": it["role"]?.toString() ?? "Opérateur",
                  "entite": "Galana",
                };
              } else if (index < _sampleParticipants.length) {
                participant = _sampleParticipants[index];
              }
              return pw.TableRow(
                children: [
                  _buildBodyCell("${index + 1}", alignCenter: true),
                  _buildBodyCell(participant?["nom"] ?? ""),
                  _buildBodyCell(participant?["prenom"] ?? ""),
                  _buildBodyCell(participant?["fonction"] ?? ""),
                  _buildBodyCell(participant?["entite"] ?? ""),
                  _buildBodyCell(participant != null ? "Signé" : "",
                      alignCenter: true, isBold: true),
                ],
              );
            }),
          ],
        ),

        pw.SizedBox(height: 10),

        // Points abordés (5 lignes)
        pw.Text(
          "Points abordés:",
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        ...List.generate(5, (index) {
          final text = index < items.length ? items[index]["title"] : "";
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("${index + 1}. ", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Expanded(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
                    ),
                    padding: const pw.EdgeInsets.only(bottom: 1),
                    child: pw.Text(text.toString(), style: const pw.TextStyle(fontSize: 8)),
                  ),
                ),
              ],
            ),
          );
        }),

        pw.SizedBox(height: 10),

        // Activités, démonstrations, exemples concrets (4 lignes)
        pw.Text(
          "Activités, démonstrations, exemples concrets:",
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        ...List.generate(4, (index) {
          final demoTexts = [
            "Démonstration de pose et serrage de la pince de mise à la terre sur camion",
            "Contrôle visuel du manomètre de l'extincteur P50 et de la goupille de scellé",
            "Exercice pratique de balisage d'urgence sur piste de dépotage",
            "Vérification du contenu de la trousse de premiers secours et numéros d'urgence",
          ];
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("${index + 1}. ", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Expanded(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
                    ),
                    padding: const pw.EdgeInsets.only(bottom: 1),
                    child: pw.Text(demoTexts[index], style: const pw.TextStyle(fontSize: 8)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // =========================================================================
  // 3. SAFETY TRAINING / SAFETY AWARENESS (PHOTO 6 DU REGISTRE GALANA)
  // =========================================================================
  static pw.Widget _buildSafetyAwarenessPdf(
    VmcItemData vmc,
    List<Map<String, dynamic>> items,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 1. Bandeau supérieur bleu-vert pétrole officiel
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const pw.BoxDecoration(color: headerTeal),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "SAFETY TRAINING",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "SAFETY AWARENESS",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 10),

        // 2. Leader Commitment
        pw.Text(
          "Leader Commitment",
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF9FAFB),
            border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
          ),
          child: pw.Column(
            children: [
              _buildLeaderDottedRow("Nom :", vmc.inspector),
              pw.SizedBox(height: 4),
              _buildLeaderDottedRow("Fonction :", "Superviseur HSSE & Exploitation"),
              pw.SizedBox(height: 4),
              _buildLeaderDottedRow("Direction:", "Direction Logistique & Distribution / Réseau"),
            ],
          ),
        ),

        pw.SizedBox(height: 10),

        // 3. Détails de la formation
        pw.Text(
          "Détails de la formation",
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Table(
          border: pw.TableBorder.all(color: borderBlack, width: 0.8),
          columnWidths: const {
            0: pw.FixedColumnWidth(60),
            1: pw.FixedColumnWidth(75),
            2: pw.FixedColumnWidth(75),
            3: pw.FlexColumnWidth(3),
            4: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: headerTeal),
              children: [
                _buildWhiteHeaderCell("Date", alignCenter: true),
                _buildWhiteHeaderCell("Type(*)", alignCenter: true),
                _buildWhiteHeaderCell("Volet(**)", alignCenter: true),
                _buildWhiteHeaderCell("Intitulé", alignCenter: true),
                _buildWhiteHeaderCell("Intervenant", alignCenter: true),
              ],
            ),
            ...List.generate(18, (index) {
              final item = index < items.length ? items[index] : null;
              final date = item?["date"]?.toString() ?? "";
              final type = item?["type"]?.toString() ?? "";
              final volet = item?["volet"]?.toString() ?? "";
              final title = (item?["intitule"] ?? item?["title"])?.toString() ?? "";
              final speaker = (item?["intervenant"] ?? item?["participant"] ?? item?["speaker"])?.toString() ?? "";

              return pw.TableRow(
                children: [
                  _buildAwarenessCell(date, alignCenter: true),
                  _buildAwarenessCell(type, alignCenter: true),
                  _buildAwarenessCell(volet, alignCenter: true),
                  _buildAwarenessCell(title),
                  _buildAwarenessCell(speaker),
                ],
              );
            }),
          ],
        ),

        pw.SizedBox(height: 8),

        // 4. Notes de bas de page officielles Galana
        pw.Text(
          "(*) Type : formation, sensibilisation, induction, atelier",
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 1.5),
        pw.Text(
          "(**) Volet : Santé, Sécurité, Sûreté, Environnement",
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static pw.Widget _buildLeaderDottedRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 70,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 1),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
              ),
            ),
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildWhiteHeaderCell(String text, {bool alignCenter = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
      child: pw.Text(
        text,
        textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildAwarenessCell(String text, {bool alignCenter = false}) {
    return pw.Container(
      height: 16.5,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      alignment: alignCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        maxLines: 1,
        overflow: pw.TextOverflow.clip,
        textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.left,
        style: const pw.TextStyle(fontSize: 7),
      ),
    );
  }

  // =========================================================================
  // 4. INSPECTIONS : STATION, CAMION, MAGASINS (PHOTOS 5, 2, 4)
  // =========================================================================
  static pw.Widget _buildInspectionPdf(
    VmcItemData vmc,
    List<Map<String, dynamic>> items,
    pw.MemoryImage? logoImage,
    String officialCode,
  ) {
    String subTitle;
    String siteLabel = "Site :";
    if (officialCode == 'HSSE GALANA 2') {
      subTitle = "Inspection camion";
      siteLabel = "Camion :";
    } else if (officialCode == 'HSSE GALANA 3') {
      subTitle = "Visite Magasins & Agences";
      siteLabel = "Camion / Véhicule :";
    } else {
      subTitle = "1. Station-Service";
      siteLabel = "Site :";
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // En-tête officiel Galana Rubis (VISIBLE MANAGEMENT COMMITMENT)
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 1.2),
          ),
          child: pw.Row(
            children: [
              // Logo
              pw.Container(
                width: 130,
                height: 52,
                padding: const pw.EdgeInsets.all(5),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(color: borderBlack, width: 1.2),
                  ),
                ),
                alignment: pw.Alignment.center,
                child: _buildLogoWidget(logoImage),
              ),
              // Titre VMC
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 6),
                      child: pw.Text(
                        "VISIBLE MANAGEMENT COMMITMENT",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: borderBlack,
                          letterSpacing: 0.5,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: borderBlack, width: 1),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(3),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                      color: borderBlack, width: 1),
                                ),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "Galana Distribution Pétrolière",
                                style: const pw.TextStyle(fontSize: 7.5),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(3),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                "Date de création : 21/02/23 - Rev.00",
                                style: const pw.TextStyle(fontSize: 7.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 8),

        // Titre de type (ex: 1. Station-Service / Inspection camion)
        pw.Text(
          subTitle,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: borderBlack,
          ),
        ),

        pw.SizedBox(height: 6),

        // Bandeau Vert Galana (#0F9D58)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: galanaGreen,
            border: pw.Border.all(color: borderBlack, width: 1),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPdfMetaRow("Date :", vmc.date),
                    pw.SizedBox(height: 2),
                    _buildPdfMetaRow(siteLabel, vmc.site),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPdfMetaRow("Évaluateur :", vmc.inspector),
                    pw.SizedBox(height: 2),
                    _buildPdfMetaRow("Accompagnateur(s) :",
                        "Mireille R. (HSSE), Chef de poste"),
                  ],
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 6),

        // Grille des N items (13 pour Station, 14 pour Camion, 7 pour Magasins)
        pw.Table(
          border: pw.TableBorder.all(color: borderBlack, width: 0.8),
          columnWidths: const {
            0: pw.FixedColumnWidth(24),
            1: pw.FlexColumnWidth(5),
            2: pw.FixedColumnWidth(28),
            3: pw.FixedColumnWidth(28),
            4: pw.FlexColumnWidth(4),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: tableHeaderGreen),
              children: [
                _buildHeaderCell("N°", alignCenter: true),
                _buildHeaderCell("Désignation"),
                _buildHeaderCell("Oui", alignCenter: true),
                _buildHeaderCell("Non", alignCenter: true),
                _buildHeaderCell("Obs"),
              ],
            ),
            ...items.map((it) {
              final ans = it["answer"]?.toString().toUpperCase();
              final bool isYes = ans == "OUI" || it["yes"] == true;
              final bool isNo = ans == "NON" || it["yes"] == false;
              final bool isNa = ans == "N/A" || (it["yes"] == null && ans == null);
              return pw.TableRow(
                children: [
                  _buildBodyCell(it["num"].toString(), alignCenter: true),
                  _buildBodyCell(it["title"].toString()),
                  _buildBodyCell(isYes ? "✓" : "",
                      alignCenter: true, isBold: true),
                  _buildBodyCell(isNo ? "✓" : (isNa ? "N/A" : ""),
                      alignCenter: true, isBold: true, isRed: isNo),
                  _buildBodyCell(it["obs"]?.toString() ?? ""),
                ],
              );
            }),
          ],
        ),

        pw.SizedBox(height: 8),

        // Encadré Recommandations (comme sur les photos 5, 2, 4)
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderBlack, width: 0.8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: const pw.BoxDecoration(
                  color: tableHeaderGreen,
                  border: pw.Border(
                    bottom: pw.BorderSide(color: borderBlack, width: 0.8),
                  ),
                ),
                child: pw.Text(
                  "Recommandations :",
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: borderBlack,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  vmc.deviations == 0
                      ? "Standards de sécurité HSSE Galana respectés lors de la visite. Continuer le suivi régulier."
                      : "- Remplacer immédiatement le composant présentant un écart lors du contrôle terrain.\n- Sensibiliser l'équipe aux contrôles avant démarrage.",
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
        ),

        pw.Spacer(),

        // Bas de page
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Document confidentiel à diffusion contrôlée",
              style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
            ),
            pw.Text(
              officialCode,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: borderBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // HELPERS INTERNES
  // =========================================================================
  static pw.Widget _buildLogoWidget(pw.MemoryImage? logoImage) {
    if (logoImage != null) {
      return pw.Image(logoImage, fit: pw.BoxFit.contain);
    }
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          "GALANA",
          style: pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
            color: galanaGreen,
          ),
        ),
        pw.Text(
          "GROUPE RUBIS",
          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: const pw.BoxDecoration(color: galanaGreen),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildFormField(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          "$label ",
          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 7.5),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfMetaRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          "$label ",
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text, {bool alignCenter = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: borderBlack,
        ),
      ),
    );
  }

  static pw.Widget _buildBodyCell(
    String text, {
    bool alignCenter = false,
    bool isBold = false,
    bool isRed = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
      child: pw.Text(
        text,
        textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isRed ? PdfColors.red : borderBlack,
        ),
      ),
    );
  }

  static final List<Map<String, String>> _sampleParticipants = [
    {"nom": "Rakoto", "prenom": "Jean", "fonction": "Chef de Piste", "entite": "Galana"},
    {"nom": "Kely", "prenom": "Marc", "fonction": "Chauffeur", "entite": "Transporteur"},
    {"nom": "Tsiresy", "prenom": "Haja", "fonction": "Opérateur", "entite": "Galana"},
    {"nom": "Randria", "prenom": "Mireille", "fonction": "Superviseur", "entite": "HSSE"},
    {"nom": "Bao", "prenom": "Alain", "fonction": "Technicien", "entite": "Maintenance"},
    {"nom": "Andriana", "prenom": "Faly", "fonction": "Pompiste", "entite": "Galana"},
  ];

  /// Détermine le code officiel Galana selon le type de VMC
  static String getCodeForType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('camion') || lower.contains('cc') || lower.contains('citerne') || lower.contains('galana 2')) return 'HSSE GALANA 2';
    if (lower.contains('magasin') || lower.contains('agence') || lower.contains('galana 3')) return 'HSSE GALANA 3';
    if (lower.contains('moment')) return 'SAFETY MOMENTS';
    if (lower.contains('report') || lower.contains('remontée')) return 'FOR01-HSSE-ACC';
    if (lower.contains('awareness') || lower.contains('sensibilisation') || lower.contains('training')) return 'SAFETY TRAINING';
    return 'HSSE GALANA 1';
  }

  /// Récupère les items selon les données de la VMC
  static List<Map<String, dynamic>> getItemsForVmc(VmcItemData vmc) {
    return getVmcItemsForType(vmc.type, deviations: vmc.deviations);
  }

  /// Retourne la liste exacte des items officiels Galana pour un type de VMC donné
  static List<Map<String, dynamic>> getVmcItemsForType(String type, {int deviations = 0}) {
    final lower = type.toLowerCase();

    if (lower.contains('camion') || lower.contains('cc') || lower.contains('citerne') || lower.contains('galana 2')) {
      // 14 points Inspection Camion CC (PHOTO 2 : HSSE GALANA 2)
      return [
        {"num": "1", "title": "Port EPI (Equipage camion)", "yes": true, "obs": "Equipage camion équipé"},
        {"num": "2", "title": "Documents de bord (Assurance, visite technique, Apave & Madauto, disponible et valide)", "yes": true, "obs": "Documents à jour dans la cabine"},
        {"num": "3", "title": "Présence de 02 extincteurs ABC 09kg (en bon état, valide)", "yes": true, "obs": "Coffres extérieurs fermés et scellés"},
        {"num": "4", "title": "Présence d'un extincteur de cabine 1kg (en bon état, valide)", "yes": true, "obs": "Extincteur cabine en place"},
        {"num": "5", "title": "Câble de mise à la terre (en bon état, pinces bien fixées)", "yes": deviations == 0, "obs": deviations == 0 ? "Pince et continuité conformes" : "Pince à brosser"},
        {"num": "6", "title": "Flexible (en bon état, valide et bouchonnée)", "yes": true, "obs": "Bouchon étanche en place"},
        {"num": "7", "title": "Cales de roues (en bon état et conforme)", "yes": true, "obs": "02 cales métalliques présentes"},
        {"num": "8", "title": "Panneau Orange (métallique, en bon état, avant et arrière)", "yes": true, "obs": "Plaques 1202 / 1203 visibles"},
        {"num": "9", "title": "Panneau Losange de type ADR (Rouge, deux côtés latérales)", "yes": true, "obs": "Pictogrammes classe 3 en bon état"},
        {"num": "10", "title": "Feux AV & AR (en bon état et opérationnel)", "yes": true, "obs": "Feux de stop et clignotants opérationnels"},
        {"num": "11", "title": "Roues (en bon état, pneu identique par essieu)", "yes": true, "obs": "Témoins d'usure conformes"},
        {"num": "12", "title": "Coupe circuit (opérationnel)", "yes": true, "obs": "Testé et déclenchement immédiat"},
        {"num": "13", "title": "Batteries (présence de capuchon de borne)", "yes": true, "obs": "Cosses protégées et serrées"},
        {"num": "14", "title": "Vannes & trous d'homme (en bon état, non fuyarde, présence de soudure d'intégrité)", "yes": true, "obs": "Plombs et joints étanches"},
      ];
    } else if (lower.contains('magasin') || lower.contains('agence') || lower.contains('galana 3')) {
      // 7 points Visite Magasins & Agences (PHOTO 4 : HSSE GALANA 3)
      return [
        {"num": "1", "title": "Ordre et propreté du site", "yes": true, "obs": "Locaux ordonnés et sols dégagés"},
        {"num": "2", "title": "Extincteur (accroché, en bon état et valide)", "yes": true, "obs": "Pression verte et signalétique conforme"},
        {"num": "3", "title": "Parking (véhicule stationné en position de départ)", "yes": true, "obs": "Véhicules orientés vers la sortie"},
        {"num": "4", "title": "Eclairage (en bon état, opérationnel)", "yes": true, "obs": "Bureaux et entrepôt bien éclairés"},
        {"num": "5", "title": "Stockage (lourd en bas, ordonné, présence aire de circulation)", "yes": deviations == 0, "obs": deviations == 0 ? "Rayonnages conformes" : "Palettes en allée à dégager"},
        {"num": "6", "title": "Absence de câbles nus et pas de multiprise en cascade", "yes": true, "obs": "Câblage sous goulotte"},
        {"num": "7", "title": "Trousse de secours (liste des contenus, valide)", "yes": true, "obs": "Produits non périmés et inventaire complet"},
      ];
    } else if (lower.contains('moment')) {
      // 5 points Safety Moment (PHOTO 3 : SAFETY MOMENTS)
      return [
        {"num": "1", "title": "Sensibilisation aux risques électrostatiques & mise à la terre", "yes": true, "obs": "Consigne expliquée à l'équipe"},
        {"num": "2", "title": "Port obligatoire des EPI en zone ATEX", "yes": true, "obs": "Rappel sur les chaussures dissipatrices"},
        {"num": "3", "title": "Procédure d'arrêt d'urgence et alarme sonore", "yes": true, "obs": "Localisation des coups de poing rappelée"},
        {"num": "4", "title": "Exercice pratique d'utilisation d'extincteur P50", "yes": true, "obs": "Démonstration réalisée par le chef de quart"},
        {"num": "5", "title": "Émargement et retour d'expérience des opérateurs", "yes": true, "obs": "Questions traitées en séance"},
      ];
    } else if (lower.contains('awareness') || lower.contains('sensibilisation') || lower.contains('training')) {
      // Sessions Safety Awareness / Training (PHOTO 6 : SAFETY TRAINING / SAFETY AWARENESS)
      return [
        {
          "date": "12/10/2026",
          "type": "formation",
          "volet": "Santé",
          "title": "Port des EPI spécifiques & manipulation des produits chimiques",
          "participant": "Mireille R. (HSSE)",
        },
        {
          "date": "12/10/2026",
          "type": "sensibilisation",
          "volet": "Sécurité",
          "title": "Gestes et postures lors de la manutention des fûts de lubrifiants",
          "participant": "Jean Rakoto (Chef de Piste)",
        },
        {
          "date": "13/10/2026",
          "type": "atelier",
          "volet": "Environnement",
          "title": "Déploiement du kit anti-pollution et gestion des terres souillées",
          "participant": "Haja Tsiresy (Opérateur)",
        },
        {
          "date": "14/10/2026",
          "type": "induction",
          "volet": "Sûreté",
          "title": "Consignes de sécurité visiteur et règles de circulation des engins",
          "participant": "Alain Bao (Maintenance)",
        },
      ];
    } else if (lower.contains('report') || lower.contains('remontée')) {
      // Safety Report (PHOTO 1 : FOR01-HSSE-ACC)
      return [
        {"num": "1", "title": "Signalement immédiat de l'anomalie au chef de quart", "yes": true, "obs": "Signalé sous 15 minutes"},
        {"num": "2", "title": "Mise en sécurité immédiate de la zone d'intervention", "yes": true, "obs": "Balisage et arrêt de pompe"},
        {"num": "3", "title": "Déploiement des absorbants ou bacs de rétention", "yes": true, "obs": "Kit anti-pollution déployé"},
        {"num": "4", "title": "Notification à la direction HSSE et planification action", "yes": true, "obs": "Action corrective #ACT-041 créée"},
      ];
    } else {
      // 13 points Station-Service SS (PHOTO 5 : HSSE GALANA 1)
      return [
        {"num": "1", "title": "Ordre et propreté du site", "yes": true, "obs": "Piste propre, absorbants disponibles"},
        {"num": "2", "title": "Port d'EPI (Chef de piste, pompiste, graisseurs, etc.)", "yes": true, "obs": "Casquette, gilet et chaussures S3 conformes"},
        {"num": "3", "title": "Parking (véhicule stationné en position de départ)", "yes": true, "obs": "Sens de circulation et stationnement respectés"},
        {"num": "4", "title": "Extincteur (accroché, accessible, en bon état et valide)", "yes": true, "obs": "Extincteurs sur îlots dégagés et scellés"},
        {"num": "5", "title": "Bac à sable (en bon état, rempli, et présence d'une pelle)", "yes": true, "obs": "Sable sec et pelle en place"},
        {"num": "6", "title": "Distributeur (pas de fuite, flexible valide et en bon état)", "yes": deviations == 0, "obs": deviations == 0 ? "Aucun suintement" : "Remplacement d'embout prévu"},
        {"num": "7", "title": "Events (identifié, relié à la terre, pas de véhicule stationné)", "yes": true, "obs": "Mise à la terre vérifiée"},
        {"num": "8", "title": "Détecteur de fuite (en bon état, opérationnel)", "yes": true, "obs": "Voyant au vert sur la baie de contrôle"},
        {"num": "9", "title": "Bouche de dépotage (cadenassé, identifié, relié individuellement à la terre, exempt d'eau)", "yes": true, "obs": "Vannes cadenassées"},
        {"num": "10", "title": "Armoire électrique (fermé à clef, pas de câble nus ou mal isolé)", "yes": true, "obs": "Armoire verrouillée"},
        {"num": "11", "title": "Eclairage (en bon état, opérationnel)", "yes": true, "obs": "Éclairage sous auvent fonctionnel"},
        {"num": "12", "title": "Toilettes & Sanitaires (en bon état, propre)", "yes": true, "obs": "Sanitaires clients et staff propres"},
        {"num": "13", "title": "Portes, fenêtres, volets roulants, grilles de protection (intègre, serrure opérationnelle)", "yes": true, "obs": "Serrures testées"},
      ];
    }
  }
}
