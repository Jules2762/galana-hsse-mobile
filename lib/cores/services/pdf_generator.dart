import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<File> generateInspectionPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'RAPPORT D\'INSPECTION HSSE',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            'Inspection : Contrôle sécurité incendie',
          ),

          pw.Text(
            'Inspecteur : Jules ARIMANANA',
          ),

          pw.Text(
            'Date : 10/08/2026',
          ),

          pw.SizedBox(height: 30),

          pw.Header(
            level: 1,
            text: 'Résultats',
          ),

          pw.Bullet(
            text: 'Extincteurs conformes',
          ),

          pw.Bullet(
            text: 'Signalisation présente',
          ),

          pw.Bullet(
            text:
                'Une non-conformité détectée',
          ),
        ],
      ),
    );

    final directory =
        await getTemporaryDirectory();

    final file = File(
      '${directory.path}/rapport_hsse.pdf',
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    return file;
  }
}