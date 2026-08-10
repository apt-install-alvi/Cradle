import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../providers/language_provider.dart';
import '../../providers/health_tracking_provider.dart';
import './models/vital_definition.dart';
import './widgets/health_top_bar.dart';
import './widgets/schedule_editor.dart';
import './widgets/confirm_modal.dart';

const _brand = Color(0xFFAB0A65);
const _dangerBg = Color(0xFFFBE4E4);
const _danger = Color(0xFFD64545);

class EditPrefsPage extends StatelessWidget {
  const EditPrefsPage({super.key, required this.vitalKey});

  final String vitalKey;

  @override
  Widget build(BuildContext context) {
    final def = kVitalDefinitions[vitalKey]!;
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final provider = context.watch<HealthTrackingProvider>();
    final state = provider.state(vitalKey);

    return GradientScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          HealthTopBar(
            title: def.name(isBangla),
            subtitle: isBangla ? 'আপনার ট্র্যাকিং সময়সূচী সমন্বয় করুন' : 'Adjust your tracking schedule',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x29C87896), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: ScheduleEditor(
              freq: state.freq,
              times: state.times,
              days: state.days,
              isBangla: isBangla,
              showReminderNote: false,
              onFreqChange: (d) => provider.changeFreq(vitalKey, d),
              onTimeChange: (i, v) => provider.updateTime(vitalKey, i, v),
              onDayToggle: (i) => provider.toggleDay(vitalKey, i),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showHealthToast(context, isBangla ? 'সময়সূচী আপডেট হয়েছে' : 'Schedule updated');
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                isBangla ? 'পরিবর্তন সংরক্ষণ করুন' : 'Save changes',
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _confirmStop(context, vitalKey, def, isBangla),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerBg,
                foregroundColor: _danger,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                isBangla ? '${def.nameBn} ট্র্যাকিং বন্ধ করুন' : 'Stop tracking ${def.nameEn}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStop(BuildContext context, String vitalKey, VitalDefinition def, bool isBangla) {
    showHealthConfirmDialog(
      context,
      emoji: '⏸️',
      title: isBangla ? '${def.nameBn} ট্র্যাকিং বন্ধ করবেন?' : 'Stop tracking ${def.nameEn}?',
      message: isBangla
          ? "আপনি আর রিমাইন্ডার পাবেন না। আপনার আগের রিডিংগুলো সংরক্ষিত থাকবে।"
          : "You'll stop receiving reminders. Your past readings will be kept.",
      cancelLabel: isBangla ? 'বাতিল' : 'Cancel',
      confirmLabel: isBangla ? 'ট্র্যাকিং বন্ধ করুন' : 'Stop tracking',
      onConfirm: () {
        context.read<HealthTrackingProvider>().stopTracking(vitalKey);
        showHealthToast(context, isBangla ? '${def.nameBn} ট্র্যাকিং বন্ধ করা হয়েছে' : '${def.nameEn} tracking stopped');
        Navigator.of(context).pop();
      },
    );
  }
}
