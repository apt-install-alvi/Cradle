import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// One row in the risk assessment history list.
class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    final riskLevel = (item['risk_level'] ?? 'LOW').toString().toUpperCase();
    final createdAt = item['created_at'] != null 
        ? DateTime.tryParse(item['created_at'])?.toLocal() ?? DateTime.now() 
        : DateTime.now();
    
    final symptoms = (item['symptoms'] as List<dynamic>?) ?? [];
    final vitals = (item['diagnosis_vitals'] as List<dynamic>?) ?? [];

    Color tagColor;
    Color tagBgColor;
    String tagLabel;

    if (riskLevel == 'HIGH') {
      tagColor = AppColors.high;
      tagBgColor = AppColors.highBg;
      tagLabel = isBangla ? 'উচ্চ ঝুঁকি' : 'High Risk';
    } else if (riskLevel == 'MEDIUM') {
      tagColor = AppColors.medium;
      tagBgColor = AppColors.mediumBg;
      tagLabel = isBangla ? 'মাঝারি ঝুঁকি' : 'Medium Risk';
    } else {
      tagColor = AppColors.low;
      tagBgColor = AppColors.lowBg;
      tagLabel = isBangla ? 'নিম্ন ঝুঁকি' : 'Low Risk';
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: appCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(createdAt),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tagLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: tagColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Symptoms
              if (symptoms.isNotEmpty) ...[
                Text(
                  isBangla ? 'উপসর্গসমূহ:' : 'Symptoms:',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: symptoms.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF2F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${s['type'] ?? ''}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.roseDark),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Required Vitals
              if (vitals.isNotEmpty) ...[
                Text(
                  isBangla ? 'প্রয়োজনীয় স্বাস্থ্য পরিমাপ (Vitals):' : 'Required Vitals:',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: vitals.map((v) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5F7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEFE8EC), width: 1),
                      ),
                      child: Text(
                        '${v['vital_name']}: ${v['value']} ${v['unit'] ?? ''}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
