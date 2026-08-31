import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/diagnosis_result.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/language_provider.dart';
import 'package:provider/provider.dart';

/// One row in the risk assessment history list.
class HistoryCard extends StatelessWidget {
  final DiagnosisResult entry;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Primary colour - FFFFFF 52% opacity
            color: Colors.white.withOpacity(0.52),
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: const Color(0xFFAB0A65).withOpacity(0.12), width: 1.5),
            boxShadow: appCardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formattedDate(isBangla),
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      isBangla
                          ? '${entry.riskLevel.displayLabel(true)} মূল্যায়ন'
                          : '${entry.riskLevel.displayLabel(false)} Assessment',
                      style: AppText.historyTitle,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      entry.reportedSymptoms
                          .map((s) => s.displayLabel(isBangla))
                          .join(' · '),
                      style: GoogleFonts.gentiumBookPlus(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFAB0A65).withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: entry.riskLevel.backgroundColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: entry.riskLevel.color.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  entry.riskLevel.shortDisplayLabel(isBangla),
                  style: GoogleFonts.gentiumBookPlus(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: entry.riskLevel.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedDate(bool isBangla) {
    final now = DateTime.now();
    final diff = now.difference(entry.timestamp);

    if (diff.inDays == 0) {
      return isBangla ? 'আজ' : 'Today';
    }

    if (diff.inDays == 1) {
      return isBangla ? 'গতকাল' : 'Yesterday';
    }

    if (diff.inDays < 7) {
      return isBangla
          ? '${diff.inDays} দিন আগে'
          : '${diff.inDays} days ago';
    }

    if (diff.inDays < 14) {
      return isBangla ? 'গত সপ্তাহে' : 'Last week';
    }

    return isBangla
        ? '${(diff.inDays / 7).floor()} সপ্তাহ আগে'
        : '${(diff.inDays / 7).floor()} weeks ago';
  }
}