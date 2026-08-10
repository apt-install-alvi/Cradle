import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import '../../providers/health_tracking_provider.dart';
import './models/vital_definition.dart';
import './models/vital_log.dart';
import './utils/health_format_utils.dart';
import './widgets/health_top_bar.dart';
import './widgets/confirm_modal.dart';
import 'log_entry_page.dart';

const _brand = DashboardBottomNav.primaryPink;
const _brandSofter = Color(0xFFFCEEF5);
const _danger = Color(0xFFD64545);
const _ink = Color(0xFF3A2C33);
const _muted = Color(0xFF8A7680);

class ViewLogsPage extends StatelessWidget {
  const ViewLogsPage({super.key, required this.vitalKey});

  final String vitalKey;

  @override
  Widget build(BuildContext context) {
    final def = kVitalDefinitions[vitalKey]!;
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final state = context.watch<HealthTrackingProvider>().state(vitalKey);
    final sorted = [...state.logs]..sort((a, b) => b.date.compareTo(a.date));

    return GradientScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          HealthTopBar(
            title: isBangla ? '${def.nameBn} লগ' : '${def.nameEn} Logs',
            subtitle: isBangla
                ? '${localizedNumber(sorted.length, isBangla)}টি রিডিং রেকর্ড করা হয়েছে'
                : '${sorted.length} reading${sorted.length == 1 ? '' : 's'} recorded',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sorted.isEmpty
                ? _EmptyState(isBangla: isBangla)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: sorted.length,
                    itemBuilder: (context, i) {
                      final log = sorted[i];
                      return _LogRow(
                        vitalKey: vitalKey,
                        log: log,
                        def: def,
                        isBangla: isBangla,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isBangla});
  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          children: [
            const Text('📭', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 10),
            Text(
              isBangla ? 'এখনো কোনো রিডিং লগ করা হয়নি।' : 'No readings logged yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({
    required this.vitalKey,
    required this.log,
    required this.def,
    required this.isBangla,
  });

  final String vitalKey;
  final VitalLog log;
  final VitalDefinition def;
  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    final valueText = def.type == VitalType.bp
        ? '${log.systolic}/${log.diastolic}'
        : localizedNumber(log.value!, isBangla);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openLogActionSheet(context, vitalKey, log, def, isBangla),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x29C87896), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: valueText,
                          style: GoogleFonts.gentiumBookPlus(fontSize: 20, fontWeight: FontWeight.w700, color: _ink),
                        ),
                        TextSpan(
                          text: ' ${def.unit}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmtDateShort(log.date, isBangla: isBangla),
                    style: const TextStyle(fontSize: 16, color: _muted),
                  ),
                  if (log.context != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _brandSofter,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        localizedGlucoseContext(log.context!, isBangla),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _brand),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _brand),
          ],
        ),
      ),
    );
  }
}

void _openLogActionSheet(
  BuildContext context,
  String vitalKey,
  VitalLog log,
  VitalDefinition def,
  bool isBangla,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBD8E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  isBangla ? 'রিডিং অপশন' : 'Reading options',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _muted),
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LogEntryPage(vitalKey: vitalKey, mode: LogEntryMode.edit, logId: log.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 30, color: _brand),
                      const SizedBox(width: 12),
                      Text(
                        isBangla ? 'রিডিং সম্পাদনা করুন' : 'Edit reading',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _ink),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showHealthConfirmDialog(
                    context,
                    emoji: '🗑️',
                    title: isBangla ? 'এই রিডিংটি মুছবেন?' : 'Delete this reading?',
                    message: isBangla
                        ? "এই রিডিংটি স্থায়ীভাবে মুছে ফেলা হবে। এটি ফিরিয়ে আনা যাবে না।"
                        : "This reading will be permanently removed. This can't be undone.",
                    cancelLabel: isBangla ? 'বাতিল' : 'Cancel',
                    confirmLabel: isBangla ? 'মুছুন' : 'Delete',
                    onConfirm: () {
                      context.read<HealthTrackingProvider>().deleteLog(vitalKey, log.id);
                      showHealthToast(context, isBangla ? 'রিডিং মুছে ফেলা হয়েছে' : 'Reading deleted');
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 30, color: _danger),
                      const SizedBox(width: 12),
                      Text(
                        isBangla ? 'রিডিং মুছুন' : 'Delete reading',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _danger),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
