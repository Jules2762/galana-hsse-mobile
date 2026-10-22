import 'package:flutter/services.dart';
import 'package:gestion_hsse/views/home/inspection/checklist/checklist_list_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ChecklistPdfService {
  static const PdfColor galanaGreen = PdfColor.fromInt(0xFF0F9D58);
  static const PdfColor headerTeal = PdfColor.fromInt(0xFF007A78);
  static const PdfColor tableHeaderBg = PdfColor.fromInt(0xFFE6F4EA);
  static const PdfColor borderBlack = PdfColors.black;

  /// Génère le document PDF officiel de contrôle Checklist Galana
  static Future<Uint8List> generateChecklistPdf(
    ChecklistItemData checklist, {
    List<Map<String, dynamic>>? items,
  }) async {
    final pdf = pw.Document();

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

    final points = items ?? [];
    final conformCount = points.where((p) => p['answer'] == 'OUI' || p['yes'] == true).length;
    final devCount = points.where((p) => p['answer'] == 'NON' || p['yes'] == false).length;
    final evaluatedCount = conformCount + devCount;
    final double rate = evaluatedCount > 0 ? (conformCount / evaluatedCount) : 1.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) => [
          // 1. En-tête officiel Galana
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderBlack, width: 1.2),
            ),
            child: pw.Row(
              children: [
                // Logo
                pw.Container(
                  width: 120,
                  height: 52,
                  padding: const pw.EdgeInsets.all(6),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(color: borderBlack, width: 1.2),
                    ),
                  ),
                  alignment: pw.Alignment.center,
                  child: logoImage != null
                      ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                      : pw.Text("GALANA",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: galanaGreen)),
                ),
                // Titre
                pw.Expanded(
                  child: pw.Container(
                    height: 52,
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          "GRILLE D'INSPECTION & CONTRÔLE TERRAIN",
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: headerTeal,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          checklist.title,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // Référence & Code
                pw.Container(
                  width: 130,
                  height: 52,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: borderBlack, width: 1.2),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        "Réf: CHK-${checklist.id ?? '01'}",
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        "Code: FOR-HSSE-CHK",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        "Date: ${checklist.date}",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 12),

          // 2. Informations générales
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderBlack, width: 0.8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Site / Emplacement : ${checklist.site}",
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text("Inspecteur : ${checklist.inspector}",
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text("Statut : ${checklist.status}",
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text("Taux de conformité : ${(rate * 100).toInt()}%",
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: galanaGreen)),
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // 3. Tableau des points de contrôle
          pw.Text("1. POINTS DE CONTRÔLE ÉVALUÉS",
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: headerTeal)),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: ["N°", "Point de contrôle", "Résultat", "Observation terrain"],
            columnWidths: {
              0: const pw.FixedColumnWidth(26),
              1: const pw.FlexColumnWidth(5),
              2: const pw.FixedColumnWidth(65),
              3: const pw.FlexColumnWidth(4),
            },
            headerStyle: pw.TextStyle(
                fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: headerTeal),
            headerDecoration: const pw.BoxDecoration(color: tableHeaderBg),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            data: points.map((p) {
              final String ans = p['answer'] ??
                  (p['yes'] == true ? 'OUI' : (p['yes'] == false ? 'NON' : 'N/A'));
              String resLabel = "Conforme";
              if (ans == 'NON') resLabel = "ÉCART";
              if (ans == 'N/A') resLabel = "N/A";

              return [
                (p['num'] ?? (points.indexOf(p) + 1)).toString(),
                p['title']?.toString() ?? '',
                resLabel,
                p['obs']?.toString() ?? '-',
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 14),

          // 4. Section Actions Correctives si écarts
          if (devCount > 0) ...[
            pw.Text("2. ACTIONS CORRECTIVES ASSIGNÉES",
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ["Pt", "Description de l'action", "Département", "Responsable", "Priorité"],
              columnWidths: {
                0: const pw.FixedColumnWidth(26),
                1: const pw.FlexColumnWidth(5),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(3),
                4: const pw.FixedColumnWidth(50),
              },
              headerStyle: pw.TextStyle(
                  fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFEE2E2)),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              data: points
                  .where((p) => (p['answer'] == 'NON' || p['yes'] == false) && p['action'] != null)
                  .map((p) {
                final act = p['action'] as Map<String, dynamic>;
                return [
                  (p['num'] ?? '').toString(),
                  act['description']?.toString() ?? '-',
                  act['department']?.toString() ?? 'Maintenance',
                  act['assignee']?.toString() ?? '-',
                  act['priority']?.toString() ?? 'Haute',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 14),
          ],

          // 5. Signatures
          pw.Spacer(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                width: 220,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderBlack, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("L'Inspecteur HSSE :",
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(checklist.inspector, style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 25),
                    pw.Text("Signature & Date :",
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.Container(
                width: 220,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderBlack, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Le Responsable de Site / Quart :",
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(checklist.site, style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 25),
                    pw.Text("Visa & Cachet :",
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Ouvre l'interface native d'impression / export PDF
  static Future<void> printOrShareChecklist(
    ChecklistItemData checklist, {
    List<Map<String, dynamic>>? items,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async =>
          generateChecklistPdf(checklist, items: items),
      name: 'Checklist_HSSE_${checklist.id ?? 'inspection'}.pdf',
    );
  }
}
