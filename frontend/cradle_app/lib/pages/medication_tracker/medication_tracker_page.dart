import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import './models/medication.dart';
import './models/scheduled_dose.dart';
import '../../providers/language_provider.dart';
import './widgets/adherence_calendar_card.dart';
import './widgets/dose_card.dart';
import './widgets/medication_list_card.dart';
import './widgets/add_medication_sheet.dart';

class MedicationTrackerPage extends StatefulWidget {
  const MedicationTrackerPage({super.key});

  @override
  State<MedicationTrackerPage> createState() => _MedicationTrackerPageState();
}

class _MedicationTrackerPageState extends State<MedicationTrackerPage> {
  late List<Medication> _medications;
  late List<ScheduledDose> _todayDoses;
  late Map<DateTime, int> _adherenceByDate;

  @override
  void initState() {
    super.initState();
    _medications = _mockMedications();
    _todayDoses = _buildTodayDoses(_medications);
    _adherenceByDate = _mockAdherenceForMonth(DateTime.now());
  }

  // ---------------------------------------------------------------------
  // Mock data. Replace with real persistence / backend calls.
  // ---------------------------------------------------------------------

  List<Medication> _mockMedications() {
    return [
      Medication(
        id: 'folic-acid',
        name: 'Folic Acid',
        doseAmount: 400,
        doseUnit: 'mcg',
        frequency: MedicationFrequency.twice,
        iconAsset: 'assets/icons/round_pill.svg',
        times: const [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 21, minute: 0)],
      ),
      Medication(
        id: 'iron-supplement',
        name: 'Iron Supplement',
        doseAmount: 65,
        doseUnit: 'mg',
        frequency: MedicationFrequency.once,
        iconAsset: 'assets/icons/pill.svg',
        times: const [TimeOfDay(hour: 8, minute: 0)],
      ),
      Medication(
        id: 'calcium-vit-d',
        name: 'Calcium + Vitamin D',
        doseAmount: 500,
        doseUnit: 'mg',
        frequency: MedicationFrequency.once,
        iconAsset: 'assets/icons/bottle.svg',
        times: const [TimeOfDay(hour: 14, minute: 0)],
      ),
      Medication(
        id: 'bp-tablet',
        name: 'Blood Pressure Tablet',
        doseAmount: 10,
        doseUnit: 'mg',
        frequency: MedicationFrequency.once,
        iconAsset: 'assets/icons/round_pill.svg',
        times: const [TimeOfDay(hour: 21, minute: 0)],
      ),
    ];
  }

  List<ScheduledDose> _buildTodayDoses(List<Medication> medications) {
    final doses = <ScheduledDose>[];
    for (final med in medications) {
      for (var i = 0; i < med.times.length; i++) {
        final time = med.times[i];
        doses.add(
          ScheduledDose(
            id: '${med.id}-$i',
            medication: med,
            time: time,
            period: dosePeriodForTime(time),
            // Demo: mark the morning Folic Acid dose as already taken.
            taken: med.id == 'folic-acid' && time.hour == 8,
          ),
        );
      }
    }
    doses.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return doses;
  }

  Map<DateTime, int> _mockAdherenceForMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final data = <DateTime, int>{};
    const pattern = [100, 100, 75, 100, 50, 100, 100, 25, 100, 75];
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      if (date.isAfter(DateTime.now())) continue;
      data[date] = pattern[(day - 1) % pattern.length];
    }
    return data;
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

  void _toggleDoseTaken(ScheduledDose dose) {
    setState(() => dose.taken = !dose.taken);
  }

  Future<void> _openAddMedicationSheet({Medication? existing}) async {
    final result = await showAddMedicationSheet(context, existing: existing);
    if (result == null) return;

    setState(() {
      if (existing != null) {
        final index = _medications.indexWhere((m) => m.id == existing.id);
        if (index != -1) _medications[index] = result;
      } else {
        _medications.add(result);
      }
      _todayDoses = _buildTodayDoses(_medications);
    });
  }

  void _deleteMedication(Medication medication) {
    setState(() {
      _medications.removeWhere((m) => m.id == medication.id);
      _todayDoses = _buildTodayDoses(_medications);
    });
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    final morningDoses = _todayDoses.where((d) => d.period == DosePeriod.morning).toList();
    final afternoonDoses = _todayDoses.where((d) => d.period == DosePeriod.afternoon).toList();
    final nightDoses = _todayDoses.where((d) => d.period == DosePeriod.night).toList();

    return GradientScaffold(
      // None of the four core tabs represent this screen, so no item is
      // highlighted; pass an out-of-range index to keep all inactive.
      bottomNavigationBar: const DashboardBottomNav(selectedIndex: 3),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  isBangla ? 'ওষুধ ট্র্যাকার' : 'Medication Tracker',
                  style: AppText.headerTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  isBangla
                      ? "আজকের ডোজ এবং আপনার ওষুধের তালিকা সম্পর্কে সচেতন থাকুন।"
                      : "Stay on track with today's doses and your medication list.",
                  style: AppText.subtext,
                ),
                const SizedBox(height: 18),
                AdherenceCalendarCard(
                  adherenceByDate: _adherenceByDate,
                  initialMonth: DateTime.now(),
                ),
                const SizedBox(height: 30),
                Text(
                  isBangla ? "আজকের সময়সূচী" : "Today's Schedule",
                  style: AppText.sectionHeading,
                ),
                if (morningDoses.isNotEmpty)
                  _DoseTimelineGroup(
                    label: dosePeriodLabel(DosePeriod.morning, isBangla),
                    doses: morningDoses,
                    onToggle: _toggleDoseTaken,
                  ),
                if (afternoonDoses.isNotEmpty)
                  _DoseTimelineGroup(
                    label: dosePeriodLabel(DosePeriod.afternoon, isBangla),
                    doses: afternoonDoses,
                    onToggle: _toggleDoseTaken,
                  ),
                if (nightDoses.isNotEmpty)
                  _DoseTimelineGroup(
                    label: dosePeriodLabel(DosePeriod.night, isBangla),
                    doses: nightDoses,
                    onToggle: _toggleDoseTaken,
                  ),
                const SizedBox(height: 6),
                Text(
                  isBangla ? 'আমার ওষুধসমূহ' : 'My Medications',
                  style: AppText.sectionHeading,
                ),
                const SizedBox(height: 12),
                for (final med in _medications)
                  MedicationListCard(
                    medication: med,
                    onEdit: () => _openAddMedicationSheet(existing: med),
                    onDelete: () => _deleteMedication(med),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 4,
            bottom: 16,
            child: Material(
              color: DashboardBottomNav.primaryPink,
              shape: const CircleBorder(),
              elevation: 6,
              shadowColor: DashboardBottomNav.primaryPink.withValues(alpha: .4),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openAddMedicationSheet(),
                child: const SizedBox(
                  width: 58,
                  height: 58,
                  child: Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseTimelineGroup extends StatelessWidget {
  final String label;
  final List<ScheduledDose> doses;
  final ValueChanged<ScheduledDose> onToggle;

  const _DoseTimelineGroup({
    required this.label,
    required this.doses,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: DashboardBottomNav.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: DashboardBottomNav.primaryPink,
                  ),
                ),
              ],
            ),
          ),
          for (final dose in doses)
            DoseCard(dose: dose, onToggle: () => onToggle(dose)),
        ],
      ),
    );
  }
}
