import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';
import 'quick_status_card.dart';

class QuickStatusRow extends StatelessWidget {
  const QuickStatusRow({
    super.key,
    required this.nextDoseName,
    required this.nextDoseNameBn,
    required this.nextDoseTime,
    required this.nextDoseEta,
    required this.nextDoseEtaBn,
    required this.lastVitalLabel,
    required this.lastVitalLabelBn,
    required this.lastVitalSub,
    required this.lastVitalSubBn,
    this.onMedicineTap,
    this.onHealthTap,
  });

  final String nextDoseName;
  final String nextDoseNameBn;
  final String nextDoseTime;
  final String nextDoseEta;
  final String nextDoseEtaBn;
  final String lastVitalLabel;
  final String lastVitalLabelBn;
  final String lastVitalSub;
  final String lastVitalSubBn;
  final VoidCallback? onMedicineTap;
  final VoidCallback? onHealthTap;

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    return Row(
      children: [
        QuickStatusCard(
          label: isBangla ? 'পরবর্তী ডোজ' : 'NEXT DOSE',
          value: isBangla ? '$nextDoseNameBn · $nextDoseTime' : '$nextDoseName · $nextDoseTime',
          sub: isBangla ? nextDoseEtaBn : nextDoseEta,
          onTap: onMedicineTap,
        ),
        const SizedBox(width: 12),
        QuickStatusCard(
          label: isBangla ? 'সর্বশেষ রিডিং' : 'LAST READING',
          value: isBangla ? lastVitalLabelBn : lastVitalLabel,
          sub: isBangla ? lastVitalSubBn : lastVitalSub,
          onTap: onHealthTap,
        ),
      ],
    );
  }
}