import 'package:flutter/material.dart';
import '../../../core/models/diagnosis_result.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/language_provider.dart';
import 'package:provider/provider.dart';

/// One row in the diagnosis history list: date, diagnosis name and
/// symptoms are all left-aligned, with only the risk tag (High/Med/Low)
/// pinned to the right.
class HistoryCard extends StatelessWidget {
  final DiagnosisResult entry;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.entry, this.onTap});

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.card),
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
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.localizedDiagnosisName(isBangla),
                      textAlign: TextAlign.left,
                      style: AppText.historyTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.reportedSymptoms
                          .map((s) => s.displayLabel(isBangla))
                          .join(' · '),
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: entry.riskLevel.backgroundColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.riskLevel.shortDisplayLabel(isBangla),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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
    if (diff.inDays == 0) return isBangla ? 'আজ' : 'Today';
    if (diff.inDays == 1) return isBangla ? 'গতকাল' : 'Yesterday';
    if (diff.inDays < 7) {
      return isBangla ? '${diff.inDays} দিন আগে' : '${diff.inDays} days ago';
    }
    if (diff.inDays < 14) return isBangla ? 'গত সপ্তাহে' : 'Last week';
    return isBangla
        ? '${(diff.inDays / 7).floor()} সপ্তাহ আগে'
        : '${(diff.inDays / 7).floor()} weeks ago';
  }
}
