import 'package:flutter/services.dart';
import 'package:gestion_hsse/cores/models/report_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPdfService {
  static const PdfColor galanaGreen = PdfColor.fromInt(0xFF0F9D58);
  static const PdfColor galanaTeal = PdfColor.fromInt(0xFF007A78);
  static const PdfColor tableHeaderBg = PdfColor.fromInt(0xFFF1F5F9);
  static const PdfColor borderGrey = PdfColor.fromInt(0xFFCBD5E1);

  /// Génère le PDF complet du rapport d'inspection/audit
  static Future<Uint8List> generateReportPdf(ReportModel report) async {
    final pdf = pw.Document();

    PdfColor scoreColor;
    if (report.conformity >= 85) {
      scoreColor = const PdfColor.fromInt(0xFF16A34A); // Green
    } else if (report.conformity >= 70) {
      scoreColor = const PdfColor.fromInt(0xFFD97706); // Amber
    } else {
      scoreColor = const PdfColor.fromInt(0xFFDC2626); // Red
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // ============================================
            // EN-TÊTE OFFICIEL GALANA HSSE
            // ============================================
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: galanaGreen, width: 2.5),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GALANA MADAGASCAR',
                        style: pw.TextStyle(
                          color: galanaGreen,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'DIRECTION QUALITÉ, HYGIÈNE, SÉCURITÉ & ENVIRONNEMENT (HSSE)',
                        style: const pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: tableHeaderBg,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: borderGrey, width: 0.8),
                    ),
                    child: pw.Text(
                      report.reference,
                      style: pw.TextStyle(
                        color: galanaTeal,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // TITRE DU RAPPORT
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'RAPPORT OFFICIEL D\'INSPECTION ET D\'AUDIT',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: galanaTeal,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    report.title.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // ============================================
            // FICHE D'IDENTIFICATION & MÉTADONNÉES
            // ============================================
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFAFAFA),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderGrey, width: 0.8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildMetaItem('Site / Dépôt :', report.site),
                        pw.SizedBox(height: 5),
                        _buildMetaItem('Inspecteur HSSE :', report.inspector),
                        pw.SizedBox(height: 5),
                        _buildMetaItem('Catégorie :', report.category),
                      ],
                    ),
                  ),
                  pw.Container(width: 1, height: 60, color: borderGrey),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildMetaItem('Date d\'évaluation :', report.date),
                        pw.SizedBox(height: 5),
                        _buildMetaItem('Statut global :', report.status),
                        pw.SizedBox(height: 5),
                        _buildMetaItem('Non-conformités :', '${report.nonConformities.length} détectée(s)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // ============================================
            // JAUGE DU SCORE DE CONFORMITÉ
            // ============================================
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: scoreColor.flatten(),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: scoreColor, width: 1.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TAUX DE CONFORMITÉ GLOBALE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Évaluation basée sur les référentiels opérationnels et réglementaires Galana.',
                        style: const pw.TextStyle(
                          fontSize: 7.5,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: scoreColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      '${report.conformity}%',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // ============================================
            // RÉSUMÉ EXÉCUTIF
            // ============================================
            pw.Text(
              'RÉSUMÉ EXÉCUTIF',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: galanaGreen,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: borderGrey, width: 0.8),
              ),
              child: pw.Text(
                report.executiveSummary,
                style: const pw.TextStyle(
                  fontSize: 8.5,
                  height: 1.4,
                  color: PdfColors.grey800,
                ),
              ),
            ),

            pw.SizedBox(height: 14),

            // ============================================
            // RÉSULTATS DÉTAILLÉS PAR SECTION
            // ============================================
            if (report.sections.isNotEmpty) ...[
              pw.Text(
                'ÉVALUATION PAR SECTION',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: galanaGreen,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: tableHeaderBg),
                    children: [
                      _tableHeaderCell('Intitulé de la section', flex: 3),
                      _tableHeaderCell('Points conformes', flex: 1, align: pw.TextAlign.center),
                      _tableHeaderCell('Score (%)', flex: 1, align: pw.TextAlign.right),
                    ],
                  ),
                  for (final sec in report.sections)
                    pw.TableRow(
                      children: [
                        _tableBodyCell(sec.title, flex: 3),
                        _tableBodyCell(
                          sec.totalQuestions > 0 ? '${sec.compliantQuestions} / ${sec.totalQuestions}' : 'N/A',
                          flex: 1,
                          align: pw.TextAlign.center,
                        ),
                        _tableBodyCell(
                          '${sec.score}%',
                          flex: 1,
                          align: pw.TextAlign.right,
                          color: sec.score >= 80 ? PdfColors.green700 : PdfColors.red700,
                          bold: true,
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 14),
            ],

            // ============================================
            // TABLEAU DES NON-CONFORMITÉS
            // ============================================
            if (report.nonConformities.isNotEmpty) ...[
              pw.Text(
                'NON-CONFORMITÉS & ÉCARTS IDENTIFIÉS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: tableHeaderBg),
                    children: [
                      _tableHeaderCell('Écart constaté', flex: 3),
                      _tableHeaderCell('Section concernée', flex: 2),
                      _tableHeaderCell('Criticité', flex: 1, align: pw.TextAlign.center),
                    ],
                  ),
                  for (final nc in report.nonConformities)
                    pw.TableRow(
                      children: [
                        _tableBodyCell(nc.title, flex: 3),
                        _tableBodyCell(nc.section, flex: 2),
                        _tableBodyCell(
                          nc.priority,
                          flex: 1,
                          align: pw.TextAlign.center,
                          color: nc.priority == 'Critique' ? PdfColors.red700 : PdfColors.orange700,
                          bold: true,
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 14),
            ],

            // ============================================
            // ACTIONS CORRECTIVES ENGAGÉES
            // ============================================
            if (report.actions.isNotEmpty) ...[
              pw.Text(
                'ACTIONS CORRECTIVES ENGAGÉES',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: galanaTeal,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: tableHeaderBg),
                    children: [
                      _tableHeaderCell('Action requise', flex: 3),
                      _tableHeaderCell('Responsable', flex: 2),
                      _tableHeaderCell('Échéance', flex: 1, align: pw.TextAlign.center),
                      _tableHeaderCell('Statut', flex: 1, align: pw.TextAlign.center),
                    ],
                  ),
                  for (final act in report.actions)
                    pw.TableRow(
                      children: [
                        _tableBodyCell(act.title, flex: 3),
                        _tableBodyCell(act.assignee, flex: 2),
                        _tableBodyCell(act.dueDate, flex: 1, align: pw.TextAlign.center),
                        _tableBodyCell(
                          act.status,
                          flex: 1,
                          align: pw.TextAlign.center,
                          bold: true,
                          color: act.status == 'Clôturée' ? PdfColors.green700 : PdfColors.blue700,
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 18),
            ],

            // ============================================
            // ZONE DE SIGNATURES
            // ============================================
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 220,
                  height: 75,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: borderGrey, width: 0.8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Visa de l\'Inspecteur HSSE :',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        report.inspector,
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: 220,
                  height: 75,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: borderGrey, width: 0.8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Visa du Responsable de Site :',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        'Signature & Cachet',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: borderGrey, width: 0.5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Galana Madagascar — Rapport officiel interne HSSE',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} sur ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Ouvre l'interface native d'impression / export PDF
  static Future<void> printReport(ReportModel report) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generateReportPdf(report),
      name: '${report.reference}_Rapport.pdf',
    );
  }

  /// Partage directement le rapport PDF via l'interface système
  static Future<void> shareReport(ReportModel report) async {
    final pdfBytes = await generateReportPdf(report);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${report.reference}_Rapport.pdf',
    );
  }

  static pw.Widget _buildMetaItem(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$label ',
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 8.5,
              color: PdfColors.grey700,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, {int flex = 1, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: galanaTeal,
        ),
      ),
    );
  }

  static pw.Widget _tableBodyCell(
    String text, {
    int flex = 1,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor color = PdfColors.black,
    bool bold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}
