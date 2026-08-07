import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../providers/language_provider.dart';
import '../providers/health_tracking_provider.dart';
import '../models/vital_definition.dart';
import '../utils/health_format_utils.dart';
import 'schedule_editor.dart';
import 'vital_plot_chart.dart';
import '../log_entry_page.dart';
import '../view_logs_page.dart';
import '../edit_prefs_page.dart';

const _brand = DashboardBottomNav.primaryPink;
const _brandSofter = Color(0xFFFCEEF5);
const _brandSoft = Color(0xFFF6D9E9);
const _ink = Color(0xFF3A2C33);
const _muted = Color(0xFF8A7680);
const _cardShadow = [
  BoxShadow(color: Color(0x29C87896), blurRadius: 16, offset: Offset(0, 6)),
];

class VitalCard extends StatelessWidget {
  const VitalCard({super.key, required this.vitalKey});

  final String vitalKey;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthTrackingProvider>();
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final state = provider.state(vitalKey);
    final expanded = provider.expandedKey == vitalKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: state.tracking
          ? _TrackedBody(vitalKey: vitalKey, isBangla: isBangla)
          : _UntrackedBody(vitalKey: vitalKey, isBangla: isBangla, expanded: expanded),
    );
  }
}

class _UntrackedBody extends StatelessWidget {
  const _UntrackedBody({
    required this.vitalKey,
    required this.isBangla,
    required this.expanded,
  });

  final String vitalKey;
  final bool isBangla;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final def = kVitalDefinitions[vitalKey]!;
    final provider = context.read<HealthTrackingProvider>();
    final state = context.watch<HealthTrackingProvider>().state(vitalKey);

    return Column(
      children: [
        InkWell(
          onTap: () => provider.toggleExpand(vitalKey),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _VitalIcon(iconAsset: def.iconAsset),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.name(isBangla),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isBangla ? 'ট্র্যাক করা হচ্ছে না' : 'Not tracking',
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: expanded,
                  activeTrackColor: _brand,
                  onChanged: (_) => provider.toggleExpand(vitalKey),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _brandSoft)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScheduleEditor(
                  freq: state.freq,
                  times: state.times,
                  days: state.days,
                  isBangla: isBangla,
                  showReminderNote: true,
                  onFreqChange: (d) => provider.changeFreq(vitalKey, d),
                  onTimeChange: (i, v) => provider.updateTime(vitalKey, i, v),
                  onDayToggle: (i) => provider.toggleDay(vitalKey, i),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LogEntryPage(
                          vitalKey: vitalKey,
                          mode: LogEntryMode.initial,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isBangla ? 'সময়সূচী সংরক্ষণ করুন' : 'Save schedule',
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }
}

class _TrackedBody extends StatelessWidget {
  const _TrackedBody({required this.vitalKey, required this.isBangla});

  final String vitalKey;
  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    final def = kVitalDefinitions[vitalKey]!;
    final provider = context.read<HealthTrackingProvider>();
    final state = context.watch<HealthTrackingProvider>().state(vitalKey);
    final last = state.logs.last;
    final chartLogs = state.logs.length > 7
        ? state.logs.sublist(state.logs.length - 7)
        : state.logs;
    final chartVals = chartLogs
        .map((l) => def.type == VitalType.bp ? l.systolic!.toDouble() : l.value!)
        .toList();
    final chartMin = chartVals.reduce((a, b) => a < b ? a : b);
    final chartMax = chartVals.reduce((a, b) => a > b ? a : b);
    final valueDisplay = def.type == VitalType.bp
        ? '${last.systolic}/${last.diastolic}'
        : localizedNumber(last.value!, isBangla);
    final daysPerWeek = state.days.where((d) => d).length;

    return InkWell(
      onTap: () => _openCardMenu(context, vitalKey, def.name(isBangla), isBangla),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _VitalIcon(iconAsset: def.iconAsset),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.name(isBangla),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isBangla
                            ? 'দৈনিক ${localizedNumber(state.freq, isBangla)}বার ট্র্যাক করা হচ্ছে · সপ্তাহে ${localizedNumber(daysPerWeek, isBangla)} দিন'
                            : 'Tracking ${state.freq}x daily · $daysPerWeek days/wk',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _brand,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _brand),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: valueDisplay,
                        style: GoogleFonts.gentiumBookPlus(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      TextSpan(
                        text: ' ${def.unit}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  fmtDateShort(last.date, isBangla: isBangla),
                  style: const TextStyle(fontSize: 11.5, color: _muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${def.type == VitalType.bp ? (isBangla ? 'সিস্টোলিক' : 'Systolic') : def.name(isBangla)} · ${isBangla ? '৭ দিনের প্রবণতা' : '7-day trend'} (${def.unit})',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _brand,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 76,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(localizedNumber(chartMax, isBangla),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _muted)),
                      Text(localizedNumber(chartMin, isBangla),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      VitalPlotChart(values: chartVals),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: chartLogs
                            .map((l) => Expanded(
                                  child: Text(
                                    fmtDDMM(l.date, isBangla: isBangla),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: _muted),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalIcon extends StatelessWidget {
  const _VitalIcon({required this.iconAsset});
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _brandSofter,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Image.asset(
        iconAsset,
        width: 22,
        height: 22,
        color: _brand,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder: (_, __, ___) => const Icon(Icons.favorite, color: _brand, size: 20),
      ),
      alignment: Alignment.center,
    );
  }
}

void _openCardMenu(BuildContext context, String vitalKey, String name, bool isBangla) {
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
                child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _muted)),
              ),
              const SizedBox(height: 6),
              _sheetOption(
                context,
                icon: Icons.list_alt,
                label: isBangla ? 'লগ দেখুন' : 'View Logs',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ViewLogsPage(vitalKey: vitalKey)),
                  );
                },
              ),
              _sheetOption(
                context,
                icon: Icons.settings_outlined,
                label: isBangla ? 'পছন্দ সম্পাদনা করুন' : 'Edit Preferences',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditPrefsPage(vitalKey: vitalKey)),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _sheetOption(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool danger = false,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: danger ? const Color(0xFFD64545) : _brand),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: danger ? const Color(0xFFD64545) : _ink,
            ),
          ),
        ],
      ),
    ),
  );
}
