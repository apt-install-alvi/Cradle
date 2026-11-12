import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:bangla_pdf/widgets.dart' as pw;

import '../../pages/health_monitor/models/vital_definition.dart';
import '../../pages/health_monitor/models/vital_log.dart';
import '../../providers/health_tracking_provider.dart';

class HealthReportPdfService {
  static Future<Uint8List> generate({
    required HealthTrackingProvider provider,
    required bool isBangla,
  }) async {
    final pdf = pw.Document();

    // Load a Unicode font so Bangla can be rendered correctly.
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansBengali-Regular.ttf',
    );
    final boldFontData = await rootBundle.load(
      'assets/fonts/NotoSansBengali-Bold.ttf',
    );

    final font = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(boldFontData);

    final textStyle = pw.TextStyle(font: font);
    final boldTextStyle = pw.TextStyle(font: boldFont);

    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        header: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'CRADLE',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                ),
              ),
              pw.Text(
                isBangla ? 'স্বাস্থ্য প্রতিবেদন' : 'Health Report',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'CRADLE',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                ),
              ),
              pw.Text(
                '${context.pageNumber} / ${context.pagesCount}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        build: (context) {
          return [
            pw.Text(
              isBangla
                  ? 'স্বাস্থ্য পর্যবেক্ষণ প্রতিবেদন'
                  : 'Health Monitoring Report',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 24,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              isBangla
                  ? 'তৈরির তারিখ: ${_formatDateTime(now)}'
                  : 'Generated: ${_formatDateTime(now)}',
              style: textStyle.copyWith(
                fontSize: 10,
              ),
            ),

            pw.SizedBox(height: 24),

            ..._buildVitalSections(
              provider: provider,
              isBangla: isBangla,
              font: font,
              boldFont: boldFont,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _buildVitalSections({
    required HealthTrackingProvider provider,
    required bool isBangla,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    final widgets = <pw.Widget>[];

    for (final key in provider.orderedKeys) {
      final definition = kVitalDefinitions[key]!;
      final state = provider.state(key);

      final logs = List<VitalLog>.from(state.logs)
        ..sort((a, b) => b.date.compareTo(a.date));

      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                width: 1,
                color: PdfColors.grey300,
              ),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                definition.name(isBangla),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                ),
              ),
              pw.Text(
                state.tracking
                    ? (isBangla ? 'ট্র্যাকিং চালু' : 'Tracking active')
                    : (isBangla ? 'ট্র্যাকিং বন্ধ' : 'Tracking inactive'),
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      );

      if (logs.isEmpty) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              isBangla
                  ? 'কোনো রেকর্ড পাওয়া যায়নি।'
                  : 'No recorded readings.',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
        );

        continue;
      }

      final headers = definition.type == VitalType.bp
          ? [
              isBangla ? 'তারিখ' : 'Date',
              isBangla ? 'সময়' : 'Time',
              isBangla ? 'সিস্টোলিক' : 'Systolic',
              isBangla ? 'ডায়াস্টোলিক' : 'Diastolic',
              isBangla ? 'নোট' : 'Note',
            ]
          : [
              isBangla ? 'তারিখ' : 'Date',
              isBangla ? 'সময়' : 'Time',
              isBangla ? 'মান' : 'Value',
              if (definition.hasContext)
                isBangla ? 'প্রসঙ্গ' : 'Context',
              isBangla ? 'নোট' : 'Note',
            ];

      final rows = logs.map((log) {
        if (definition.type == VitalType.bp) {
          return [
            _formatDate(log.date),
            _formatTime(log.date),
            log.systolic?.toString() ?? '—',
            log.diastolic?.toString() ?? '—',
            log.note.isEmpty ? '—' : log.note,
          ];
        }

        return [
          _formatDate(log.date),
          _formatTime(log.date),
          _formatValue(log.value, definition.decimals),
          if (definition.hasContext)
            log.context?.isNotEmpty == true ? log.context! : '—',
          log.note.isEmpty ? '—' : log.note,
        ];
      }).toList();

      widgets.add(
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
          headerStyle: pw.TextStyle(
            font: boldFont,
            fontSize: 8,
          ),
          cellStyle: pw.TextStyle(
            font: font,
            fontSize: 8,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          border: pw.TableBorder.all(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
      );
    }

    return widgets;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }

  static String _formatValue(double? value, int decimals) {
    if (value == null) return '—';
    return value.toStringAsFixed(decimals);
  }
}