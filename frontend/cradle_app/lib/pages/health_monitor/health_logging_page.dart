import 'package:cradle_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import '../../providers/health_tracking_provider.dart';
import './widgets/vital_card.dart';
import './widgets/confirm_modal.dart';
import 'package:printing/printing.dart';
import '../../core/services/health_report_pdf_service.dart';

const _brand = DashboardBottomNav.primaryPink;

/// Health Monitor: lets the person turn tracking on/off for each vital
/// sign and view their trend once tracking begins.
class HealthLoggingPage extends StatelessWidget {
  const HealthLoggingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final provider = context.watch<HealthTrackingProvider>();

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(selectedIndex: 4),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 180),
        children: [
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  isBangla ? 'স্বাস্থ্য মনিটর' : 'Health Monitor',
                  style: AppText.headerTitle
                ),
              ),
              _ExportButton(
                isBangla: isBangla,
                provider: provider,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              isBangla
                  ? "আপনি কী পর্যবেক্ষণ করতে চান তা বেছে নিন। আপনি এটি চালু না করা এবং একটি সময়সূচী নির্ধারণ না করা পর্যন্ত কিছুই ট্র্যাক করা হয় না।"
                  : "Choose what you'd like to monitor. Nothing is tracked until you turn it on and set a schedule.",
              style: AppText.subtext.copyWith(fontSize: 16),
            ),
          ),
          for (final key in provider.orderedKeys) VitalCard(vitalKey: key),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.isBangla,
    required this.provider,
  });

  final bool isBangla;
  final HealthTrackingProvider provider;

  Future<void> _exportPdf(BuildContext context) async {
    if (!provider.hasHealthTracking) {
      showHealthToast(
        context,
        isBangla
            ? 'কোনো স্বাস্থ্য ট্র্যাকিং রেকর্ড পাওয়া যায়নি।'
            : 'There are no health tracking records to export.',
      );
      return;
    }

    try {
      showHealthToast(
        context,
        isBangla
            ? 'আপনার স্বাস্থ্য প্রতিবেদন প্রস্তুত করা হচ্ছে…'
            : 'Preparing your health report…',
      );

      final pdfBytes = await HealthReportPdfService.generate(
        provider: provider,
        isBangla: isBangla,
      );

      await Printing.layoutPdf(
        name: 'cradle_health_report.pdf',
        onLayout: (_) async => pdfBytes,
      );
    } catch (e, stackTrace) {
      debugPrint('Health PDF export failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      showHealthToast(
        context,
        isBangla
            ? 'PDF প্রতিবেদন তৈরি করা যায়নি।'
            : 'Could not generate the PDF report.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: ElevatedButton.icon(
        onPressed: () => _exportPdf(context),
        icon: Image.asset(
          "assets/icons/pdf.png",
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
        label: Text(
          isBangla ? 'পিডিএফ এক্সপোর্ট করুন' : 'Export PDF',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _brand,
          elevation: 3,
          shadowColor: _brand.withValues(alpha: 0.14),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
